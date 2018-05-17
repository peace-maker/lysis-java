package lysis.builder.structure;

import lysis.nodes.NodeBlock;

public class GotoBlock extends ControlBlock {
	NodeBlock target_ = null;
	public GotoBlock(NodeBlock source)
	{
		super(source);
	}

	public GotoBlock(NodeBlock source, NodeBlock target)
	{
		super(source);
		target_ = target;
	}
	
	@Override
	public ControlType type()
	{
		return ControlType.Goto;
	}
	
	public NodeBlock target()
	{
		return target_;
	}
}
