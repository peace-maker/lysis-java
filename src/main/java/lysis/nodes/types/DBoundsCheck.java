package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DBoundsCheck extends DUnaryNode {

	private long amount_;

	public DBoundsCheck(DNode index, long amount) throws Exception {
		super(index);
		amount_ = amount;
	}

	public long amount() {
		return amount_;
	}

	@Override
	public NodeType type() {
		return NodeType.BoundsCheck;
	}

	@Override
	public void accept(NodeVisitor visitor) {
		visitor.visit(this);
	}

	@Override
	public boolean guard() {
		return true;
	}
}
