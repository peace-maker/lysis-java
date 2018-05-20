package lysis.nodes.types;

import lysis.lstructure.Tag;
import lysis.lstructure.Variable;
import lysis.lstructure.VariableType;
import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;
import lysis.sourcepawn.SourcePawnFile;

public class DDeclareLocal extends DUnaryNode {

	private long pc_;
	private long offset_;
	private Variable var_;

	public DDeclareLocal(long pc, DNode value) throws Exception {
		super(value);
		pc_ = pc;
	}

	public void setOffset(long offset) {
		offset_ = offset;
	}

	public void setVariable(Variable var) {
		var_ = var;
	}

	public long pc() {
		return pc_;
	}

	public DNode value() {
		return getOperand(0);
	}

	public long offset() {
		return offset_;
	}

	public Variable var() {
		return var_;
	}

	@Override
	public NodeType type() {
		return NodeType.DeclareLocal;
	}

	@Override
	public void accept(NodeVisitor visitor) {
		visitor.visit(this);
	}

	@Override
	public boolean idempotent() {
		return false;
	}

	@Override
	public DNode applyType(SourcePawnFile file, Tag tag, VariableType type) throws Exception {
		if (value() == null)
			return null;
		DNode replacement = value().applyType(file, tag, type);
		if (replacement != value())
			replaceOperand(0, replacement);
		return this;
	}
}
