package lysis.nodes;

import lysis.nodes.types.DDeclareLocal;
import lysis.nodes.types.DNode;
import lysis.nodes.types.DTempName;
import lysis.nodes.types.DUse;

public class NodeRenamer {
	private NodeGraph graph_;

    private void renameBlock(NodeBlock block) throws Exception
    {
        for (NodeList.iterator iter = block.nodes().begin(); iter.more();)
        {
            DNode node = iter.node();
            switch (node.type())
            {
                case TempName:
                case Jump:
                case JumpCondition:
                case Store:
                case Return:
                case IncDec:
                case DeclareStatic:
                case Switch:
                {
                    iter.next();
                    continue;
                }

                case DeclareLocal:
                {
                    DDeclareLocal decl = (DDeclareLocal)node;
                    if (decl.var() == null)
                    {
                        if (decl.uses().size() <= 1)
                        {
                            // This was probably just a stack temporary.
                            if (decl.uses().size() == 1)
                            {
                                DUse use = decl.uses().getFirst();
                                use.node().replaceOperand(use.index(), decl.value());
                            }
                            block.nodes().remove(iter);
                            continue;
                        }
                        DTempName name = new DTempName(graph_.tempName());
                        node.replaceAllUsesWith(name);
                        name.init(decl.value());
                        block.nodes().replace(iter, name);
                    }
                    iter.next();
                    continue;
                }

                case SysReq:
                case Call:
                {
                    // Calls are statements or expressions, so we can't
                    // remove them if they have no uses.
                    if (node.uses().size() <= 1)
                    {
                        if (node.uses().size() == 1)
                            block.nodes().remove(iter);
                        else
                            iter.next();
                        continue;
                    }
                    break;
                }

                case Constant:
                {
                    // Constants can be deeply copied.
                    block.nodes().remove(iter);
                    continue;
                }

                default:
                {
                    if (node.uses().size() <= 1)
                    {
                        // This node has one or zero uses, so instead of
                        // renaming it, we remove it from the instruction
                        // stream. This way the source printer will deep-
                        // print it instead of using its 'SSA' name.
                        block.nodes().remove(iter);
                        continue;
                    }

                    break;
                }
            }

            // If we've reached here, the expression has more than one use
            // and we have to wrap it in some kind of name, lest we
            // duplicate it in the expression tree which may be illegal.
            DTempName replacement = new DTempName(graph_.tempName());
            node.replaceAllUsesWith(replacement);
            replacement.init(node);
            block.nodes().replace(iter, replacement);
            iter.next();
        }
    }

    public NodeRenamer(NodeGraph graph)
    {
        graph_ = graph;
    }

    public void rename() throws Exception
    {
        for (int i = 0; i < graph_.numBlocks(); i++)
            renameBlock(graph_.blocks(i));
    }
}
