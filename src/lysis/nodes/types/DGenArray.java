package lysis.nodes.types;

import lysis.lstructure.Variable;
import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DGenArray extends DNode
{
	private long pc_;
	private Variable var_;
	private long offset_;
	private boolean autozero_;
	private DNode[] dims_;

	public DGenArray(long pc, DNode[] dims, boolean autozero) throws Exception
	{
		pc_ = pc;
		autozero_ = autozero;
		dims_ = new DNode[dims.length];
		for (int i = 0; i < dims.length; i++)
			initOperand(i, dims[i]);
	}

	public long pc()
	{
		return pc_;
	}

	public boolean autozero() {
		return autozero_;
	}

	public void setVariable(Variable var)
	{
		var_ = var;
	}

	public Variable var()
	{
		return var_;
	}

	public void setOffset(long offset)
	{
		offset_ = offset;
	}

	public long offset()
	{
		return offset_;
	}

	@Override
	public NodeType type()
	{
		return NodeType.GenArray;
	}

	@Override
	public void accept(NodeVisitor visitor) throws Exception
	{
		visitor.visit(this);
	}

	@Override
	public int numOperands() {
		return dims_.length;
	}

	@Override
	public DNode getOperand(int i) throws Exception {
		return dims_[i];
	}

	@Override
	protected void setOperand(int i, DNode node) throws Exception {
		dims_[i] = node;
	}
}
