package lysis.nodes.types;

public class DUse {
	private DNode node_;
    private int index_;

    public DUse(DNode node, int index)
    {
        node_ = node;
        index_ = index;
    }

    public DNode node()
    {
        return node_;
    }
    public int index()
    {
        return index_;
    }
}
