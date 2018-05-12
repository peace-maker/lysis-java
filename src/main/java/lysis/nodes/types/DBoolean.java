package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DBoolean extends DNullaryNode {
	private boolean value_;

    public DBoolean(boolean value)
    {
        value_ = value;
    }

    public boolean value()
    {
        return value_;
    }
    
    @Override
    public NodeType type()
    {
        return NodeType.Boolean;
    }
    
    @Override
    public void accept(NodeVisitor visitor)
    {
        visitor.visit(this);
    }
}
