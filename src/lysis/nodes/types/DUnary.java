package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;
import lysis.sourcepawn.SPOpcode;

public class DUnary extends DUnaryNode {
	private SPOpcode spop_;

    public DUnary(SPOpcode op, DNode node) throws Exception
    {
    	super(node);
        spop_ = op;
    }

    public SPOpcode spop()
    {
        return spop_;
    }
    
    @Override
    public NodeType type()
    {
        return NodeType.Unary;
    }
    
    @Override
    public void accept(NodeVisitor visitor)
    {
        visitor.visit(this);
    }
}
