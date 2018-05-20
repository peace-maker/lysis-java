package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DString extends DNullaryNode {
	private String value_;

	public DString(String value) {
		value_ = value;
	}

	public String value() {
		return value_;
	}

	@Override
	public NodeType type() {
		return NodeType.String;
	}

	@Override
	public void accept(NodeVisitor visitor) {
		visitor.visit(this);
	}
}
