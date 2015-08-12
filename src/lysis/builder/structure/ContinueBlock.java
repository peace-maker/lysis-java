package lysis.builder.structure;

import lysis.nodes.NodeBlock;

public class ContinueBlock extends ControlBlock {

    public ContinueBlock(NodeBlock source) {
        super(source);
    }

    @Override
    public ControlType type() {
        return ControlType.Continue;
    }

}
