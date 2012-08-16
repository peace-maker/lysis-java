package lysis.nodes;

import lysis.lstructure.Function;
import lysis.sourcepawn.SourcePawnFile;

public class NodeGraph {
	private SourcePawnFile file_;
    private NodeBlock[] blocks_;
    private int nameCounter_;
    private Function function_;

    public NodeGraph(SourcePawnFile file, NodeBlock[] blocks)
    {
        file_ = file;
        blocks_ = blocks;
        nameCounter_ = 0;
        function_ = file_.lookupFunction(blocks[0].lir().pc());
    }
    public NodeBlock blocks(int i)
    {
        return blocks_[i];
    }
    public SourcePawnFile file()
    {
        return file_;
    }
    public Function function()
    {
        return function_;
    }
    public int numBlocks()
    {
        return blocks_.length;
    }
    public String tempName()
    {
        return "var" + ++nameCounter_;
    }
}
