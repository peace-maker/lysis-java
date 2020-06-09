package lysis.builder;

import java.io.IOException;
import java.io.PrintStream;

import lysis.PawnFile;
import lysis.PawnFile.Automation;
import lysis.Public;
import lysis.builder.structure.BlockAnalysis;
import lysis.builder.structure.ControlBlock;
import lysis.builder.structure.GotoBlock;
import lysis.builder.structure.IfBlock;
import lysis.builder.structure.LogicChain;
import lysis.builder.structure.LogicOperator;
import lysis.builder.structure.ReturnBlock;
import lysis.builder.structure.StatementBlock;
import lysis.builder.structure.SwitchBlock;
import lysis.builder.structure.WhileLoop;
import lysis.lstructure.Argument;
import lysis.lstructure.Dimension;
import lysis.lstructure.Function;
import lysis.lstructure.Scope;
import lysis.lstructure.Tag;
import lysis.lstructure.Variable;
import lysis.lstructure.VariableType;
import lysis.nodes.NodeBlock;
import lysis.nodes.NodeList;
import lysis.nodes.NodeType;
import lysis.nodes.types.DArrayRef;
import lysis.nodes.types.DBinary;
import lysis.nodes.types.DBoolean;
import lysis.nodes.types.DCall;
import lysis.nodes.types.DCharacter;
import lysis.nodes.types.DConstant;
import lysis.nodes.types.DDeclareLocal;
import lysis.nodes.types.DDeclareStatic;
import lysis.nodes.types.DFloat;
import lysis.nodes.types.DFunction;
import lysis.nodes.types.DGenArray;
import lysis.nodes.types.DGlobal;
import lysis.nodes.types.DIncDec;
import lysis.nodes.types.DInlineArray;
import lysis.nodes.types.DJump;
import lysis.nodes.types.DJumpCondition;
import lysis.nodes.types.DLabel;
import lysis.nodes.types.DLoad;
import lysis.nodes.types.DLocalRef;
import lysis.nodes.types.DNode;
import lysis.nodes.types.DReturn;
import lysis.nodes.types.DStore;
import lysis.nodes.types.DString;
import lysis.nodes.types.DSwitch;
import lysis.nodes.types.DSysReq;
import lysis.nodes.types.DTempName;
import lysis.nodes.types.DUnary;
import lysis.sourcepawn.SPOpcode;
import lysis.sourcepawn.SourcePawnFile;
import lysis.types.CellType;
import lysis.types.PawnType;
import lysis.types.TypeUnit;
import lysis.types.rtti.RttiType;
import lysis.types.rtti.TypeFlag;

public class SourceBuilder {
	private PawnFile file_;
	private PrintStream out_;
	private String indent_;

	public SourceBuilder(PawnFile file, PrintStream tw) {
		file_ = file;
		out_ = tw;
		indent_ = "";
	}

	private void increaseIndent() {
		indent_ += "	";
	}

	private void decreaseIndent() {
		indent_ = indent_.substring(0, indent_.length() - 1);
	}

	private void outputLine(String text) {
		out_.println(indent_ + text);
	}

	private String indentLine(String text) {
		return indent_ + text;
	}

	private String prepareOutputLine(String text) {
		return indent_ + text + System.lineSeparator();
	}

	static public String spop(SPOpcode op) throws Exception {
		switch (op) {
		case add:
			return "+";
		case sub:
		case sub_alt:
		case neg:
			return "-";
		case less:
		case sless:
		case jsless:
			return "<";
		case grtr:
		case sgrtr:
		case jsgrtr:
			return ">";
		case leq:
		case sleq:
		case jsleq:
			return "<=";
		case geq:
		case sgeq:
		case jsgeq:
			return ">=";
		case eq:
		case jeq:
		case jzer:
			return "==";
		case jnz:
		case jneq:
		case neq:
			return "!=";
		case and:
			return "&";
		case not:
			return "!";
		case or:
			return "|";
		case sdiv:
		case sdiv_alt:
			return "/";
		case sdiv_alt_mod:
			return "%";
		case smul:
			return "*";
		case shr:
			return ">>";
		case shl:
			return "<<";
		case invert:
			return "~";
		case xor:
			return "^";
		case sshr:
			return ">>>";

		default:
			throw new Exception("NYI");
		}
	}

	private String buildTag(PawnType type) {
		if (type.type() == CellType.Bool)
			return "bool:";
		if (type.type() == CellType.Float)
			return "Float:";
		if (type.type() == CellType.Tag)
			return buildType(type.tag());
		return "";
	}
	
	private String buildType(Variable var) {
		if (var.tag() == null && var.rttiType() == null)
			return "";
		
		String prefix = var.type() == VariableType.Reference ? "&" : "";
		if (var.tag() != null) {
			return prefix + buildType(var.tag());
		}
		
		return prefix + buildType(var.rttiType());
	}

	private String buildType(Argument arg) {
		if (arg.tag() == null && arg.rttiType() == null)
			return "";
		
		String prefix = arg.type() == VariableType.Reference ? "&" : "";
		if (arg.tag() != null) {
			return prefix + buildType(arg.tag());
		}
		
		return prefix + buildType(arg.rttiType());
	}
	
	private String buildType(Tag tag) {
		// TODO: why wouldn't one print "any"?
		if (tag == null || tag.name().equals("_")/* || tag.name().equals("any") */)
			return "";
		return tag.name() + ":";
	}
	
	private String buildType(RttiType type) {
		switch (type.getTypeFlag()) {
		case TypeFlag.Bool:
			return "bool:";
		case TypeFlag.Int32:
			return "";
		case TypeFlag.Float32:
			return "Float:";
		case TypeFlag.Char8:
			return "String:";
		case TypeFlag.Any:
			return "any:";
		case TypeFlag.TopFunction:
			return "Function:";
		case TypeFlag.Void:
			return "void:";
		case TypeFlag.FixedArray:
		case TypeFlag.Array:
			return buildType(type.getArrayBaseType());
		case TypeFlag.Enum:
			// FIXME: Hack to access rtti info
			SourcePawnFile spf = (SourcePawnFile)file_;
			return spf.getEnumName((int) type.getData()) + ":";
		case TypeFlag.Typedef:
			return "<typedef " + type.getData() + ">:";
		case TypeFlag.Typeset:
			return "<typeset " + type.getData() + ">:";
		case TypeFlag.Classdef:
			return "<classdef " + type.getData() + ">:";
		case TypeFlag.EnumStruct:
			return "<enumstruct" + type.getData() + ">:";
		case TypeFlag.Function:
			// Only print the return type.
			return buildType(type.getInnerType());
		}
		return "";
	}
	
	// Build return type string
	private String buildType(Function func) {
		if (func.returnType() != null)
			return buildType(func.returnType());
		return buildType(func.returnTag());
	}

	private void writeSignature(NodeBlock entry) throws IOException {
		Function f = file_.lookupFunction(entry.lir().pc());
		if (f == null)
			throw new IOException("Function not found.");

		Public pub = file_.lookupPublic(entry.lir().pc());
		// All functions are in the .publics table now, so they can be used as
		// callbacks.
		// Functions without the "public" keyword are prefixed with their address like
		// ".addr.FuncName"
		if (pub != null && !pub.name().matches("\\.\\d+\\..+"))
			out_.print("public ");

		out_.print(buildType(f) + f.name());

		out_.print("(");
		if (f.args() != null) {
			for (int i = 0; i < f.args().length; i++) {
				out_.print(buildArgDeclaration(f.args()[i]));
				if (i != f.args().length - 1)
					out_.print(", ");
			}
		}

		out_.print(")");

		// Print the state and automation this blob belongs to.
		out_.println(buildStateSignature(f));
	}

	private String buildStateSignature(Function func) {
		if (func.stateAddr() == -1)
			return "";

		// See if we have debug info about this automation.
		Automation automation = file_.lookupAutomation(func.stateAddr());
		if (automation == null)
			return String.format("<%x:%d>", func.stateAddr(), func.stateId());

		String ret = " <";
		if (automation.automation_id() > 0)
			ret += automation.name() + ":";

		// Try to lookup the name of the state for non-default states.
		if (func.stateId() != -1) {
			String stateName = file_.lookupState(func.stateId(), automation.automation_id());
			if (stateName != null)
				ret += stateName;
			else
				ret += func.stateId();
		}

		ret += ">";
		return ret;
	}

	private String buildConstant(DConstant node) {
		String prefix = "";
		if (node.typeSet().numTypes() == 1) {
			TypeUnit tu = node.typeSet().types(0);
			if (tu.kind() == TypeUnit.Kind.Cell && tu.type().type() == CellType.Tag) {
				if (tu.type().tag() != null)
					prefix = tu.type().tag().name() + ":";
				else
					prefix = "MissingTAG:";
			}
		}
		return prefix + node.value();
	}

	private String buildString(String str) {
		str = str.replace("\r", "\\r");
		str = str.replace("\n", "\\n");
		str = str.replace("\"", "\\\"");
		str = replaceChatColorCharacters(str);
		return "\"" + str + "\"";
	}

	private String buildLocalRef(DLocalRef lref) {
		if (lref.getOperand(0) instanceof DTempName)
			return ((DTempName) lref.getOperand(0)).name();
		if (lref.local() == null)
			return "_NULLVAR_";
		return lref.local().var().name();
	}

	private String buildArrayRef(DArrayRef aref) throws Exception {
		String lhs = buildExpression(aref.getOperand(0));
		String rhs = buildExpression(aref.getOperand(1));
		return lhs + "[" + rhs + "]";
	}

	private String buildUnary(DUnary unary) throws Exception {
		String rhs = buildExpression(unary.getOperand(0));
		return spop(unary.spop()) + rhs;
	}

	private String buildBinary(DBinary binary) throws Exception {
		String lhs = buildExpression(binary.getOperand(0));
		String rhs = buildExpression(binary.getOperand(1));
		return lhs + " " + spop(binary.spop()) + " " + rhs;
	}

	private String buildLoadStoreRef(DNode node) throws Exception {
		if (node == null)
			return "unk__";
		switch (node.type()) {
		case TempName: {
			DTempName temp = (DTempName) node;
			return temp.name();
		}

		case DeclareLocal: {
			DDeclareLocal local = (DDeclareLocal) node;
			return local.var().name();
		}

		case ArrayRef:
			return buildArrayRef((DArrayRef) node);

		case LocalRef: {
			DLocalRef lref = (DLocalRef) node;
			DDeclareLocal local = lref.local();
			if (local.var().type() == VariableType.ArrayReference || local.var().type() == VariableType.Array)
				return local.var().name() + "[0]";
			if (local.var().type() == VariableType.Reference)
				return local.var().name();
			throw new Exception("unknown local ref");
		}

		case Global: {
			DGlobal global = (DGlobal) node;
			if (global.var() == null)
				return "__unk";
			return global.var().name();
		}

		case Load: {
			DLoad load = (DLoad) node;

			assert (load.from().type() == NodeType.DeclareLocal || load.from().type() == NodeType.ArrayRef
					|| load.from().type() == NodeType.Global);
			return buildLoadStoreRef(load.from());
		}

		case Binary: {
			return buildBinary((DBinary) node) + "/* ERROR unknown load Binary */";
		}

		case Constant: {
			return buildConstant((DConstant) node) + "/* ERROR unknown load Constant */";
		}

		case GenArray: {
			return ((DGenArray) node).var().name();
		}
		
		case Call: {
			return buildCall((DCall) node) + "/* ERROR unknown load Call */";
		}
		
		case Unary: {
			return buildUnary((DUnary) node) + "/* ERROR unknown load Unary */";
		}

		default:
			throw new Exception("unknown load " + node.type());
		}
	}

	private String buildLoad(DLoad load) throws Exception {
		return buildLoadStoreRef(load.getOperand(0));
	}

	private String buildSysReq(DSysReq sysreq) throws Exception {
		String args = "";
		for (int i = 0; i < sysreq.numOperands(); i++) {
			DNode input = sysreq.getOperand(i);
			String arg = buildExpression(input);
			args += arg;
			if (i != sysreq.numOperands() - 1)
				args += ", ";
		}

		return sysreq.nativeX().name() + "(" + args + ")";
	}

	private String buildCall(DCall call) throws Exception {
		String args = "";
		for (int i = 0; i < call.numOperands(); i++) {
			DNode input = call.getOperand(i);
			String arg = buildExpression(input);
			args += arg;
			if (i != call.numOperands() - 1)
				args += ", ";
		}

		return call.function().name() + "(" + args + ")";
	}

	private String buildStateChange(DStore store) throws Exception {
		if (store.getOperand(0).type() != NodeType.Global)
			return null;

		DGlobal glob = (DGlobal) store.getOperand(0);
		if (!glob.var().isStateVariable())
			return null;

		assert (store.getOperand(1).type() == NodeType.Constant);
		DConstant state = (DConstant) store.getOperand(1);

		Automation automation = file_.lookupAutomation(glob.var().address());
		// No debug info for this stuff.
		if (automation == null)
			return "state " + state.value();

		String expr = "state ";
		if (automation.automation_id() > 0)
			expr += automation.name() + ":";

		String stateName = file_.lookupState((short) state.value(), automation.automation_id());
		if (stateName != null)
			expr += stateName;
		else
			expr += state.value();

		return expr;
	}

	private String buildStore(DStore store) throws Exception {
		// See if this is a state change in an automation (AMXX only)
		String stateChange = buildStateChange(store);
		if (stateChange != null)
			return stateChange;

		String lhs = buildLoadStoreRef(store.getOperand(0));
		String rhs;
		if (store.logic() != null)
			rhs = buildLogicChain(store.logic());
		else
			rhs = buildExpression(store.getOperand(1));
		String eq = store.spop() == SPOpcode.nop ? "=" : spop(store.spop()) + "=";
		return lhs + " " + eq + " " + rhs;
	}

	private String buildInlineArray(DInlineArray ia, TypeUnit tu, DNode use) {
		Variable var = null;
		assert (use.type() == NodeType.DeclareLocal || use.type() == NodeType.DeclareStatic);
		if (use.type() == NodeType.DeclareLocal)
			var = ((DDeclareLocal) use).var();
		else if (use.type() == NodeType.DeclareStatic)
			var = ((DDeclareStatic) use).var();

		// No debug info, can't print the array.
		if (var == null)
			return null;

		assert (var.dims().length == tu.dims());

		String text = "{" + System.lineSeparator();
		increaseIndent();
		if (tu.isString())
			text += dumpStringArray(var, ia.address(), 0);
		else
			text += dumpArray(var, ia.address(), 0);
		decreaseIndent();
		text += indentLine("}");
		return text;
	}

	private String buildInlineArray(DInlineArray ia) {
		TypeUnit tu;
		// If we don't have type information, just assume a one-dimensional integer
		// array.
		// AMXX natives don't have debug information attached, so still print something
		// in native calls with default arguments.
		if (ia.typeSet().numTypes() == 0) {
			tu = new TypeUnit(new PawnType(CellType.None), 1);
		} else {
			assert (ia.typeSet().numTypes() == 1);
			tu = ia.typeSet().types(0);
		}

		assert (tu.kind() == TypeUnit.Kind.Array);

		if (tu.dims() > 1 && ia.uses().size() > 0) {
			assert (ia.uses().size() == 1);
			DNode use = ia.uses().get(0).node();
			String text = buildInlineArray(ia, tu, use);
			if (text != null)
				return text;
		}

		assert (tu.dims() == 1);

		if (tu.isString()) {
			String s = file_.stringFromData(ia.address(), (int) ia.size() - 1);
			return buildString(s);
		}

		String text = "{";
		for (int i = 0; i < ia.size() / 4; i++) {
			if (tu.type().type() == CellType.Float) {
				float f = file_.floatFromData(ia.address() + i * 4);
				text += f;
			} else {
				long v = file_.int32FromData(ia.address() + i * 4);
				text += buildTag(tu.type()) + v;
			}
			if (i != (ia.size() / 4) - 1)
				text += ",";
		}
		text += "}";
		return text;
	}

	private String buildBoolean(DBoolean node) {
		return node.value() ? "true" : "false";
	}

	private String buildFloat(DFloat node) {
		return Float.toString(node.value());
	}

	private String buildCharacter(DCharacter node) {
		String str = new Character(node.value()).toString();
		str = replaceChatColorCharacters(str);
		return "'" + str + "'";
	}

	private String buildFunction(DFunction node) {
		return node.function().name();
	}

	private String buildExpression(DNode node) throws Exception {
		switch (node.type()) {
		case Constant:
			return buildConstant((DConstant) node);

		case Boolean:
			return buildBoolean((DBoolean) node);

		case Float:
			return buildFloat((DFloat) node);

		case Character:
			return buildCharacter((DCharacter) node);

		case Function:
			return buildFunction((DFunction) node);

		case Load:
			return buildLoad((DLoad) node);

		case String:
			return buildString(((DString) node).value());

		case LocalRef:
			return buildLocalRef((DLocalRef) node);

		case ArrayRef:
			return buildArrayRef((DArrayRef) node);

		case Unary:
			return buildUnary((DUnary) node);

		case Binary:
			return buildBinary((DBinary) node);

		case SysReq:
			return buildSysReq((DSysReq) node);

		case Call:
			return buildCall((DCall) node);

		case DeclareLocal: {
			DDeclareLocal local = (DDeclareLocal) node;
			return local.var().name();
		}

		case TempName: {
			DTempName name = (DTempName) node;
			return name.name();
		}

		case Global: {
			DGlobal global = (DGlobal) node;
			return global.var().name();
		}

		case InlineArray: {
			return buildInlineArray((DInlineArray) node);
		}

		case GenArray: {
			return ((DGenArray) node).var().name();
		}

		case Store: {
			return "(" + buildStore((DStore) node) + ")";
		}

		default:
			throw new Exception("Can't print expression: " + node.type());
		}
	}

	private String buildArgDeclaration(Argument arg) {
		String decl = buildType(arg) + arg.name();
		if (arg.dimensions() != null) {
			for (int i = 0; i < arg.dimensions().length; i++) {
				Dimension dim = arg.dimensions()[i];
				decl += "[";
				if (dim.size() >= 1) {
					if (arg.isString())
						decl += dim.size() * 4;
					else
						decl += dim.size();
				}
				decl += "]";
			}
		}
		return decl;
	}

	private String buildVarDeclaration(Variable var) {
		String decl = buildType(var) + var.name();
		if (var.dims() != null) {
			for (int i = 0; i < var.dims().length; i++) {
				Dimension dim = var.dims()[i];
				decl += "[";
				if (dim.size() >= 1) {
					if (var.isString() && i == var.dims().length - 1)
						decl += dim.size() * 4;
					else
						decl += dim.size();
				}
				decl += "]";
			}
		}
		return decl;
	}

	private void writeLocal(DDeclareLocal local) throws Exception {
		// Don't declare arguments.
		if (local.offset() >= 0)
			return;

		String decl = buildVarDeclaration(local.var());

		if (local.value() == null) {
			outputLine("decl " + decl + ";");
			return;
		}

		if (local.value().type() == NodeType.Constant) {
			DConstant con = (DConstant) local.value();
			if (con.value() == 0) {
				outputLine("new " + decl + ";");
				return;
			}
		}

		String expr = buildExpression(local.value());
		outputLine("new " + decl + " = " + expr + ";");
	}

	private void writeGenArray(DGenArray array) throws Exception {
		String prefix = (array.autozero() ? "new " : "decl ");
		String decl = prefix + array.var().name();
		for (int i = array.numOperands() - 1; i >= 0; i--) {
			decl += "[" + buildExpression(array.getOperand(i)) + "]";
		}
		outputLine(decl + ";");
	}

	private void writeStatic(DDeclareStatic decl) throws IOException {
		writeGlobal(decl.var());
	}

	private void writeSysReq(DSysReq sysreq) throws Exception {
		outputLine(buildSysReq(sysreq) + ";");
	}

	private void writeCall(DCall call) throws Exception {
		outputLine(buildCall(call) + ";");
	}

	private void writeStore(DStore store) throws Exception {
		outputLine(buildStore(store) + ";");
	}

	private void writeReturn(ReturnBlock block) throws Exception {
		String operand;
		if (block.chain() != null) {
			operand = buildLogicChain(block.chain());
		} else {
			DReturn ret = (DReturn) block.source().nodes().last();
			operand = buildExpression(ret.getOperand(0));
		}
		outputLine("return " + operand + ";");
	}

	private void writeIncDec(DIncDec incdec) throws Exception {
		String lhs = buildLoadStoreRef(incdec.getOperand(0));
		String rhs = incdec.amount() == 1 ? "++" : "--";
		outputLine(lhs + rhs + ";");
	}

	private void writeTempName(DTempName name) throws Exception {
		// if(name.next().type() == NodeType.JumpCondition && name.next() ==
		// name.block().nodes().last())
		// return;

		if (name.getOperand(0) != null)
			outputLine("new " + name.name() + " = " + buildExpression(name.getOperand(0)) + ";");
		else
			outputLine("new " + name.name() + ";");
	}

	private void writeStatement(DNode node) throws Exception {
		switch (node.type()) {
		case DeclareLocal:
			writeLocal((DDeclareLocal) node);
			break;

		case DeclareStatic:
			writeStatic((DDeclareStatic) node);
			break;

		case Jump:
		case JumpCondition:
		case Return:
		case Switch:
			break;

		case SysReq:
			writeSysReq((DSysReq) node);
			break;

		case Call: {
			writeCall((DCall) node);
			break;
		}

		case Store:
			writeStore((DStore) node);
			break;

		case BoundsCheck:
			break;

		case TempName:
			writeTempName((DTempName) node);
			break;

		case IncDec:
			writeIncDec((DIncDec) node);
			break;

		case GenArray:
			writeGenArray((DGenArray) node);
			break;

		case Label:
			writeLabel((DLabel) node);
			break;

		default:
			throw new Exception("unknown op (" + node.type() + ")");
		}
	}

	private String lgop(LogicOperator lop) {
		return lop == LogicOperator.And ? "&&" : "||";
	}

	private String buildLogicExpr(LogicChain.Node node) throws Exception {
		if (node.isSubChain()) {
			String text = buildLogicChain(node.subChain());
			if (node.subChain().nodes().size() == 1)
				return text;
			return "(" + text + ")";
		}
		return buildExpression(node.expression());
	}

	private String buildLogicChain(LogicChain chain) throws Exception {
		String text = buildLogicExpr(chain.nodes().get(0));
		for (int i = 1; i < chain.nodes().size(); i++) {
			LogicChain.Node node = chain.nodes().get(i);
			text += " " + lgop(chain.op()) + " " + buildLogicExpr(node);
		}
		return text;
	}

	private void writeStatements(NodeBlock block) throws Exception {
		for (NodeList.iterator iter = block.nodes().begin(); iter.more(); iter.next())
			writeStatement(iter.node());
	}

	private void writeIf(IfBlock block) throws Exception {
		writeStatements(block.source());

		String cond;
		if (block.logic() == null) {
			DJumpCondition jcc = (DJumpCondition) block.source().nodes().last();

			if (block.invert()) {
				if (jcc.getOperand(0).type() == NodeType.Unary && ((DUnary) jcc.getOperand(0)).spop() == SPOpcode.not) {
					cond = buildExpression(jcc.getOperand(0).getOperand(0));
				} else if (jcc.getOperand(0).type() == NodeType.Load) {
					cond = "!" + buildExpression(jcc.getOperand(0));
				} else {
					cond = "!(" + buildExpression(jcc.getOperand(0)) + ")";
				}
			} else {
				cond = buildExpression(jcc.getOperand(0));
			}
		} else {
			if (block.invert()) {
				cond = "!(" + buildLogicChain(block.logic()) + ")";
			} else {
				cond = buildLogicChain(block.logic());
			}
		}

		outputLine("if (" + cond + ")");
		outputLine("{");
		// TODO empty if
		if (block.trueArm() != null) {
			increaseIndent();
			writeBlock(block.trueArm());
			decreaseIndent();
		}
		if (block.falseArm() != null && BlockAnalysis.GetEmptyTarget(block.falseArm().source()) == null) {
			outputLine("}");
			outputLine("else");
			outputLine("{");
			increaseIndent();
			writeBlock(block.falseArm());
			decreaseIndent();
		}
		outputLine("}");
		if (block.join() != null)
			writeBlock(block.join());
	}

	private void writeWhileLoop(WhileLoop loop) throws Exception {
		String cond;
		if (loop.logic() == null) {
			writeStatements(loop.source());

			DNode jcc = loop.source().nodes().last();
			if (jcc.type() == NodeType.JumpCondition)
				cond = buildExpression(jcc.getOperand(0));
			else
				cond = "true";
		} else {
			cond = buildLogicChain(loop.logic());
		}

		outputLine("while (" + cond + ")");
		outputLine("{");
		increaseIndent();
		writeBlock(loop.body());
		decreaseIndent();
		outputLine("}");
		if (loop.join() != null)
			writeBlock(loop.join());
	}

	private void writeDoWhileLoop(WhileLoop loop) throws Exception {
		outputLine("do {");
		increaseIndent();
		if (loop.body() != null)
			writeBlock(loop.body());

		String cond;
		if (loop.logic() == null) {
			writeStatements(loop.source());
			decreaseIndent();

			DNode last = loop.source().nodes().last();
			if (last.type() == NodeType.JumpCondition) {
				DJumpCondition jcc = (DJumpCondition) last;
				cond = buildExpression(jcc.getOperand(0));
			} else {
				if (last.type() == NodeType.Jump) {
					DJump j = (DJump) last;
					writeStatements(j.target());
				}
				cond = "true";
			}
		} else {
			decreaseIndent();
			cond = buildLogicChain(loop.logic());
		}

		outputLine("} while (" + cond + ");");
		if (loop.join() != null)
			writeBlock(loop.join());
	}

	private void writeSwitch(SwitchBlock switch_) throws Exception {
		writeStatements(switch_.source());

		DSwitch last = (DSwitch) switch_.source().nodes().last();
		String cond = buildExpression(last.getOperand(0));
		outputLine("switch (" + cond + ")");
		outputLine("{");
		increaseIndent();
		for (int i = 0; i < switch_.numCases(); i++) {
			SwitchBlock.Case cas = switch_.getCase(i);
			String values = "";
			for (int j = 0; j < cas.numValues(); j++) {
				if (j > 0)
					values += ", ";
				values += cas.value(j);
			}
			outputLine("case " + values + ":");
			outputLine("{");
			increaseIndent();
			writeBlock(cas.target());
			decreaseIndent();
			outputLine("}");
		}
		// if(switch_.defaultCase().source().nodes().first().type() != NodeType.Jump) {
		outputLine("default:");
		outputLine("{");
		increaseIndent();
		writeBlock(switch_.defaultCase());
		decreaseIndent();
		outputLine("}");
		// }

		decreaseIndent();
		outputLine("}");

		if (switch_.join() != null)
			writeBlock(switch_.join());
	}

	private void writeLabel(DLabel label) {
		outputLine(label.label() + ":");
	}

	private void writeGoto(GotoBlock goto_) throws Exception {
		writeStatements(goto_.source());
		DLabel label = (DLabel) goto_.target().nodes().first();
		outputLine(String.format("goto %s;", label.label()));
	}

	private void writeStatementBlock(StatementBlock block) throws Exception {
		writeStatements(block.source());
		if (block.next() != null)
			writeBlock(block.next());
	}

	private void writeBlock(ControlBlock block) throws Exception {
		switch (block.type()) {
		case If:
			writeIf((IfBlock) block);
			break;
		case WhileLoop:
			writeWhileLoop((WhileLoop) block);
			break;
		case DoWhileLoop:
			writeDoWhileLoop((WhileLoop) block);
			break;
		case Statement:
			writeStatementBlock((StatementBlock) block);
			break;
		case Return:
			writeStatements(block.source());
			writeReturn((ReturnBlock) block);
			break;
		case Switch:
			writeSwitch((SwitchBlock) block);
			break;
		case Goto:
			writeGoto((GotoBlock) block);
			break;
		default:
			assert (false);
			break;
		}
	}

	private String replaceChatColorCharacters(String str) {
		// Chat colors
		//  = 0x02 (STX) - Use team color up to the end of the player name. This only
		// works at the start of the string, and precludes using the other control
		// characters.
		//  = 0x03 (ETX) - Use team color from this point forward
		//  = 0x04 (EOT) - Use location color from this point forward
		//  = 0x01 (SOH) - Use normal color from this point forward
		str = str.replace("\u0000", "\\x00");
		str = str.replace("\u0001", "\\x01"); // Default
		str = str.replace("\u0002", "\\x02"); // Teamcolor at start
		str = str.replace("\u0003", "\\x03"); // Teamcolor
		str = str.replace("\u0004", "\\x04"); // Green
		str = str.replace("\u0005", "\\x05"); // Olive
		str = str.replace("\u0006", "\\x06");
		str = str.replace("\u0007", "\\x07"); // followed by a hex code in RRGGBB format
		str = str.replace("\u0008", "\\x08"); // followed by a hex code with alpha in RRGGBBAA format
		str = str.replace("\u0009", "\\x09");
		str = str.replace("\n", "\\n");
		str = str.replace("\u000B", "\\x0B");
		str = str.replace("\u000C", "\\x0C");
		str = str.replace("\u000E", "\\x0E");
		str = str.replace("\u000F", "\\x0F");
		str = str.replace("\u0010", "\\x10");
		return str;
	}

	private boolean isArrayValid(long address, int[] dims, int level) {
		if (level == dims.length - 1)
			return file_.isValidDataAddress(address);

		for (int i = 0; i < dims[level]; i++) {
			long abase = address + i * 4;
			long inner = file_.int32FromData(abase);
			long finalX = abase + inner;
			if (!isArrayValid(finalX, dims, level + 1))
				return false;
		}

		return true;
	}

	private boolean isArrayEmpty(long address, int bytes) {
		for (long i = address + 0; i < address + bytes; i++) {
			if (file_.DAT().length > i && file_.DAT()[(int) i] != 0)
				return false;
		}
		return true;
	}

	private boolean isArrayEmpty(long address, int[] dims, int level) {
		if (level == dims.length - 1)
			return isArrayEmpty(address, dims[level] * 4);

		for (int i = 0; i < dims[level]; i++) {
			long abase = address + i * 4;
			long inner = file_.int32FromData(abase);
			if (inner == 0)
				return true;
			long finalX = abase + inner;
			if (!isArrayEmpty(finalX, dims, level + 1))
				return false;
		}

		return true;
	}

	private boolean isArrayEmpty(Variable var) {
		int[] dims = new int[var.dims().length];
		for (int i = 0; i < var.dims().length; i++)
			dims[i] = var.dims()[i].size();
		if (var.isString())
			dims[dims.length - 1] /= 4;

		// Don't try to print an array with invalid indirection vectors.
		if (!isArrayValid(var.address(), dims, 0))
			return true;

		// Initializing arrays like char arr[2][] = {"a", "b"};
		// has the last dimension undetermined, so just print
		// the strings as long as they are.
		if (var.dims().length > 0 && var.dims()[var.dims().length - 1].size() == 0)
			return false;

		return isArrayEmpty(var.address(), dims, 0);
	}

	private String dumpStringArray(long address, int size) {
		String text = "";
		for (int i = 0; i < size; i++) {
			long abase = address + i * 4;
			long inner = file_.int32FromData(abase);
			long finalX = abase + inner;
			String str = file_.stringFromData(finalX);
			String printStr = buildString(str);
			if (i != size - 1)
				printStr += ",";
			text += prepareOutputLine(printStr);
		}
		return text;
	}

	private String dumpStringArray(Variable var, long address, int level) {
		if (level == var.dims().length - 2) {
			return dumpStringArray(address, var.dims()[level].size());
		}

		// TODO: Revisit for codeversion 13 and feature DirectArrays
		// assert(false);

		String text = "";
		for (int i = 0; i < var.dims()[level].size(); i++) {
			long abase = address + i * 4;
			long inner = file_.int32FromData(abase);
			long finalX = abase + inner;
			text += prepareOutputLine("{");
			increaseIndent();
			text += dumpStringArray(var, finalX, level + 1);
			decreaseIndent();
			if (i == var.dims()[level].size() - 1)
				text += prepareOutputLine("}");
			else
				text += prepareOutputLine("},");
		}
		return text;
	}

	private String dumpEntireArray(long address, int size) {
		String text = "";
		for (int i = 0; i < size; i++) {
			long cell = file_.int32FromData(address + i * 4);
			text += cell;
			if (i != size - 1)
				text += ", ";
		}
		return prepareOutputLine(text);
	}

	private String dumpArray(long address, int size) {
		long first = file_.int32FromData(address);
		for (int i = 1; i < size; i++) {
			long cell = file_.int32FromData(address + i * 4);
			if (first != cell) {
				return dumpEntireArray(address, size);
			}
		}
		return prepareOutputLine(first + ", ...");
	}

	private String dumpArray(Variable var, long address, int level) {
		if (level == var.dims().length - 1) {
			return dumpArray(address, var.dims()[level].size());
		}

		// assert(false);

		String text = "";
		for (int i = 0; i < var.dims()[level].size(); i++) {
			long abase = address + i * 4;
			long inner = file_.int32FromData(abase);
			long finalX = abase + inner;
			text += prepareOutputLine("{");
			increaseIndent();
			text += dumpArray(var, finalX, level + 1);
			decreaseIndent();
			if (i == var.dims()[level].size() - 1)
				text += prepareOutputLine("}");
			else
				text += prepareOutputLine("},");
		}
		return text;
	}

	private void writeGlobal(Variable var) throws IOException {
		String decl = var.scope() == Scope.Global ? "new" : "static";
		if (var.name().equals("myinfo")) {
			int nameOffset = file_.int32FromData(var.address() + 0);
			int descriptionOffset = file_.int32FromData(var.address() + 4);
			int authorOffset = file_.int32FromData(var.address() + 8);
			int versionOffset = file_.int32FromData(var.address() + 12);
			int urlOffset = file_.int32FromData(var.address() + 16);
			String name = file_.isValidDataAddress(nameOffset) ? file_.stringFromData(nameOffset) : "[INVALID_STRING]";
			String description = file_.isValidDataAddress(descriptionOffset) ? file_.stringFromData(descriptionOffset)
					: "[INVALID_STRING]";
			String author = file_.isValidDataAddress(authorOffset) ? file_.stringFromData(authorOffset)
					: "[INVALID_STRING]";
			String version = file_.isValidDataAddress(versionOffset) ? file_.stringFromData(versionOffset)
					: "[INVALID_STRING]";
			String url = file_.isValidDataAddress(urlOffset) ? file_.stringFromData(urlOffset) : "[INVALID_STRING]";

			outputLine("public Plugin:myinfo =");
			outputLine("{");
			increaseIndent();
			outputLine("name = " + buildString(name) + ",");
			outputLine("description = " + buildString(description) + ",");
			outputLine("author = " + buildString(author) + ",");
			outputLine("version = " + buildString(version) + ",");
			outputLine("url = " + buildString(url));
			decreaseIndent();
			outputLine("};");
		} else if (var.name().startsWith("__ext_")) {
			/*
			 * struct _ext { cell_t name; cell_t file; cell_t autoload; cell_t required; }
			 * *ext;
			 */
			int nameOffset = file_.int32FromData(var.address() + 0);
			int fileOffset = file_.int32FromData(var.address() + 4);
			int autoload = file_.int32FromData(var.address() + 8);
			int required = file_.int32FromData(var.address() + 12);
			String name = file_.isValidDataAddress(nameOffset) ? file_.stringFromData(nameOffset) : "[INVALID_STRING]";
			String file = file_.isValidDataAddress(fileOffset) ? file_.stringFromData(fileOffset) : "[INVALID_STRING]";
			outputLine("public Extension:" + var.name() + " =");
			outputLine("{");
			increaseIndent();
			outputLine("name = " + buildString(name) + ",");
			outputLine("file = " + buildString(file) + ",");
			outputLine("autoload = " + autoload + ",");
			outputLine("required = " + required + ",");
			decreaseIndent();
			outputLine("};");
		} else if (var.name().startsWith("__pl_")) {
			/*
			 * struct _pl { cell_t name; cell_t file; cell_t required; } *pl;
			 */
			int nameOffset = file_.int32FromData(var.address() + 0);
			int fileOffset = file_.int32FromData(var.address() + 4);
			int required = file_.int32FromData(var.address() + 8);
			String name = file_.isValidDataAddress(nameOffset) ? file_.stringFromData(nameOffset) : "[INVALID_STRING]";
			String file = file_.isValidDataAddress(fileOffset) ? file_.stringFromData(fileOffset) : "[INVALID_STRING]";
			outputLine("public SharedPlugin:" + var.name() + " =");
			outputLine("{");
			increaseIndent();
			outputLine("name = " + buildString(name) + ",");
			outputLine("file = " + buildString(file) + ",");
			outputLine("required = " + required + ",");
			decreaseIndent();
			outputLine("};");
		} else if (var.name().equals("__version")) {
			/*
			 * struct PlVers { version, String:filevers[], String:date[], String:time[] };
			 */
			int version = file_.int32FromData(var.address() + 0);
			int fileversOffset = file_.int32FromData(var.address() + 4);
			int dateOffset = file_.int32FromData(var.address() + 8);
			int timeOffset = file_.int32FromData(var.address() + 12);
			String filevers = file_.isValidDataAddress(fileversOffset) ? file_.stringFromData(fileversOffset)
					: "[INVALID_STRING]";
			String date = file_.isValidDataAddress(dateOffset) ? file_.stringFromData(dateOffset) : "[INVALID_STRING]";
			String time = file_.isValidDataAddress(timeOffset) ? file_.stringFromData(timeOffset) : "[INVALID_STRING]";
			outputLine("public PlVers:__version =");
			outputLine("{");
			increaseIndent();
			outputLine("version = " + version + ",");
			outputLine("filevers = " + buildString(filevers) + ",");
			outputLine("date = " + buildString(date) + ",");
			outputLine("time = " + buildString(time));
			decreaseIndent();
			outputLine("};");
		} else if (var.isString()) {
			if (var.dims().length == 1) {
				String text = decl + " String:" + var.name() + "[" + var.dims()[0].size() * 4 + "]";
				String primer = file_.stringFromData(var.address());
				if (primer.length() > 0)
					text += " = " + buildString(primer);
				outputLine(text + ";");
			} else {
				String text = decl + " " + buildType(var) + var.name();
				if (var.dims() != null) {
					for (int i = 0; i < var.dims().length; i++) {
						// Display the correct number of bytes for the last dim of a string array
						int size = var.dims()[i].size();
						if (i == (var.dims().length - 1))
							size *= 4;

						if (size == 0)
							text += "[]";
						else
							text += "[" + size + "]";
					}
				}
				if (isArrayEmpty(var)) {
					outputLine(text + ";");
					return;
				}
				outputLine(text + " =");
				outputLine("{");
				increaseIndent();
				out_.print(dumpStringArray(var, var.address(), 0));
				decreaseIndent();
				outputLine("};");
			}
		} else if (var.dims() == null || var.dims().length == 0) {
			String text = decl + " " + buildType(var) + var.name();

			long value = file_.int32FromData(var.address());
			if (value != 0) {
				text += " = " + value;
			}

			text += ";";

			// Add comment about this automation implementation detail,
			// since it's not visible in the original source code.
			if (var.isStateVariable())
				text += buildStateVarComment(var);

			outputLine(text);
		} else if (isArrayEmpty(var)) {
			String text = decl + " " + buildType(var) + var.name();
			if (var.dims() != null) {
				for (int i = 0; i < var.dims().length; i++)
					text += "[" + var.dims()[i].size() + "]";
			}
			outputLine(text + ";");
		} else {
			String text = decl + " " + buildType(var) + var.name();
			if (var.dims() != null) {
				for (int i = 0; i < var.dims().length; i++)
					text += "[" + var.dims()[i].size() + "]";
			}
			outputLine(text + " =");
			outputLine("{");
			increaseIndent();
			out_.print(dumpArray(var, var.address(), 0));
			decreaseIndent();
			outputLine("};");
		}
	}

	private String buildStateVarComment(Variable var) {
		Automation automation = file_.lookupAutomation(var.address());
		if (automation == null)
			return " // Internal state variable";

		String comment = " // Internal state variable for ";
		if (automation.automation_id() > 0)
			comment += "automation " + automation.name();
		else
			comment += "default automation";

		return comment;
	}

	public void writeGlobals() throws IOException {
		if (file_.globals() == null) {
			System.err.println("// File got no pubvars?");
			return;
		}
		for (int i = 0; i < file_.globals().length; i++)
			writeGlobal(file_.globals()[i]);
	}

	public void write(ControlBlock root) throws Exception {
		writeSignature(root.source());
		outputLine("{");
		increaseIndent();
		writeBlock(root);
		decreaseIndent();
		outputLine("}");
	}
}
