package lysis.nodes.types;

public abstract class DBinaryNode extends DNode {
	private DNode[] operands_ = new DNode[2];

    public DBinaryNode(DNode operand1, DNode operand2) throws Exception
    {
        initOperand(0, operand1);
        initOperand(1, operand2);
    }

    @Override
    public int numOperands()
    {
        return 2;
    }
    
    @Override
    public DNode getOperand(int i)
    {
        return operands_[i];
    }
    
    @Override
    protected void setOperand(int i, DNode node)
    {
        operands_[i] = node;
    }
    
    public DNode lhs()
    {
        return getOperand(0);
    }
    
    public DNode rhs()
    {
        return getOperand(1);
    }
}
