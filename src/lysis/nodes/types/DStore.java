package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;
import lysis.sourcepawn.SPOpcode;

public class DStore extends DBinaryNode {
	private SPOpcode spop_;

    public DStore(DNode addr, DNode value) throws Exception
    {
    	super(addr, value);
        assert(value != null);
        spop_ = SPOpcode.nop;
    }

    public void makeStoreOp(SPOpcode op)
    {
        spop_ = op;
    }

    @Override
    public NodeType type()
    {
        return NodeType.Store;
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
    public SPOpcode spop()
    {
        return spop_;
    }
}
