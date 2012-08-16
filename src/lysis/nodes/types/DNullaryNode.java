package lysis.nodes.types;

public abstract class DNullaryNode extends DNode {

	@Override
	public int numOperands()
    {
        return 0;
    }
	
	@Override
    public DNode getOperand(int i) throws Exception
    {
        throw new Exception("not reached");
    }
	
	@Override
    protected void setOperand(int i, DNode node) throws Exception
    {
        throw new Exception("not reached");
    }
}
