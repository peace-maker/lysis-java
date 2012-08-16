package lysis.nodes.types;

import lysis.lstructure.Variable;
import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DDeclareStatic extends DNullaryNode {

	private Variable var_;

    public DDeclareStatic(Variable var)
    {
        var_ = var;
    }

    public Variable var()
    {
        return var_;
    }
    
    @Override
    public NodeType type()
    {
        return NodeType.DeclareStatic;
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

}
