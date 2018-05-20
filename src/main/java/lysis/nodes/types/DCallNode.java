package lysis.nodes.types;

public abstract class DCallNode extends DNode {
	private DNode[] arguments_;

	public DCallNode(DNode[] arguments) throws Exception {
		arguments_ = new DNode[arguments.length];
		for (int i = 0; i < arguments.length; i++)
			initOperand(i, arguments[i]);
	}

	@Override
	public int numOperands() {
		return arguments_.length;
	}

	@Override
	public DNode getOperand(int i) {
		return arguments_[i];
	}

	@Override
	protected void setOperand(int i, DNode node) {
		arguments_[i] = node;
	}

	@Override
	public boolean idempotent() {
		return false;
	}
}
