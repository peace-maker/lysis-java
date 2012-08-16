package lysis.nodes.types;

import lysis.lstructure.Function;
import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DFunction extends DNullaryNode {
	private Function function_;
    private long pc_;

    public DFunction(long pc, Function value)
    {
        pc_ = pc;
        function_ = value;
    }

    public long pc()
    {
        return pc_;
    }
    
    public Function function()
    {
        return function_;
    }
    
    @Override
    public NodeType type()
    {
        return NodeType.Function;
    }
    
    @Override
    public void accept(NodeVisitor visitor)
    {
        visitor.visit(this);
    }
}
