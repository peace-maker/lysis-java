package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DIncDec extends DUnaryNode {
	private long amount_;

    public DIncDec(DNode node, int amount) throws Exception
    {
    	super(node);
        amount_ = amount;
    }

    @Override
    public NodeType type()
    {
        return NodeType.IncDec;
    }
    
    @Override
    public boolean idempotent()
    {
        return false;
    }
    
    @Override
    public void accept(NodeVisitor visitor)
    {
        visitor.visit(this);
    }
    
    public long amount()
    {
        return amount_;
    }
}
