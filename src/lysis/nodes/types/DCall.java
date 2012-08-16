package lysis.nodes.types;

import lysis.lstructure.Function;
import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DCall extends DCallNode {
	private Function function_;

    public DCall(Function function, DNode[] arguments) throws Exception
    {
    	super(arguments);
        function_ = function;
    }

    public Function function()
    {
        return function_;
    }
    
    @Override
    public NodeType type()
    {
        return NodeType.Call;
    }
    
    @Override
    public void accept(NodeVisitor visitor) throws Exception
    {
        visitor.visit(this);
    }
}
