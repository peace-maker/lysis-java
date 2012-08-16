package lysis.builder.structure;

import java.util.LinkedList;

import lysis.nodes.types.DNode;

public class LogicChain {
	public class Node
    {
        private DNode expression_;
        private LogicChain subChain_;

        public Node(DNode expression)
        {
            expression_ = expression;
        }
        public Node(LogicChain subChain)
        {
            subChain_ = subChain;
        }

        public DNode expression()
        {
            assert(!isSubChain());
            return expression_;
        }
        public boolean isSubChain()
        {
            return subChain_ != null;
        }
        public LogicChain subChain()
        {
            return subChain_;
        }
    }

    private LogicOperator op_;
    private LinkedList<Node> nodes_ = new LinkedList<Node>();

    public LogicChain(LogicOperator op)
    {
        op_ = op;
    }

    public void append(DNode expression)
    {
        nodes_.add(new Node(expression));
    }
    public void append(LogicChain subChain)
    {
        nodes_.add(new Node(subChain));
    }

    public LogicOperator op()
    {
        return op_;
    }
    public LinkedList<Node> nodes()
    {
        return nodes_;
    }
}
