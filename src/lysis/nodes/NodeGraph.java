package lysis.nodes;

import lysis.PawnFile;
import lysis.lstructure.Function;

public class NodeGraph {
	private PawnFile file_;
    private NodeBlock[] blocks_;
    private int nameCounter_;
    private Function function_;

    public NodeGraph(PawnFile file, NodeBlock[] blocks)
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
    public PawnFile file()
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
