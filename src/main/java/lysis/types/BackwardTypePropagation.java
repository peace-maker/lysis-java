package lysis.types;

import java.nio.ByteBuffer;

import lysis.BitConverter;
import lysis.Public;
import lysis.lstructure.Argument;
import lysis.lstructure.Function;
import lysis.lstructure.Scope;
import lysis.lstructure.Signature;
import lysis.lstructure.Variable;
import lysis.lstructure.VariableType;
import lysis.nodes.NodeBlock;
import lysis.nodes.NodeGraph;
import lysis.nodes.NodeList;
import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;
import lysis.nodes.types.DArrayRef;
import lysis.nodes.types.DBinary;
import lysis.nodes.types.DBoolean;
import lysis.nodes.types.DBoundsCheck;
import lysis.nodes.types.DCall;
import lysis.nodes.types.DCharacter;
import lysis.nodes.types.DConstant;
import lysis.nodes.types.DDeclareLocal;
import lysis.nodes.types.DDeclareStatic;
import lysis.nodes.types.DFloat;
import lysis.nodes.types.DFunction;
import lysis.nodes.types.DGenArray;
import lysis.nodes.types.DGlobal;
import lysis.nodes.types.DJump;
import lysis.nodes.types.DJumpCondition;
import lysis.nodes.types.DLoad;
import lysis.nodes.types.DLocalRef;
import lysis.nodes.types.DNode;
import lysis.nodes.types.DReturn;
import lysis.nodes.types.DStore;
import lysis.nodes.types.DString;
import lysis.nodes.types.DSysReq;
import lysis.sourcepawn.SPOpcode;
import lysis.types.TypeUnit.Kind;

public class BackwardTypePropagation extends NodeVisitor {
	private NodeGraph graph_;
	private NodeBlock block_;

	public BackwardTypePropagation(NodeGraph graph) {
		graph_ = graph;
	}

	public void propagate() throws Exception {
		for (int i = graph_.numBlocks() - 1; i >= 0; i--) {
			block_ = graph_.blocks(i);
			for (NodeList.reverse_iterator iter = block_.nodes().rbegin(); iter.more(); iter.next())
				iter.node().accept(this);
		}
	}

	private void propagateInputs(DNode lhs, DNode rhs) {
		lhs.typeSet().addTypes(rhs.typeSet());
		rhs.typeSet().addTypes(lhs.typeSet());
	}

	private DNode ConstantToReference(DConstant node, TypeUnit tu) {
		Variable global = graph_.file().lookupGlobal(node.value());
		if (global == null)
			global = graph_.file().lookupVariable(node.pc(), node.value(), Scope.Static);
		if (global != null)
			return new DGlobal(global);

		if (tu != null && tu.isString())
			return new DString(graph_.file().stringFromData(node.value()));
		return null;
	}

	@Override
	public void visit(DConstant node) throws Exception {
		DNode replacement = null;
		if (node.typeSet().numTypes() == 1) {
			TypeUnit tu = node.typeSet().types(0);
			switch (tu.kind()) {
			case Cell: {
				switch (tu.type().type()) {
				case Bool:
					replacement = new DBoolean(node.value() != 0);
					break;
				case Character:
					replacement = new DCharacter((char) node.value());
					break;
				case Float: {
					// assert(BitConverter.IsLittleEndian);
					byte[] bits = BitConverter.GetBytes(node.value());
					ByteBuffer b = ByteBuffer.wrap(bits);
					float v = b.getFloat();
					// float v = BitConverter.ToSingle(bits, 0);
					replacement = new DFloat(v);
					break;
				}
				case Function: {
					// Don't try to find variables tagged as Function like
					// new Function:myfunc = FunctionReturningFunction();
					// Call_StartFunction(GetMyHandle(), myfunc);
					if (node.value() < 0)
						break;
					Public p = graph_.file().publics()[(int) (node.value() >> 1)];
					Function function = graph_.file().lookupFunction(p.address());
					replacement = new DFunction(p.address(), function);
					break;
				}
				default:
					return;
				}
				break;
			}

			case Array: {
				replacement = ConstantToReference(node, tu);
				break;
			}

			default:
				return;
			}
		}

		if (replacement == null && node.usedAsReference())
			replacement = ConstantToReference(node, null);
		if (replacement != null) {
			block_.nodes().insertAfter(node, replacement);
			node.replaceAllUsesWith(replacement);
		}
	}

	@Override
	public void visit(DDeclareLocal local) {
		if (local.value() != null && local.var() == null)
			local.value().addTypes(local.typeSet());
	}

	@Override
	public void visit(DLocalRef lref) {
		lref.addTypes(lref.local().typeSet());
	}

	@Override
	public void visit(DJump jump) {
	}

	@Override
	public void visit(DJumpCondition jcc) {
		if (jcc.getOperand(0).type() == NodeType.Binary) {
			DBinary binary = (DBinary) jcc.getOperand(0);
			propagateInputs(binary.lhs(), binary.rhs());
		}
	}

	private void visitSignature(DNode call, Signature signature) throws Exception {
		// This plugin was compiled without the .dbg.natives section, so there's no info
		// about native's arguments..
		if (signature.args() == null) {
			for (int i = 0; i < call.numOperands(); i++) {
				DNode arg = call.getOperand(i);
				visitArgument(call, arg, i);
			}
			return;
		}

		for (int i = 0; i < call.numOperands() && i < signature.args().length; i++) {
			DNode node = call.getOperand(i);
			Argument arg = i < signature.args().length ? signature.args()[i]
					: signature.args()[signature.args().length - 1];

			// Try to detect string literals if the file is lacking debug symbols.
			// AMXX doesn't have a String tag at all.
			if (arg.generated() || (arg.type() == VariableType.ArrayReference && arg.dimensions() != null
					&& arg.dimensions().length == 1 && arg.tag().name().equals("_"))) {
				if (node.type() == NodeType.Constant) {
					DConstant constNode = (DConstant) node;
					if (graph_.file().IsMaybeString(constNode.value())) {
						call.replaceOperand(i, new DString(graph_.file().stringFromData(constNode.value())));
						continue;
					}
				} else if (node.type() == NodeType.DeclareLocal) {
					DDeclareLocal localNode = (DDeclareLocal) node;
					if (localNode.value() != null && localNode.value().type() == NodeType.Constant) {
						DConstant constNode = (DConstant) localNode.value();
						if (constNode.value() > 0 && graph_.file().IsMaybeString(constNode.value())) {
							call.replaceOperand(i, new DString(graph_.file().stringFromData(constNode.value())));
							continue;
						}
					}
				}
			}

			// A reference to a constant. See if it's a global variable.
			// This catches cases of stock ClearHandle(&Handle:handle) called with a global
			// variable
			if (arg.type() == VariableType.Reference && node.type() == NodeType.DeclareLocal
					&& node.getOperand(0).type() == NodeType.Constant) {
				DDeclareLocal localNode = (DDeclareLocal) node;
				DConstant constNode = (DConstant) localNode.getOperand(0);
				Variable global = graph_.file().lookupGlobal(constNode.value());
				if (global == null)
					global = graph_.file().lookupVariable(localNode.pc(), constNode.value(), Scope.Static);
				if (global != null) {
					call.replaceOperand(i, new DGlobal(global));
					node = call.getOperand(i);
				}
			}

			TypeUnit tu = TypeUnit.FromArgument(arg);
			if (tu != null) {
				// Ignore invalid function references.
				// HookUserMessage defines a default posthook callback as
				// MsgPostHook:post=MsgPostHook:-1
				// We avoid such stupid invalid functags by not trying to find the corresponding
				// callback function
				// and just print the tagged constant value.
				if (tu.kind() == TypeUnit.Kind.Cell && tu.type().type() == CellType.Function
						&& node.type() == NodeType.DeclareLocal && node.getOperand(0).type() == NodeType.Constant
						&& ((DConstant) node.getOperand(0)).value() < 0) {
					tu = new TypeUnit(new PawnType(CellType.Tag, arg.tag()));
				}

				node.addType(tu);
			}
		}

		// Peek ahead for constants.
		if (signature.args().length > 0 &&
		// Is this a variadic native
				(signature.args()[signature.args().length - 1].type() == VariableType.Variadic
						// Or a call with more parameters passed than arguments defined?
						|| signature.args().length < call.numOperands())) {
			for (int i = signature.args().length - 1; i < call.numOperands(); i++) {
				DNode node = call.getOperand(i);
				visitArgument(call, node, i);
			}
		}
	}

	private void visitArgument(DNode call, DNode arg, int index) throws Exception {
		switch (arg.type()) {
		case DeclareLocal: {
			DDeclareLocal localNode = (DDeclareLocal) arg;
			if (localNode.value().type() == NodeType.Constant) {

				DConstant constNode = (DConstant) localNode.value();
				Variable global = graph_.file().lookupGlobal(constNode.value());
				if (global == null)
					global = graph_.file().lookupVariable(localNode.pc(), constNode.value(), Scope.Static);
				if (global != null) {
					// Don't print references to implicit state variables.
					if (!global.isStateVariable())
						call.replaceOperand(index, new DGlobal(global));
					return;
				}

				// Guess a string...
				if (graph_.file().IsMaybeString(constNode.value()))
					call.replaceOperand(index, new DString(graph_.file().stringFromData(constNode.value())));
			}

			if (localNode.var() == null)
				return;

			TypeUnit tu = TypeUnit.FromVariable(localNode.var());
			if (tu != null) {
				arg.addType(tu);
				return;
			}
			break;
		}
		case DeclareStatic: {
			DDeclareStatic staticNode = (DDeclareStatic) arg;
			if (staticNode.var() == null)
				return;

			TypeUnit tu = TypeUnit.FromVariable(staticNode.var());
			if (tu != null) {
				arg.addType(tu);
				return;
			}
			break;
		}
		case Constant: {
			DConstant constNode = (DConstant) arg;
			/*Variable global = graph_.file().lookupGlobal(constNode.value());
			if (global == null)
				global = graph_.file().lookupVariable(constNode.pc(), constNode.value(), Scope.Static);
			if (global != null) {
				call.replaceOperand(index, new DGlobal(global));
				return;
			}*/

			// Guess a string...
			if (graph_.file().IsMaybeString(constNode.value()))
				call.replaceOperand(index, new DString(graph_.file().stringFromData(constNode.value())));
			break;
		}
		default:
			break;
		}
	}

	public void visit(DCall call) throws Exception {
		visitSignature(call, call.function());
	}

	public void visit(DSysReq sysreq) throws Exception {
		visitSignature(sysreq, sysreq.nativeX());
	}

	public void visit(DBinary binary) {
		if (binary.spop() == SPOpcode.add && binary.usedAsReference())
			binary.lhs().setUsedAsReference();

		// Check for Float constants in a store like
		// new Float:bla = 1.0 * GetSomeProp();
		// new Float:bla = 1065353216 * GetSomeProp();
		if (binary.uses().size() != 1)
			return;

		DDeclareLocal local = null;
		if (binary.lhs().type() == NodeType.DeclareLocal)
			local = (DDeclareLocal) binary.lhs();
		else if (binary.rhs().type() == NodeType.DeclareLocal)
			local = (DDeclareLocal) binary.rhs();
		else
			return;

		if (local.value() != null && local.value().type() == NodeType.Constant) {
			DConstant con = (DConstant) local.value();
			if (con.value() < 1000000000)
				return;

			if (con.typeSet() != null && con.typeSet().numTypes() > 0)
				return;

			DNode use = binary.uses().getFirst().node();
			if (use.type() == NodeType.Store) {
				DStore store = (DStore) use;
				if (store.lhs().typeSet().numTypes() == 1) {
					TypeUnit unit = store.lhs().typeSet().types(0);
					if (unit.kind() == Kind.Reference && unit.inner().type().type() == CellType.Float) {
						// System.out.printf("%d is probably a float?%n", con.value());
						con.addType(new TypeUnit(new PawnType(CellType.Float)));
					}
				}
			}
		}
	}

	public void visit(DBoundsCheck check) {
	}

	public void visit(DArrayRef aref) {
		aref.abase().setUsedAsReference();
	}

	public void visit(DStore store) {
		store.getOperand(0).setUsedAsReference();
	}

	public void visit(DLoad load) throws Exception {
		load.from().setUsedAsReference();
		if (load.from().typeSet() != null && load.from().typeSet().numTypes() == 1) {
			TypeUnit tu = load.from().typeSet().types(0);
			if (tu.kind() == TypeUnit.Kind.Array) {
				if (load.from().type() == NodeType.ArrayRef) {
					DArrayRef arrayref = (DArrayRef) load.from();
					if (arrayref.abase().type() == NodeType.Global)
						return;
				}
				DConstant cv = new DConstant(0);
				DArrayRef aref = new DArrayRef(load.from(), cv, 1);
				block_.nodes().insertAfter(load.from(), cv);
				block_.nodes().insertAfter(cv, aref);
				load.replaceOperand(0, aref);
			}
		}
	}

	public void visit(DReturn ret) {
		if (graph_.function() != null) {
			DNode input = ret.getOperand(0);
			TypeUnit tu = TypeUnit.FromFunction(graph_.function());
			input.typeSet().addType(tu);
		}
	}

	public void visit(DGlobal global) {
	}

	public void visit(DString node) {
	}

	@Override
	public void visit(DGenArray genarray) throws Exception {
		for (int i = 0; i < genarray.numOperands(); i++) {
			genarray.getOperand(i).accept(this);
		}
	}
}
