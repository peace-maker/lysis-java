package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DLabel extends DNullaryNode {
	
	private long address_;
	
	public DLabel(long address)
	{
		address_ = address;
	}
	
	public String label()
	{
		return String.format("Label_%X", address_);
	}

    @Override
    public NodeType type()
    {
        return NodeType.Label;
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
}
