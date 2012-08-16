package lysis.nodes.types;

public abstract class DUnaryNode extends DNode {
	private DNode operand_;

    public DUnaryNode(DNode operand) throws Exception
    {
        initOperand(0, operand);
    }

    @Override
    public int numOperands()
    {
        return 1;
    }
    
    @Override
    public DNode getOperand(int i)
    {
        assert(i == 0);
        return operand_;
    }
    
    @Override
    protected void setOperand(int i, DNode node)
    {
        assert(i == 0);
        operand_ = node;
    }
}
