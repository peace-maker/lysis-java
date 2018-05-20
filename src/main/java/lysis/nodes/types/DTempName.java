package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DTempName extends DUnaryNode {
	private String name_;

	public DTempName(String name) throws Exception {
		super(null);
		name_ = name;
	}

	public void init(DNode node) throws Exception {
		initOperand(0, node);
	}

	public String name() {
		return name_;
	}

	@Override
	public NodeType type() {
		return NodeType.TempName;
	}

	@Override
	public void accept(NodeVisitor visitor) {
	}

	@Override
	public boolean idempotent() {
		return false;
	}
}
