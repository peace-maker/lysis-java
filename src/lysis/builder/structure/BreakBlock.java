package lysis.builder.structure;

import lysis.nodes.NodeBlock;

public class BreakBlock extends ControlBlock {

    public BreakBlock(NodeBlock source) {
        super(source);
    }

    @Override
    public ControlType type() {
        return ControlType.Break;
    }

}
