package lysis.builder;

import java.io.IOException;
import java.io.PrintStream;

import lysis.PawnFile;
import lysis.builder.structure.BlockAnalysis;
import lysis.builder.structure.ControlBlock;
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
import lysis.nodes.types.DJumpCondition;
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
import lysis.types.CellType;
import lysis.types.PawnType;
import lysis.types.TypeUnit;

public class SourceBuilder {
	private PawnFile file_;
    private PrintStream out_;
    private String indent_;

    public SourceBuilder(PawnFile file, PrintStream tw)
    {
        file_ = file;
        out_ = tw;
        indent_ = "";
    }

    private void increaseIndent()
    {
        indent_ += "	";
    }

    private void decreaseIndent()
    {
        indent_ = indent_.substring(0, indent_.length() - 1);
    }

    private void outputLine(String text) throws IOException
    {
        out_.println(indent_ + text);
    }
    private void outputStart(String text) throws IOException
    {
        out_.print(indent_ + text);
    }

    static public String spop(SPOpcode op) throws Exception
    {
        switch (op)
        {
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
            case sdiv_alt:
                return "/";
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

    private String buildTag(PawnType type)
    {
        if (type.type() == CellType.Bool)
            return "bool:";
        if (type.type() == CellType.Float)
            return "Float:";
        if (type.type() == CellType.Tag)
            return buildTag(type.tag());
        return "";
    }

    private String buildTag(Tag tag)
    {
    	// TODO: why wouldn't one print "any"?
        if (tag.name().equals("_")/* || tag.name().equals("any")*/)
            return "";
        return tag.name() + ":";
    }

    private void writeSignature(NodeBlock entry) throws IOException
    {
        Function f = file_.lookupFunction(entry.lir().pc());
        if(f == null)
        	throw new IOException("Function not found.");

        if (file_.lookupPublic(entry.lir().pc()) != null)
            out_.print("public ");

        if (f != null)
        {
            out_.print(buildTag(f.returnType()) + f.name());
        }
        /*else
        {
            out_.writeBytes("function" + f.address());
        }*/

        out_.print("(");
        for (int i = 0; i < f.args().length; i++)
        {
            out_.print(buildArgDeclaration(f.args()[i]));
            if (i != f.args().length - 1)
                out_.print(", ");
        }

        out_.print(")\n");
    }

    private String buildConstant(DConstant node)
    {
        String prefix = "";
        if (node.typeSet().numTypes() == 1)
        {
            TypeUnit tu = node.typeSet().types(0);
            if (tu.kind() == TypeUnit.Kind.Cell && tu.type().type() == CellType.Tag)
            {
            	if(tu.type().tag() != null)
            		prefix = tu.type().tag().name() + ":";
            	else
            		prefix = "MissingTAG:";
            }
        }
        return prefix + node.value();
    }

    private String buildString(String str)
    {
        str = str.replace("\r", "\\r");
        str = str.replace("\n", "\\n");
        str = str.replace("\"", "\\\"");
        str = replaceChatColorCharacters(str);
        return "\"" + str + "\"";
    }

    private String buildLocalRef(DLocalRef lref)
    {
        return lref.local().var().name();
    }

    private String buildArrayRef(DArrayRef aref) throws Exception
    {
        String lhs = buildExpression(aref.getOperand(0));
        String rhs = buildExpression(aref.getOperand(1));
        return lhs + "[" + rhs + "]";
    }

    private String buildUnary(DUnary unary) throws Exception
    {
        String rhs = buildExpression(unary.getOperand(0));
        return spop(unary.spop()) + rhs;
    }

    private String buildBinary(DBinary binary) throws Exception
    {
        String lhs = buildExpression(binary.getOperand(0));
        String rhs = buildExpression(binary.getOperand(1));
        return lhs + " " + spop(binary.spop()) + " " + rhs;
    }

    private String buildLoadStoreRef(DNode node) throws Exception
    {
        switch (node.type())
        {
            case TempName:
            {
                DTempName temp = (DTempName)node;
                return temp.name();
            }

            case DeclareLocal:
            {
                DDeclareLocal local = (DDeclareLocal)node;
                return local.var().name();
            }

            case ArrayRef:
                return buildArrayRef((DArrayRef)node);

            case LocalRef:
            {
                DLocalRef lref = (DLocalRef)node;
                DDeclareLocal local = lref.local();
                if (local.var().type() == VariableType.ArrayReference || local.var().type() == VariableType.Array)
                    return local.var().name() + "[0]";
                if (local.var().type() == VariableType.Reference)
                    return local.var().name();
                throw new Exception("unknown local ref");
            }

            case Global:
            {
                DGlobal global = (DGlobal)node;
                if (global.var() == null)
                    return "__unk";
                return global.var().name();
            }

            case Load:
            {
                DLoad load = (DLoad)node;

                assert(load.from().type() == NodeType.DeclareLocal ||
                                load.from().type() == NodeType.ArrayRef ||
                                load.from().type() == NodeType.Global);
                return buildLoadStoreRef(load.from());
            }
            
            /*case Binary:
            {
            	return buildBinary((DBinary)node);
            }
            
            case Constant:
            {
            	return buildConstant((DConstant)node);
            }*/

            case GenArray:
            {
            	return ((DGenArray)node).var().name();
            }
            
            default:
                throw new Exception("unknown load " + node.type());
        }
    }

    private String buildLoad(DLoad load) throws Exception
    {
        return buildLoadStoreRef(load.getOperand(0));
    }

    private String buildSysReq(DSysReq sysreq) throws Exception
    {
        String args = "";
        for (int i = 0; i < sysreq.numOperands(); i++)
        {
            DNode input = sysreq.getOperand(i);
            String arg = buildExpression(input);
            args += arg;
            if (i != sysreq.numOperands() - 1)
                args += ", ";
        }

        return sysreq.nativeX().name() + "(" + args + ")";
    }

    private String buildCall(DCall call) throws Exception
    {
        String args = "";
        for (int i = 0; i < call.numOperands(); i++)
        {
            DNode input = call.getOperand(i);
            String arg = buildExpression(input);
            args += arg;
            if (i != call.numOperands() - 1)
                args += ", ";
        }

        return call.function().name() + "(" + args + ")";
    }

    private String buildInlineArray(DInlineArray ia)
    {
        assert(ia.typeSet().numTypes() == 1);
        TypeUnit tu = ia.typeSet().types(0);

        assert(tu.kind() == TypeUnit.Kind.Array);
        assert(tu.dims() == 1);

        if (tu.type().isString())
        {
            String s = file_.stringFromData(ia.address());
            return buildString(s);
        }

        String text = "{";
        for (int i = 0; i < ia.size() / 4; i++)
        {
            if (tu.type().type() == CellType.Float)
            {
                float f = file_.floatFromData(ia.address() + i * 4);
                text += f;
            }
            else
            {
                long v = file_.int32FromData(ia.address() + i * 4);
                text += buildTag(tu.type()) + v;
            }
            if (i != (ia.size() / 4) - 1)
                text += ",";
        }
        text += "}";
        return text;
    }

    private String buildBoolean(DBoolean node)
    {
        return node.value() ? "true" : "false";
    }

    private String buildFloat(DFloat node)
    {
        return Float.toString(node.value());
    }

    private String buildCharacter(DCharacter node)
    {
    	String str = new Character(node.value()).toString();
    	str = replaceChatColorCharacters(str);
        return "'" + str + "'";
    }

    private String buildFunction(DFunction node)
    {
        return node.function().name();
    }

    private String buildExpression(DNode node) throws Exception
    {
        switch (node.type())
        {
            case Constant:
                return buildConstant((DConstant)node);

            case Boolean:
                return buildBoolean((DBoolean)node);

            case Float:
                return buildFloat((DFloat)node);

            case Character:
                return buildCharacter((DCharacter)node);

            case Function:
                return buildFunction((DFunction)node);

            case Load:
                return buildLoad((DLoad)node);

            case String:
                return buildString(((DString)node).value());

            case LocalRef:
                return buildLocalRef((DLocalRef)node);

            case ArrayRef:
                return buildArrayRef((DArrayRef)node);

            case Unary:
                return buildUnary((DUnary)node);

            case Binary:
                return buildBinary((DBinary)node);

            case SysReq:
                return buildSysReq((DSysReq)node);

            case Call:
                return buildCall((DCall)node);

            case DeclareLocal:
            {
                DDeclareLocal local = (DDeclareLocal)node;
                return local.var().name();
            }

            case TempName:
            {
                DTempName name = (DTempName)node;
                return name.name();
            }

            case Global:
            {
                DGlobal global = (DGlobal)node;
                return global.var().name();
            }

            case InlineArray:
            {
                return buildInlineArray((DInlineArray)node);
            }
            
            case GenArray:
            {
            	return ((DGenArray)node).var().name();
            }

            default:
                throw new Exception("Can't print expression: " + node.type());
        }
    }

	private String buildArgDeclaration(Argument arg)
    {
        String prefix = arg.type() == VariableType.Reference
                        ? "&"
                        : "";
        String decl = prefix + buildTag(arg.tag()) + arg.name();
        if (arg.dimensions() != null)
        {
            for (int i = 0; i < arg.dimensions().length; i++)
            {
                Dimension dim = arg.dimensions()[i];
                decl += "[";
                if (dim.size() >= 1)
                {
                    if (arg.tag() != null && arg.tag().name().equals("String"))
                        decl += dim.size() * 4;
                    else
                        decl += dim.size();
                }
                decl += "]";
            }
        }
        return decl;
    }

    private String buildVarDeclaration(Variable var)
    {
        String prefix = var.type() == VariableType.Reference
                        ? "&"
                        : "";
        String decl = prefix + buildTag(var.tag()) + var.name();
        if (var.dims() != null)
        {
            for (int i = 0; i < var.dims().length; i++)
            {
                Dimension dim = var.dims()[i];
                decl += "[";
                if (dim.size() >= 1)
                {
                    if (var.tag() != null && var.tag().name().equals("String") && i == var.dims().length-1)
                        decl += dim.size() * 4;
                    else
                        decl += dim.size();
                }
                decl += "]";
            }
        }
        return decl;
    }

    private void writeLocal(DDeclareLocal local) throws Exception
    {
        // Don't declare arguments.
        if (local.offset() >= 0)
            return;

        String decl = buildVarDeclaration(local.var());

        if (local.value() == null)
        {
            outputLine("decl " + decl + ";");
            return;
        }

        if(local.value().type() == NodeType.Constant)
        {
        	DConstant con = (DConstant)local.value();
        	if(con.value() == 0)
        	{
        		outputLine("new " + decl + ";");
        		return;
        	}
        }
        
        String expr = buildExpression(local.value());
        outputLine("new " + decl + " = " + expr + ";");
    }
    
    private void writeGenArray(DGenArray array) throws Exception {
    	String prefix = (array.autozero()?"new ":"decl ");
    	String decl = prefix + array.var().name();
		for(int i=array.numOperands()-1;i>=0;i--)
		{
			decl += "[" + buildExpression(array.getOperand(i)) + "]";
		}
		outputLine(decl + ";");
	}

    private void writeStatic(DDeclareStatic decl) throws IOException
    {
        writeGlobal(decl.var());
    }

    private void writeSysReq(DSysReq sysreq) throws Exception
    {
        outputLine(buildSysReq(sysreq) + ";");
    }

    private void writeCall(DCall call) throws Exception
    {
        outputLine(buildCall(call) + ";");
    }

    private void writeStore(DStore store) throws Exception
    {
        String lhs = buildLoadStoreRef(store.getOperand(0));
        String rhs;
        if(store.logic() != null)
            rhs = buildLogicChain(store.logic());
        else
            rhs = buildExpression(store.getOperand(1));
        String eq = store.spop() == SPOpcode.nop
                    ? "="
                    : spop(store.spop()) + "=";
        outputLine(lhs + " " + eq + " " + rhs + ";");
    }

    private void writeReturn(ReturnBlock block) throws Exception
    {
        String operand;
        if(block.chain() != null) {
            operand = buildLogicChain(block.chain());
        }
        else {
            DReturn ret = (DReturn)block.source().nodes().last();
            operand = buildExpression(ret.getOperand(0));
        }
        outputLine("return " + operand + ";");
    }

    private void writeIncDec(DIncDec incdec) throws Exception
    {
        String lhs = buildLoadStoreRef(incdec.getOperand(0));
        String rhs = incdec.amount() == 1 ? "++" : "--";
        outputLine(lhs + rhs + ";");
    }

    private void writeTempName(DTempName name) throws Exception
    {
//    	if(name.next().type() == NodeType.JumpCondition && name.next() == name.block().nodes().last())
//    		return;
    	
        if (name.getOperand(0) != null)
            outputLine("new " + name.name() + " = " + buildExpression(name.getOperand(0)) + ";");
        else
            outputLine("new " + name.name() + ";");
    }

    private void writeStatement(DNode node) throws Exception
    {
        switch (node.type())
        {
            case DeclareLocal:
                writeLocal((DDeclareLocal)node);
                break;

            case DeclareStatic:
                writeStatic((DDeclareStatic)node);
                break;

            case Jump:
            case JumpCondition:
            case Return:
            case Switch:
                break;

            case SysReq:
                writeSysReq((DSysReq)node);
                break;

            case Call:
            {
                writeCall((DCall)node);
                break;
            }

            case Store:
                writeStore((DStore)node);
                break;

            case BoundsCheck:
                break;

            case TempName:
                writeTempName((DTempName)node);
                break;

            case IncDec:
                writeIncDec((DIncDec)node);
                break;
            
            case GenArray:
            	writeGenArray((DGenArray)node);
            	break;

            default:
                throw new Exception("unknown op (" + node.type() + ")");
        }
    }

	private String lgop(LogicOperator lop)
    {
        return lop == LogicOperator.And
                      ? "&&"
                      : "||";
    }

    private String buildLogicExpr(LogicChain.Node node) throws Exception
    {
        if (node.isSubChain())
        {
            String text = buildLogicChain(node.subChain());
            if (node.subChain().nodes().size() == 1)
                return text;
            return "(" + text + ")";
        }
        return buildExpression(node.expression());
    }

    private String buildLogicChain(LogicChain chain) throws Exception
    {
        String text = buildLogicExpr(chain.nodes().get(0));
        for (int i = 1; i < chain.nodes().size(); i++)
        {
            LogicChain.Node node = chain.nodes().get(i);
            text += " " + lgop(chain.op()) + " " + buildLogicExpr(node);
        }
        return text;
    }

    private void writeStatements(NodeBlock block) throws Exception
    {
        for (NodeList.iterator iter = block.nodes().begin(); iter.more(); iter.next())
            writeStatement(iter.node());
    }

    private void writeIf(IfBlock block) throws Exception
    {
    	writeStatements(block.source());
    	
        String cond;
        if (block.logic() == null)
        {
            DJumpCondition jcc = (DJumpCondition)block.source().nodes().last();

            if (block.invert())
            {
                if (jcc.getOperand(0).type() == NodeType.Unary &&
                    ((DUnary)jcc.getOperand(0)).spop() == SPOpcode.not)
                {
                    cond = buildExpression(jcc.getOperand(0).getOperand(0));
                }
                else if (jcc.getOperand(0).type() == NodeType.Load)
                {
                    cond = "!" + buildExpression(jcc.getOperand(0));
                }
                else
                {
                    cond = "!(" + buildExpression(jcc.getOperand(0)) + ")";
                }
            }
            else
            {
                cond = buildExpression(jcc.getOperand(0));
            }
        }
        else
        {
            cond = buildLogicChain(block.logic());
            assert(!block.invert());
        }

        outputLine("if (" + cond + ")");
        outputLine("{");
        // TODO empty if
        if(block.trueArm() != null)
        {
	        increaseIndent();
	        writeBlock(block.trueArm());
	        decreaseIndent();
        }
        if (block.falseArm() != null &&
            BlockAnalysis.GetEmptyTarget(block.falseArm().source()) == null)
        {
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

    private void writeWhileLoop(WhileLoop loop) throws Exception
    {
        String cond;
        if (loop.logic() == null)
        {
            writeStatements(loop.source());

            DJumpCondition jcc = (DJumpCondition)loop.source().nodes().last();
            cond = buildExpression(jcc.getOperand(0));
        }
        else
        {
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

    private void writeDoWhileLoop(WhileLoop loop) throws Exception
    {
        outputLine("do {");
        increaseIndent();
        if (loop.body() != null)
            writeBlock(loop.body());

        String cond;
        if (loop.logic() == null)
        {
            writeStatements(loop.source());
            decreaseIndent();

            DJumpCondition jcc = (DJumpCondition)loop.source().nodes().last();
            cond = buildExpression(jcc.getOperand(0));
        }
        else
        {
            decreaseIndent();
            cond = buildLogicChain(loop.logic());
        }

        outputLine("} while (" + cond + ");");
        if (loop.join() != null)
            writeBlock(loop.join());
    }

    private void writeSwitch(SwitchBlock switch_) throws Exception
    {
        writeStatements(switch_.source());

        DSwitch last = (DSwitch)switch_.source().nodes().last();
        String cond = buildExpression(last.getOperand(0));
        outputLine("switch (" + cond + ")");
        outputLine("{");
        increaseIndent();
        for (int i = 0; i < switch_.numCases(); i++)
        {
            SwitchBlock.Case cas = switch_.getCase(i);
            String values = "";
            for(int j = 0; j < cas.numValues(); j++)
            {
            	if(j > 0)
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
        //if(switch_.defaultCase().source().nodes().first().type() != NodeType.Jump) {
	        outputLine("default:");
                outputLine("{");
	        increaseIndent();
	        writeBlock(switch_.defaultCase());
	        decreaseIndent();
	        outputLine("}");
        //}

        decreaseIndent();
        outputLine("}");

        if (switch_.join() != null)
            writeBlock(switch_.join());
    }

    private void writeStatementBlock(StatementBlock block) throws Exception
    {
        writeStatements(block.source());
        if (block.next() != null)
            writeBlock(block.next());
    }

    private void writeBlock(ControlBlock block) throws Exception
    {
        switch (block.type())
        {
            case If:
                writeIf((IfBlock)block);
                break;
            case WhileLoop:
                writeWhileLoop((WhileLoop)block);
                break;
            case DoWhileLoop:
                writeDoWhileLoop((WhileLoop)block);
                break;
            case Statement:
                writeStatementBlock((StatementBlock)block);
                break;
            case Return:
                writeStatements(block.source());
                writeReturn((ReturnBlock)block);
                break;
            case Switch:
                writeSwitch((SwitchBlock)block);
                break;
            default:
                assert(false);
                break;
        }
    }

    private String replaceChatColorCharacters(String str)
    {
    	// Chat colors
		//  = 0x02 (STX) - Use team color up to the end of the player name.  This only works at the start of the string, and precludes using the other control characters.
		//  = 0x03 (ETX) - Use team color from this point forward
		//  = 0x04 (EOT) - Use location color from this point forward
		//  = 0x01 (SOH) - Use normal color from this point forward
        str = str.replace("\u0001", "\\x01"); // Default
        str = str.replace("\u0002", "\\x02"); // Teamcolor at start
        str = str.replace("\u0003", "\\x03"); // Teamcolor
        str = str.replace("\u0004", "\\x04"); // Green
        str = str.replace("\u0005", "\\x05"); // Olive
        str = str.replace("\u0007", "\\x07"); // followed by a hex code in RRGGBB format
        str = str.replace("\u0008", "\\x08"); // followed by a hex code with alpha in RRGGBBAA format
        return str;
    }
    
    private boolean isArrayEmpty(long address, int bytes)
    {
        for (long i = address + 0; i < address + bytes; i++)
        {
            if (file_.DAT().length > i && file_.DAT()[(int) i] != 0)
                return false;
        }
        return true;
    }

    private boolean isArrayEmpty(long address, int[] dims, int level)
    {
        if (level == dims.length - 1)
            return isArrayEmpty(address, dims[level] * 4);

        for (int i = 0; i < dims[level]; i++)
        {
        	long abase = address + i * 4;
            long inner = file_.int32FromData(abase);
            long finalX = abase + inner;
            if (!isArrayEmpty(finalX, dims, level + 1))
                return false;
        }

        return true;
    }

    private boolean isArrayEmpty(Variable var)
    {
        int[] dims = new int[var.dims().length];
        for (int i = 0; i < var.dims().length; i++)
            dims[i] = var.dims()[i].size();
        if (var.tag() != null && var.tag().name().equals("String"))
            dims[dims.length - 1] /= 4;
        return isArrayEmpty(var.address(), dims, 0);
    }

    private void dumpStringArray(long address, int size) throws IOException
    {
        for (int i = 0; i < size; i++)
        {
        	long abase = address + i * 4;
        	long inner = file_.int32FromData(abase);
            long finalX = abase + inner;
            String str = file_.stringFromData(finalX);
            String text = buildString(str);
            if (i != size - 1)
                text += ",";
            outputLine(text);
        }
    }

    private void dumpStringArray(Variable var, long address, int level) throws IOException
    {
        if (level == var.dims().length - 2)
        {
            dumpStringArray(address, var.dims()[level].size());
            return;
        }

        assert(false);

        for (int i = 0; i < var.dims()[level].size(); i++)
        {
        	long abase = address + i * 4;
        	long inner = file_.int32FromData(abase);
            long finalX = abase + inner;
            outputLine("{");
            increaseIndent();
            dumpStringArray(var, finalX, level + 1);
            decreaseIndent();
            if (i == var.dims()[level].size() - 1)
                outputLine("}");
            else
                outputLine("},");
        }
    }

    private void dumpEntireArray(long address, int size) throws IOException
    {
        String text = "";
        for (int i = 0; i < size; i++)
        {
        	long cell = file_.int32FromData(address + i * 4);
            text += cell;
            if (i != size - 1)
                text += ", ";
        }
        outputLine(text);
    }

    private void dumpArray(long address, int size) throws IOException
    {
    	long first = file_.int32FromData(address);
        for (int i = 1; i < size; i++)
        {
        	long cell = file_.int32FromData(address + i * 4);
            if (first != cell)
            {
                dumpEntireArray(address, size);
                return;
            }
        }
        outputLine(first + ", ...");
    }

    private void dumpArray(Variable var, long address, int level) throws IOException
    {
        if (level == var.dims().length - 1)
        {
            dumpArray(address, var.dims()[level].size());
            return;
        }

        //assert(false);

        for (int i = 0; i < var.dims()[level].size(); i++)
        {
        	long abase = address + i * 4;
        	long inner = file_.int32FromData(abase);
            long finalX = abase + inner;
            outputLine("{");
            increaseIndent();
            dumpArray(var, finalX, level + 1);
            decreaseIndent();
            if (i == var.dims()[level].size() - 1)
                outputLine("}");
            else
                outputLine("},");
        }
    }

    private void writeGlobal(Variable var) throws IOException
    {
        String decl = var.scope() == Scope.Global
                                   ? "new"
                                   : "static";
        if (var.tag() != null && var.tag().name().equals("Plugin"))
        {
        	long nameOffset = file_.int32FromData(var.address() + 0);
        	long descriptionOffset = file_.int32FromData(var.address() + 4);
        	long authorOffset = file_.int32FromData(var.address() + 8);
        	long versionOffset = file_.int32FromData(var.address() + 12);
        	long urlOffset = file_.int32FromData(var.address() + 16);
            String name = file_.stringFromData(nameOffset);
            String description = file_.stringFromData(descriptionOffset);
            String author = file_.stringFromData(authorOffset);
            String version = file_.stringFromData(versionOffset);
            String url = file_.stringFromData(urlOffset);

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
        }
        else if (var.name().startsWith("__ext_"))
        {
        	/*struct _ext
			{
				cell_t name;
				cell_t file;
				cell_t autoload;
				cell_t required;
			} *ext;*/
        	long nameOffset = file_.int32FromData(var.address() + 0);
        	long fileOffset = file_.int32FromData(var.address() + 4);
        	long autoload = file_.int32FromData(var.address() + 8);
        	long required = file_.int32FromData(var.address() + 12);
        	String name = file_.stringFromData(nameOffset);
            String file = file_.stringFromData(fileOffset);
            outputLine("public Extension:" + var.name() + " =");
            outputLine("{");
            increaseIndent();
            outputLine("name = " + buildString(name) + ",");
            outputLine("file = " + buildString(file) + ",");
            outputLine("autoload = " + autoload + ",");
            outputLine("required = " + required + ",");
            decreaseIndent();
            outputLine("};");
        }
        else if (var.name().startsWith("__pl_"))
        {
        	/*struct _pl
    		{
    			cell_t name;
    			cell_t file;
    			cell_t required;
    		} *pl;*/
        	long nameOffset = file_.int32FromData(var.address() + 0);
        	long fileOffset = file_.int32FromData(var.address() + 4);
        	long required = file_.int32FromData(var.address() + 8);
        	String name = file_.stringFromData(nameOffset);
            String file = file_.stringFromData(fileOffset);
            outputLine("public SharedPlugin:" + var.name() + " =");
            outputLine("{");
            increaseIndent();
            outputLine("name = " + buildString(name) + ",");
            outputLine("file = " + buildString(file) + ",");
            outputLine("required = " + required + ",");
            decreaseIndent();
            outputLine("};");
        }
        else if(var.tag().name().equals("PlVers"))
        {
        	/*struct PlVers
        	{
        		version,
        		String:filevers[],
        		String:date[],
        		String:time[]
        	};*/
        	long version = file_.int32FromData(var.address() + 0);
        	long fileversOffset = file_.int32FromData(var.address() + 4);
        	long dateOffset = file_.int32FromData(var.address() + 8);
        	long timeOffset = file_.int32FromData(var.address() + 12);
        	String filevers = file_.stringFromData(fileversOffset);
            String date = file_.stringFromData(dateOffset);
            String time = file_.stringFromData(timeOffset);
            outputLine("public PlVers:__version =");
            outputLine("{");
            increaseIndent();
            outputLine("version = " + version + ",");
            outputLine("filevers = " + buildString(filevers) + ",");
            outputLine("date = " + buildString(date) + ",");
            outputLine("time = " + buildString(time));
            decreaseIndent();
            outputLine("};");
        }
        else if (var.tag() != null && var.tag().name().equals("String"))
        {
            if (var.dims().length == 1)
            {
                String text = decl + " String:" + var.name() + "[" + var.dims()[0].size() * 4 + "]";
                String primer = file_.stringFromData(var.address());
                if (primer.length() > 0)
                    text += " = " + buildString(primer);
                outputLine(text + ";");
            }
            else
            {
                String text = decl + " " + buildTag(var.tag()) + var.name();
                if (var.dims() != null)
                {
                    for (int i = 0; i < var.dims().length; i++)
                    {
                    	// Display the correct number of bytes for the last dim of a string array
                    	if(i == (var.dims().length-1))
                    		text += "[" + var.dims()[i].size() * 4 + "]";
                    	else
                    		text += "[" + var.dims()[i].size() + "]";
                    }
                }
                if (isArrayEmpty(var))
                {
                    outputLine(text + ";");
                    return;
                }
                outputLine(text + " =");
                outputLine("{");
                increaseIndent();
                dumpStringArray(var, var.address(), 0);
                decreaseIndent();
                outputLine("};");
            }
        }
        else if (var.dims() == null || var.dims().length == 0)
        {
            String text = decl + " " + buildTag(var.tag()) + var.name();
           
            long value = file_.int32FromData(var.address());
            if (value != 0)
            {
                text += " = " + value;
            }
            outputLine(text + ";");
        }
        else if (isArrayEmpty(var))
        {
            String text = decl + " " + buildTag(var.tag()) + var.name();
            if (var.dims() != null)
            {
                for (int i = 0; i < var.dims().length; i++)
                    text += "[" + var.dims()[i].size() + "]";
            }
            outputLine(text + ";");
        }
        else
        {
            String text = decl + " " + buildTag(var.tag()) + var.name();
            if (var.dims() != null)
            {
                for (int i = 0; i < var.dims().length; i++)
                    text += "[" + var.dims()[i].size() + "]";
            }
            outputLine(text + " =");
            outputLine("{");
            increaseIndent();
            dumpArray(var, var.address(), 0);
            decreaseIndent();
            outputLine("};");
        }
    }

    public void writeGlobals() throws IOException
    {
        for (int i = 0; i < file_.globals().length; i++)
            writeGlobal(file_.globals()[i]);
    }

    public void write(ControlBlock root) throws Exception
    {
        writeSignature(root.source());
        outputLine("{");
        increaseIndent();
        writeBlock(root);
        decreaseIndent();
        outputLine("}");
    }
}
