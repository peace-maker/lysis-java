package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DBoundsCheck extends DUnaryNode {
	public DBoundsCheck(DNode index) throws Exception
    {
		super(index);
    }

	@Override
    public NodeType type()
    {
        return NodeType.BoundsCheck;
    }
	
	@Override
    public void accept(NodeVisitor visitor)
    {
        visitor.visit(this);
    }
	
	@Override
    public boolean guard()
    {
        return true;
    }
}
