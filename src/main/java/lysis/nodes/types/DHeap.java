package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DHeap extends DNullaryNode {
	private long amount_;

    public DHeap(long amount)
    {
        amount_ = amount;
    }

    @Override
    public NodeType type()
    {
        return NodeType.Heap;
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
