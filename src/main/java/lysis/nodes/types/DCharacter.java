package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DCharacter extends DNullaryNode {
	private char value_;

	public DCharacter(char value) {
		value_ = value;
	}

	public char value() {
		return value_;
	}

	@Override
	public NodeType type() {
		return NodeType.Character;
	}

	@Override
	public void accept(NodeVisitor visitor) {
		visitor.visit(this);
	}
}
