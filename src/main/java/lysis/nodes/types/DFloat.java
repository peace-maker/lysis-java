package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DFloat extends DNullaryNode {
	private float value_;

	public DFloat(float value) {
		value_ = value;
	}

	public float value() {
		return value_;
	}

	@Override
	public NodeType type() {
		return NodeType.Float;
	}

	@Override
	public void accept(NodeVisitor visitor) {
		visitor.visit(this);
	}
}
