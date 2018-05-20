package lysis.builder.structure;

import lysis.nodes.NodeBlock;

public class WhileLoop extends ControlBlock {
	ControlBlock body_;
	ControlBlock join_;
	LogicChain logic_;
	ControlType type_;

	public WhileLoop(ControlType type, NodeBlock source, ControlBlock body, ControlBlock join) {
		super(source);
		body_ = body;
		join_ = join;
		type_ = type;
	}

	public WhileLoop(ControlType type, LogicChain logic, ControlBlock body, ControlBlock join) {
		super(null);
		body_ = body;
		join_ = join;
		logic_ = logic;
		type_ = type;
	}

	@Override
	public ControlType type() {
		return type_;
	}

	public ControlBlock body() {
		return body_;
	}

	public ControlBlock join() {
		return join_;
	}

	public LogicChain logic() {
		return logic_;
	}
}
