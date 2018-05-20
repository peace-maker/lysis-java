package lysis.nodes.types;

import lysis.lstructure.Variable;
import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DGlobal extends DNullaryNode {
	private Variable var_;

	public DGlobal(Variable var) {
		assert (var != null);
		var_ = var;
	}

	public Variable var() {
		return var_;
	}

	@Override
	public NodeType type() {
		return NodeType.Global;
	}

	@Override
	public void accept(NodeVisitor visitor) {
		visitor.visit(this);
	}
}
