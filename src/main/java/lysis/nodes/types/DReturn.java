package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DReturn extends DUnaryNode {
	public DReturn(DNode value) throws Exception
    {
		super(value);
    }

	@Override
    public NodeType type()
    {
        return NodeType.Return;
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
}
