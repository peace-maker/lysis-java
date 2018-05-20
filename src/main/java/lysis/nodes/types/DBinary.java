package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;
import lysis.sourcepawn.SPOpcode;

public class DBinary extends DBinaryNode {
	private SPOpcode spop_;

	public DBinary(SPOpcode op, DNode lhs, DNode rhs) throws Exception {
		super(lhs, rhs);
		spop_ = op;
	}

	public SPOpcode spop() {
		return spop_;
	}

	@Override
	public NodeType type() {
		return NodeType.Binary;
	}

	@Override
	public void accept(NodeVisitor visitor) {
		visitor.visit(this);
	}
}
