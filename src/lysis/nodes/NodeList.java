package lysis.nodes;

import lysis.nodes.types.DNode;
import lysis.nodes.types.DSentinel;

public class NodeList {
	private DNode head_;

    public NodeList()
    {
        head_ = new DSentinel();
        head_.prevSet(head_);
        head_.nextSet(head_);
    }

    public void insertBefore(DNode at, DNode node)
    {
        node.nextSet(at);
        node.prevSet(at.prev());
        at.prev().nextSet(node);
        at.prevSet(node);
    }
    public void insertAfter(DNode at, DNode node)
    {
        node.nextSet(at);
        node.prevSet(at.prev());
        at.prev().nextSet(node);
        at.prevSet(node);
    }
    public void add(DNode node)
    {
        insertBefore(head_, node);
    }
    public iterator begin()
    {
        return new iterator(head_.next());
    }
    public reverse_iterator rbegin()
    {
        return new reverse_iterator(head_.prev());
    }
    public void remove(iterator_base where)
    {
        DNode node = where.node();
        where.next();
        remove(node);
    }
    public void remove(DNode node)
    {
        node.prev().nextSet(node.next());
        node.next().prevSet(node.prev());
        node.nextSet(null);
        node.prevSet(null);
    }
    public void replace(DNode at, DNode with)
    {
        with.prevSet(at.prev());
        with.nextSet(at.next());
        at.prev().nextSet(with);
        at.next().prevSet(with);
        at.prevSet(null);
        at.nextSet(null);
    }
    public void replace(iterator_base where, DNode with)
    {
        replace(where.node(), with);
        where.nodeSet(with);
    }

    public DNode last()
    {
    	return head_.prev();
    }
    public DNode first()
    {
        return head_.next();
    }

    public abstract class iterator_base
    {
        protected DNode node_;

        public iterator_base(DNode node)
        {
            node_ = node;
        }

        public boolean more()
        {
            return node_.type() != NodeType.Sentinel;
        }

        public abstract void next();

        public DNode node()
        {
            return node_;
        }
        
        public DNode nodeSet(DNode value) {
        	node_ = value;
        	return node_;
        }
    }

    public class iterator extends iterator_base
    {
        public iterator(DNode node)
        {
        	super(node);
        }

        @Override
        public void next()
        {
            node_ = node_.next();
        }
    }

    public class reverse_iterator extends iterator_base
    {
        public reverse_iterator(DNode node)
        {
        	super(node);
        }

        @Override
        public void next()
        {
            node_ = node_.prev();
        }
    }
}
