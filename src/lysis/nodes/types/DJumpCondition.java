package lysis.nodes.types;

import lysis.nodes.NodeBlock;
import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;
import lysis.sourcepawn.SPOpcode;

public class DJumpCondition extends DUnaryNode {
	private SPOpcode spop_;
    private NodeBlock trueTarget_;
    private NodeBlock falseTarget_;
    private NodeBlock joinTarget_;

    public DJumpCondition(SPOpcode spop, DNode node, NodeBlock lht, NodeBlock rht) throws Exception
    {
    	super(node);
        // Debug.Assert(getOperand(0) != null);
        spop_ = spop;
        trueTarget_ = lht;
        falseTarget_ = rht;
    }

    public void rewrite(SPOpcode spop, DNode node) throws Exception
    {
        spop_ = spop;
        replaceOperand(0, node);
    }

    public SPOpcode spop()
    {
        return spop_;
    }
    public NodeBlock trueTarget()
    {
        return trueTarget_;
    }
    public NodeBlock falseTarget()
    {
        return falseTarget_;
    }
    
    @Override
    public NodeType type()
    {
        return NodeType.JumpCondition;
    }
    
    @Override
    public void accept(NodeVisitor visitor)
    {
        visitor.visit(this);
    }
    
    @Override
    public boolean idempotent()
    {
        return false;
    }
    
    @Override
    public boolean controlFlow()
    {
        return true;
    }
    public NodeBlock joinTarget()
    {
        return joinTarget_;
    }
    public void setTrueTarget(NodeBlock block)
    {
        trueTarget_ = block;
    }
    public void setFalseTarget(NodeBlock block)
    {
        falseTarget_ = block;
    }
    public void setJoinTarget(NodeBlock block)
    {
        joinTarget_ = block;
    }
    public void setConditional(SPOpcode op)
    {
        spop_ = op;
    }
}
