package lysis.nodes.types;

import lysis.nodes.NodeBlock;
import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DJump extends DNullaryNode {
	private NodeBlock target_;
    private boolean isBreak_;

    public DJump(NodeBlock target)
    {
        target_ = target;
    }

    public NodeBlock target()
    {
        return target_;
    }
    
    @Override
    public NodeType type()
    {
        return NodeType.Jump;
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
    
    public void setBreak()
    {
        isBreak_ = true;
    }
    
    public boolean isBreak()
    {
        return isBreak_;
    }
}
