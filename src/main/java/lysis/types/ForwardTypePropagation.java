package lysis.types;

import lysis.lstructure.Argument;
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
import lysis.nodes.types.DBoundsCheck;
import lysis.nodes.types.DCall;
import lysis.nodes.types.DConstant;
import lysis.nodes.types.DDeclareLocal;
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
import lysis.types.TypeUnit.Kind;

public class ForwardTypePropagation extends NodeVisitor {
	private NodeGraph graph_;
	private NodeBlock block_;

	public ForwardTypePropagation(NodeGraph graph) {
		graph_ = graph;
	}

	public void propagate() throws Exception {
		for (int i = 0; i < graph_.numBlocks(); i++) {
			block_ = graph_.blocks(i);
			for (NodeList.iterator iter = block_.nodes().begin(); iter.more(); iter.next())
				iter.node().accept(this);
		}
	}

	@Override
	public void visit(DConstant node) {
	}

	@Override
	public void visit(DDeclareLocal local) {
		Variable var = graph_.file().lookupVariable(local.pc(), local.offset());
		local.setVariable(var);

		if (var != null) {
			TypeUnit tu = TypeUnit.FromVariable(var);
			assert (tu != null);
			local.addType(new TypeUnit(tu));
			if (local.value() != null && local.value().type() == NodeType.Constant && var.isFloat()) {
				// Assign the raw non-array and non-reference type to the constant. 
				TypeUnit rawType = null;
				if (var.tag() != null)
					rawType = TypeUnit.FromTag(var.tag());
				if (var.rttiType() != null)
					rawType = TypeUnit.FromType(var.rttiType());
				local.value().addType(rawType);
			}
		}
	}

	@Override
	public void visit(DLocalRef lref) {
		TypeSet localTypes = lref.local().typeSet();
		lref.addTypes(localTypes);
	}

	@Override
	public void visit(DJump jump) {
	}

	@Override
	public void visit(DJumpCondition jcc) {
		jcc.typeSet().addType(new TypeUnit(new PawnType(CellType.Bool)));
	}

	private void visitSignature(DNode call, Signature signature) throws Exception {
		// This plugin was compiled without the .dbg.natives section, so there's no info
		// about native's arguments..
		if (signature.args() == null) {
			// assert(SourcePawnFile.debugUnpacked_);
			return;
		}
		// Alert: Nasty format specifier parsing to get some info about the params of
		// variadic argumented functions
		int formatIndex;
		if (call.type() == NodeType.SysReq) {
			// Need at least (String format, any:...) 2 arguments
			if (signature.args().length < 2)
				return;
			// The last one has to be variadic
			if (signature.args()[signature.args().length - 1].type() != VariableType.Variadic)
				return;
			// We just assume the one right before the variadic argument is the format
			// string.
			if (!signature.args()[signature.args().length - 2].isString())
				return;
			// Are there any variadic arguments passed to the native?
			if (call.numOperands() == (signature.args().length - 2))
				return;
			formatIndex = signature.args().length - 2;
		}
		// It's a NodeType.Call
		// There's no variadic argument known here..
		else {
			// No arguments or exactly the same amount passed as expected? Not a vararg.
			if (signature.args().length == 0 || call.numOperands() <= signature.args().length)
				return;
			// We just assume the one right before the variadic argument is the format
			// string.
			Argument formatArg = signature.args()[signature.args().length - 1];
			if (!formatArg.isString())
				return;
			formatIndex = signature.args().length - 1;
		}

		DNode formatNode = call.getOperand(formatIndex);
		// Make sure we're dealing with a constant string here
		if (formatNode.type() != NodeType.DeclareLocal || formatNode.getOperand(0).type() != NodeType.String)
			return;

		String formatString = ((DString) formatNode.getOperand(0)).value();
		// Remove any escaped %
		formatString = formatString.replace("%%", "");
		String[] parts = formatString.split("%");
		int argumentIndex = formatIndex + 1;
		for (int i = 1; i < parts.length && argumentIndex < call.numOperands(); i++) {
			switch (parts[i].charAt(0)) {
			case 'f': {
				DNode floatArg = call.getOperand(argumentIndex);
				// Don't add any info, if we already know what that node is.
				if (floatArg.typeSet().numTypes() != 0)
					break;
				floatArg.addType(new TypeUnit(new PawnType(CellType.Float)));
				break;
			}
			case 's':
			case 't':
			case 'T': {
				DNode stringArg = call.getOperand(argumentIndex);
				// %T translations have a client index after the phrase
				if (parts[i].charAt(0) == 'T') {
					argumentIndex++;
				}
				// Don't add any info, if we already know what that node is.
				if (stringArg.typeSet().numTypes() != 0)
					break;
				// No constants as strings
				if (stringArg.type() == NodeType.Heap)
					break;
				stringArg.addType(new TypeUnit(new PawnType(signature.args()[formatIndex].tag()), 1));
				break;
			}
			case 'c': {
				DNode charArg = call.getOperand(argumentIndex);
				// Don't add any info, if we already know what that node is.
				if (charArg.typeSet().numTypes() != 0)
					break;
				charArg.addType(new TypeUnit(new PawnType(CellType.Character)));
				break;
			}

			}
			argumentIndex++;
		}
	}

	@Override
	public void visit(DSysReq sysreq) throws Exception {
		visitSignature(sysreq, sysreq.nativeX());
	}

	@Override
	public void visit(DBinary binary) {
//		System.out.printf("Binary: %s (lhs: %s, rhs: %s)%n", binary, binary.lhs(), binary.rhs());
//		DNode checkForFloat = null;
//		if (binary.lhs().type() == NodeType.Load) {
//			DLoad load = (DLoad) binary.lhs();
//			System.out.printf("Loading some %s%n", load.from());
//			if (load.from().type() == NodeType.DeclareLocal) {
//				DDeclareLocal local = (DDeclareLocal) load.from();
//				System.out.printf("Declaring some %s%n", local.value());
//			}
//		}
//		if (binary.rhs().type() == NodeType.Load) {
//			DLoad load = (DLoad) binary.rhs();
//			System.out.printf("Loading some %s%n", load.from());
//			if (load.from().type() == NodeType.DeclareLocal) {
//				DDeclareLocal local = (DDeclareLocal) load.from();
//				System.out.printf("Declaring some %s%n", local.value());
//			}
//		}
//
//		if (binary.lhs().type() == NodeType.Float)
//			checkForFloat = binary.rhs();
//		else if (binary.rhs().type() == NodeType.Float)
//			checkForFloat = binary.lhs();
//		else
//			return;
//
//		System.out.println("BLA?");
//
//		if (checkForFloat.type() != NodeType.Constant)
//			return;
//
//		DConstant con = (DConstant) checkForFloat;
//
//		System.out.printf("%s (%d) might be a float?%n", checkForFloat, con.value());
	}

	@Override
	public void visit(DBoundsCheck check) {
		check.getOperand(0).setUsedAsArrayIndex();
	}

	@Override
	public void visit(DArrayRef aref) {
		DNode abase = aref.abase();
		TypeSet baseTypes = abase.typeSet();
		for (int i = 0; i < baseTypes.numTypes(); i++)
			aref.addType(baseTypes.types(i));
	}

	@Override
	public void visit(DStore store) {
		// Make sure a constant float is assigned the right type.
		// new Float:x;
		// x = 12.0; // 12.0 instead of 1094713344!
		if (store.getOperand(0).typeSet().numTypes() == 1 && store.getOperand(1).type() == NodeType.Constant) {
			TypeUnit tu = store.getOperand(0).typeSet().types(0);
			if (tu.kind() == Kind.Cell)
				store.getOperand(1).addType(new TypeUnit(new PawnType(tu.type().type())));
			else if (tu.kind() == Kind.Reference)
				store.getOperand(1).addType(new TypeUnit(new PawnType(tu.inner().type().type())));
		}
	}

	@Override
	public void visit(DLoad load) {
		TypeSet fromTypes = load.from().typeSet();
		for (int i = 0; i < fromTypes.numTypes(); i++) {
			TypeUnit tu = fromTypes.types(i);
			TypeUnit actual = tu.load();
			if (actual == null)
				actual = tu;
			load.addType(actual);
		}
	}

	@Override
	public void visit(DReturn ret) {
	}

	@Override
	public void visit(DGlobal global) {
		if (global.var() == null)
			return;

		TypeUnit tu = TypeUnit.FromVariable(global.var());
		global.addType(tu);
	}

	@Override
	public void visit(DString node) {
	}

	@Override
	public void visit(DCall call) throws Exception {
		visitSignature(call, call.function());
	}

	@Override
	public void visit(DGenArray genarray) throws Exception {
		Variable var = graph_.file().lookupVariable(genarray.pc(), genarray.offset());
		genarray.setVariable(var);

		for (int i = 0; i < genarray.numOperands(); i++) {
			genarray.getOperand(i).accept(this);
		}
		if (var != null) {
			TypeUnit tu = TypeUnit.FromVariable(var);
			assert (tu != null);
			genarray.addType(new TypeUnit(tu));
		}
	}
}
