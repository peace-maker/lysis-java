package lysis.nodes;

import lysis.nodes.types.DArrayRef;
import lysis.nodes.types.DBinary;
import lysis.nodes.types.DBoundsCheck;
import lysis.nodes.types.DCall;
import lysis.nodes.types.DConstant;
import lysis.nodes.types.DDeclareLocal;
import lysis.nodes.types.DFloat;
import lysis.nodes.types.DGlobal;
import lysis.nodes.types.DIncDec;
import lysis.nodes.types.DJump;
import lysis.nodes.types.DJumpCondition;
import lysis.nodes.types.DLoad;
import lysis.nodes.types.DLocalRef;
import lysis.nodes.types.DNode;
import lysis.nodes.types.DPhi;
import lysis.nodes.types.DReturn;
import lysis.nodes.types.DStore;
import lysis.nodes.types.DString;
import lysis.nodes.types.DSysReq;
import lysis.nodes.types.DTempName;
import lysis.nodes.types.DUnary;
import lysis.sourcepawn.SPOpcode;
import lysis.types.CellType;
import lysis.types.PawnType;
import lysis.types.TypeUnit;
import lysis.types.TypeUnit.Kind;

public class NodeRewriter extends NodeVisitor {
	private NodeGraph graph_;
    private NodeBlock current_;
    private NodeList.iterator iterator_;

    @Override
    public void visit(DConstant node)
    {
    }
    
    @Override
    public void visit(DDeclareLocal local)
    {
    }
    
    @Override
    public void visit(DLocalRef lref)
    {
    }
    
    @Override
    public void visit(DJump jump)
    {
    }

    @Override
    public void visit(DJumpCondition jcc)
    {
    }

    @Override
    public void visit(DSysReq sysreq) throws Exception
    {
    	if (sysreq.numOperands() != 2)
            return;

        SPOpcode spop;
        switch (sysreq.nativeX().name())
        {
            case "FloatAdd":
                spop = SPOpcode.add;
                break;
            case "FloatSub":
                spop = SPOpcode.sub;
                break;
            case "FloatMul":
                spop = SPOpcode.smul;
                break;
            case "FloatDiv":
                spop = SPOpcode.sdiv_alt;
                break;
            default:
                return;
        }
        
        DNode lhs, rhs;
        
        // For commutative operations, try to avoid having a constant on the lhs.
        // This helps to coalesce to += and *=
        if((spop == SPOpcode.add || spop == SPOpcode.smul)
        && sysreq.getOperand(0).type() == NodeType.DeclareLocal)
        {
        	lhs = sysreq.getOperand(1);
        	rhs = sysreq.getOperand(0);
        }
        else
        {
        	lhs = sysreq.getOperand(0);
        	rhs = sysreq.getOperand(1);
        }
        
        DBinary binary = new DBinary(spop, lhs, rhs);
        sysreq.getOperand(0).addType(new TypeUnit(new PawnType(CellType.Float)));
        sysreq.getOperand(1).addType(new TypeUnit(new PawnType(CellType.Float)));
        sysreq.replaceAllUsesWith(binary);
        sysreq.removeFromUseChains();
        current_.replace(iterator_, binary);
        return;
    }

    @Override
    public void visit(DBinary binary)
    {
    }

    @Override
    public void visit(DBoundsCheck check)
    {
    }
    
    @Override
    public void visit(DArrayRef aref)
    {
/*#if B
        DNode node = aref.getOperand(0);
        DNode replacement = node.applyType(graph_.file(), null, VariableType.ArrayReference);
        if (replacement != node)
        {
            node.block().replace(node, replacement);
            aref.replaceOperand(0, replacement);
        }
#endif*/
    }
    
    @Override
    public void visit(DStore store)
    {
    }
    
    @Override
    public void visit(DLoad load)
    {
    }
    
    @Override
    public void visit(DReturn ret)
    {
    }
    
    @Override
    public void visit(DGlobal global)
    {
    }
    
    @Override
    public void visit(DString node)
    {
    }

    @Override
    public void visit(DPhi phi) throws Exception
    {
        // Convert a phi into a move on each incoming edge. Declare the
        // temporary name in the dominator.
        NodeBlock idom = graph_.blocks(phi.block().lir().idom().id());

        DTempName name = new DTempName(graph_.tempName());
        idom.prepend(name);

        for (int i = 0; i < phi.numOperands(); i++)
        {
            DNode input = phi.getOperand(i);
            DStore store = new DStore(name, input);
            NodeBlock pred = graph_.blocks(phi.block().lir().getPredecessor(i).id());
            pred.prepend(store);
        }

        phi.replaceAllUsesWith(name);
    }

    @Override
    public void visit(DCall call) throws Exception
    {
        // Operators can be overloaded for floats, and we want these to print
        // normally, so here is some gross peephole stuff. Maybe we should be
        // looking for bytecode patterns instead or something, but that would
        // need a whole-program analysis.
        if (call.function().name().length() < 8)
            return;
        if (!call.function().name().substring(0, 8).equals("operator"))
            return;

        String op = "";
        for (int i = 8; i < call.function().name().length(); i++)
        {
            if (call.function().name().charAt(i) == '(')
                break;
            op += call.function().name().charAt(i);
        }

        SPOpcode spop;
        if(call.numOperands() == 2)
        {
	        switch (op)
	        {
	            case ">":
	                spop = SPOpcode.sgrtr;
	                break;
	            case ">=":
	                spop = SPOpcode.sgeq;
	                break;
	            case "<":
	                spop = SPOpcode.sless;
	                break;
	            case "<=":
	                spop = SPOpcode.sleq;
	                break;
	            case "==":
	                spop = SPOpcode.eq;
	                break;
	            case "!=":
	                spop = SPOpcode.neq;
	                break;
	            case "+":
	                spop = SPOpcode.add;
	                break;
	            case "-":
	                spop = SPOpcode.sub;
	                break;
	            case "*":
	                spop = SPOpcode.smul;
	                break;
	            case "/":
	                spop = SPOpcode.sdiv_alt;
	                break;
	            default:
	                throw new Exception("unknown operator (" + op + ")");
	        }
        }
        else // if(call.numOperands() == 1)
        {
	        switch (op)
	        {
	            case "-":
	                spop = SPOpcode.neg;
	                break;
	            case "!":
	                spop = SPOpcode.not;
	                break;
	            case "++":
	            	spop = SPOpcode.inc;
	            	break;
	            case "--":
	            	spop = SPOpcode.dec;
	                break;
	            default:
	                throw new Exception("unknown operator (" + op + ")");
	        }
        }

        switch (spop)
        {
            case sgeq:
            case sleq:
            case sgrtr:
            case sless:
            case eq:
            case neq:
            case add:
            case sub:
            case smul:
            case sdiv_alt:
            {
                DBinary binary = new DBinary(spop, call.getOperand(0), call.getOperand(1));
                call.replaceAllUsesWith(binary);
                call.removeFromUseChains();
                current_.replace(iterator_, binary);
                break;
            }
            case inc:
            case dec:
            {
            	DBinary rep = new DBinary((spop == SPOpcode.inc?SPOpcode.add:SPOpcode.sub), call.getOperand(0), new DFloat(1.0f));
            	//DIncDec rep = new DIncDec(call.getOperand(0), (spop == SPOpcode.inc?1:-1));
                call.replaceAllUsesWith(rep);
                call.removeFromUseChains();
                current_.replace(iterator_, rep);
                break;
            }
            case neg:
            case not:
            {
                DUnary unary = new DUnary(spop, call.getOperand(0));
                call.replaceAllUsesWith(unary);
                call.removeFromUseChains();
                current_.replace(iterator_, unary);
                break;
            }
            default:
                throw new Exception("unknown spop");
        }
    }

    private void rewriteBlock(NodeBlock block) throws Exception
    {
        current_ = block;
        iterator_ = block.nodes().begin();
        while (iterator_.more())
        {
            // Iterate before accepting so we can replace the node.
            iterator_.node().accept(this);
            iterator_.next();
        }
    }

    public NodeRewriter(NodeGraph graph)
    {
        graph_ = graph;
    }

    public void rewrite() throws Exception
    {
        // We rewrite nodes in forward order so they are collapsed by the time we see their uses.
        for (int i = 0; i < graph_.numBlocks(); i++)
            rewriteBlock(graph_.blocks(i));
    }
}
