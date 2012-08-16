package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DLocalRef extends DUnaryNode {
	public DLocalRef(DDeclareLocal local) throws Exception
    {
		super(local);
    }

    public DDeclareLocal local()
    {
        return (DDeclareLocal)getOperand(0);
    }
    
    @Override
    public NodeType type()
    {
        return NodeType.LocalRef;
    }
    
    @Override
    public void accept(NodeVisitor visitor)
    {
        visitor.visit(this);
    }
}
