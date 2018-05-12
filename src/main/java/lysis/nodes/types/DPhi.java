package lysis.nodes.types;

import java.util.LinkedList;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DPhi extends DNode {
	private LinkedList<DNode> inputs_ = new LinkedList<DNode>();

    public DPhi(DNode node) throws Exception
    {
        addInput(node);
    }

    public void addInput(DNode node) throws Exception
    {
        inputs_.add(null);
        initOperand(inputs_.size() - 1, node);
    }

    @Override
    public NodeType type()
    {
        return NodeType.Phi;
    }
    
    @Override
    public int numOperands()
    {
        return inputs_.size();
    }
    
    @Override
    public DNode getOperand(int i)
    {
        return inputs_.get(i);
    }
    
    @Override
    protected void setOperand(int i, DNode node)
    {
    	inputs_.set(i,  node);
    }
    
    @Override
    public void accept(NodeVisitor visitor) throws Exception
    {
        visitor.visit(this);
    }
}
