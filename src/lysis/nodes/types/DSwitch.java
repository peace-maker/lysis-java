package lysis.nodes.types;

import lysis.instructions.LSwitch;
import lysis.instructions.SwitchCase;
import lysis.lstructure.LBlock;
import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DSwitch extends DUnaryNode {
	private LSwitch lir_;

    public DSwitch(DNode node, LSwitch lir) throws Exception
    {
    	super(node);
        lir_ = lir;
    }
    
    @Override
    public NodeType type()
    {
        return NodeType.Switch;
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
    public LBlock defaultCase()
    {
        return lir_.defaultCase();
    }
    public int numCases()
    {
        return lir_.numCases();
    }
    public SwitchCase getCase(int i)
    {
        return lir_.getCase(i);
    }
}
