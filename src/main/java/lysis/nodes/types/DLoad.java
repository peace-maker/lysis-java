package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DLoad extends DUnaryNode {
	public DLoad(DNode addr) throws Exception {
		super(addr);
	}

	@Override
	public NodeType type() {
		return NodeType.Load;
	}

	@Override
	public void accept(NodeVisitor visitor) throws Exception {
		visitor.visit(this);
	}

	public DNode from() {
		return getOperand(0);
	}
}
