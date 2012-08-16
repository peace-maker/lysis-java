package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DArrayRef extends DBinaryNode {
	private long shift_;

    public DArrayRef(DNode bas, DNode index, long shift) throws Exception
    {
    	super(bas, index);
        shift_ = shift;
    }
    
    public DArrayRef(DNode bas, DNode index) throws Exception {
    	this(bas, index, 2);
    }

    @Override
    public NodeType type()
    {
        return NodeType.ArrayRef;
    }
    
    @Override
    public void accept(NodeVisitor visitor)
    {
        visitor.visit(this);
    }
    public DNode abase()
    {
        return getOperand(0);
    }
    public DNode index()
    {
        return getOperand(1);
    }
}
