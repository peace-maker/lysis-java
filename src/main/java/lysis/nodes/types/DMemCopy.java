package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DMemCopy extends DBinaryNode {
	private long bytes_;

	public DMemCopy(DNode to, DNode from, long bytes) throws Exception {
		super(to, from);
		bytes_ = bytes;
	}

	@Override
	public NodeType type() {
		return NodeType.MemCopy;
	}

	@Override
	public void accept(NodeVisitor visitor) {
		visitor.visit(this);
	}

	@Override
	public boolean idempotent() {
		return false;
	}

	public long bytes() {
		return bytes_;
	}

	public DNode from() {
		return getOperand(1);
	}

	public DNode to() {
		return getOperand(0);
	}
}
