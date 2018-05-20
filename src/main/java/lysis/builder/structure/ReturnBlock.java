package lysis.builder.structure;

import lysis.nodes.NodeBlock;

public class ReturnBlock extends ControlBlock {
	LogicChain chain_ = null;

	public ReturnBlock(NodeBlock source) {
		super(source);
	}

	public ReturnBlock(NodeBlock source, LogicChain chain) {
		super(source);
		chain_ = chain;
	}

	@Override
	public ControlType type() {
		return ControlType.Return;
	}

	public LogicChain chain() {
		return chain_;
	}
}
