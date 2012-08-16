package lysis.builder.structure;

import lysis.nodes.NodeBlock;

public class ReturnBlock extends ControlBlock {
	public ReturnBlock(NodeBlock source)
	{
		super(source);
	}

	@Override
	public ControlType type()
	{
		return ControlType.Return;
	}
}
