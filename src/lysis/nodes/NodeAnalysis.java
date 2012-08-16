package lysis.nodes;

import lysis.lstructure.Signature;
import lysis.nodes.types.DArrayRef;
import lysis.nodes.types.DBinary;
import lysis.nodes.types.DCall;
import lysis.nodes.types.DConstant;
import lysis.nodes.types.DDeclareLocal;
import lysis.nodes.types.DHeap;
import lysis.nodes.types.DInlineArray;
import lysis.nodes.types.DLoad;
import lysis.nodes.types.DMemCopy;
import lysis.nodes.types.DNode;
import lysis.nodes.types.DStore;
import lysis.nodes.types.DSysReq;
import lysis.nodes.types.DUse;
import lysis.sourcepawn.SPOpcode;
import lysis.types.TypeSet;
import lysis.types.TypeUnit;


public class NodeAnalysis {
	public static void RemoveGuards(NodeGraph graph) throws Exception
    {
        for (int i = graph.numBlocks() - 1; i >= 0; i--)
        {
            NodeBlock block = graph.blocks(i);
            for (NodeList.reverse_iterator iter = block.nodes().rbegin(); iter.more(); )
            {
                if (iter.node().guard())
                {
                    assert(iter.node().idempotent());
                    iter.node().removeFromUseChains();
                    block.nodes().remove(iter);
                    continue;
                }
                iter.next();
            }
        }
    }
	
	private static void RemoveDeadCodeInBlock(NodeBlock block) throws Exception
    {
        for (NodeList.reverse_iterator iter = block.nodes().rbegin(); iter.more(); )
        {
            if (iter.node().type() == NodeType.DeclareLocal)
            {
                DDeclareLocal decl = (DDeclareLocal)iter.node();
                if (decl.var() == null &&
                    (decl.uses().size() == 0 ||
                     (decl.uses().size() == 1 && decl.value() != null)))
                {
                    // This was probably just a stack temporary.
                    if (decl.uses().size() == 1)
                    {
                        DUse use = decl.uses().getFirst();
                        // This a onetime variable. Don't remove it, so we can keep the type info.
                        if(decl.value() != null 
                        && (decl.value().type() == NodeType.Constant 
                        || (decl.value().type() == NodeType.LocalRef 
                        && decl.value().getOperand(0) != null
                        && decl.value().getOperand(0).getOperand(0) != null
                        && decl.value().getOperand(0).getOperand(0).type() == NodeType.Constant)))
                        {
                        	//use.node().replaceOperand(use.index(), decl.value().getOperand(0).getOperand(0)); // Needs type info.
                        	iter.next();
                        	continue;
                        }
                        else
                        	use.node().replaceOperand(use.index(), decl.value());
                    }
                    iter.node().removeFromUseChains();
                    block.nodes().remove(iter);
                    continue;
                }
            }

            if ((iter.node().type() == NodeType.Store &&
                 iter.node().getOperand(0).type() == NodeType.Heap &&
                 iter.node().getOperand(0).uses().size() == 1))
            {
                iter.node().removeFromUseChains();
                block.nodes().remove(iter);
            }

            if (!iter.node().idempotent() || iter.node().guard() || iter.node().uses().size() > 0)
            {
                iter.next();
                continue;
            }

            iter.node().removeFromUseChains();
            block.nodes().remove(iter);
        }
    }
	
	// We rely on accurate use counts to rename nodes in a readable way,
    // so we provide a phase for updating use info.
    public static void RemoveDeadCode(NodeGraph graph) throws Exception
    {
        for (int i = graph.numBlocks() - 1; i >= 0; i--)
            RemoveDeadCodeInBlock(graph.blocks(i));
    }

    private static boolean IsArray(TypeSet ts)
    {
        if (ts == null)
            return false;
        if (ts.numTypes() != 1)
            return false;
        TypeUnit tu = ts.types(0);
        if (tu.kind() == TypeUnit.Kind.Array)
            return true;
        if (tu.kind() == TypeUnit.Kind.Reference && tu.inner().kind() == TypeUnit.Kind.Array)
            return true;
        return false;
    }

    private static DNode GuessArrayBase(DNode op1, DNode op2)
    {
        if (op1.usedAsArrayIndex())
            return op2;
        if (op2.usedAsArrayIndex())
            return op1;
        if (op1.type() == NodeType.ArrayRef ||
            op1.type() == NodeType.LocalRef ||
            IsArray(op1.typeSet()))
        {
            return op1;
        }
        if (op2.type() == NodeType.ArrayRef ||
            op2.type() == NodeType.LocalRef ||
            IsArray(op2.typeSet()))
        {
            return op2;
        }
        return null;
    }

    private static boolean IsReallyLikelyArrayCompute(DNode node, DNode abase)
    {
        if (abase.type() == NodeType.ArrayRef)
            return true;
        if (IsArray(abase.typeSet()))
            return true;
        for (DUse use : node.uses())
        {
            if (use.node().type() == NodeType.Store || use.node().type() == NodeType.Load)
                return true;
        }
        return false;
    }

    private static boolean IsArrayOpCandidate(DNode node)
    {
        if (node.type() == NodeType.Load || node.type() == NodeType.Store)
            return true;
        if (node.type() == NodeType.Binary)
        {
            DBinary bin = (DBinary)node;
            return bin.spop() == SPOpcode.add;
        }
        return false;
    }

    private static boolean CollapseArrayReferences(NodeBlock block) throws Exception
    {
        boolean changed = false;

        for (NodeList.reverse_iterator iter = block.nodes().rbegin(); iter.more(); iter.next())
        {
            DNode node = iter.node();

            if (node.type() == NodeType.Store || node.type() == NodeType.Load)
            {
                if (node.getOperand(0).type() != NodeType.ArrayRef && IsArray(node.getOperand(0).typeSet()))
                {
                    DConstant index0 = new DConstant(0);
                    DArrayRef aref0 = new DArrayRef(node.getOperand(0), index0, 0);
                    block.nodes().insertBefore(node, index0);
                    block.nodes().insertBefore(node, aref0);
                    node.replaceOperand(0, aref0);
                    continue;
                }
            }

            if (node.type() != NodeType.Binary)
                continue;

            DBinary binary = (DBinary)node;
            if (binary.spop() != SPOpcode.add)
                continue;

            if (binary.lhs().type() == NodeType.LocalRef)
            {
                assert(true);
            }

            // Check for an array index.
            DNode abase = GuessArrayBase(binary.lhs(), binary.rhs());
            if (abase == null)
                continue;
            DNode index = (abase == binary.lhs()) ? binary.rhs() : binary.lhs();

            if (!IsReallyLikelyArrayCompute(binary, abase))
                continue;

            // Multi-dimensional arrays are indexed like:
            // x[y] => x + x[y]
            //
            // We recognize this and just remove the add, ignoring the
            // underlying representation of the array.
            if (index.type() == NodeType.Load && index.getOperand(0) == abase)
            {
                node.replaceAllUsesWith(index);
                node.removeFromUseChains();
                block.nodes().remove(iter);
                changed = true;
                continue;
            }
            
            index.setUsedAsArrayIndex();
            
            // Otherwise, create a new array reference.
            DArrayRef aref = new DArrayRef(abase, index);
            iter.node().replaceAllUsesWith(aref);
            iter.node().removeFromUseChains();
            block.nodes().remove(iter);
            block.nodes().insertBefore(iter.node(), aref);
            changed = true;
        }

        return changed;
    }

    // Find adds that should really be array references.
    public static void CollapseArrayReferences(NodeGraph graph) throws Exception
    {
        boolean changed;
        do
        {
            changed = false;
            for (int i = graph.numBlocks() - 1; i >= 0; i--)
                changed |= CollapseArrayReferences(graph.blocks(i));
        } while (changed);
    }

    public static void CoalesceLoadsAndDeclarations(NodeGraph graph) throws Exception
    {
        for (int i = 0; i < graph.numBlocks(); i++)
        {
            NodeBlock block = graph.blocks(i);
            for (NodeList.iterator iter = block.nodes().begin(); iter.more(); )
            {
                DNode node = iter.node();

                if (node.type() == NodeType.DeclareLocal)
                {
                    // Peephole next = store(this, expr)
                    DDeclareLocal local = (DDeclareLocal)node;
                    if (node.next().type() == NodeType.Store)
                    {
                        DStore store = (DStore)node.next();
                        if (store.getOperand(0) == local)
                        {
                        	DNode replacement;
                        	if(store.spop() != SPOpcode.nop)
                        		replacement = new DBinary(store.spop(), local.getOperand(0), store.getOperand(1));
                        	else
                        		replacement = store.getOperand(1);
                            local.replaceOperand(0, replacement);
                            store.removeFromUseChains();
                            iter.next();
                            block.nodes().remove(iter);
                            continue;
                        }
                    }
                }

                iter.next();
            }
        }
    }

    private static void CoalesceLoadStores(NodeBlock block) throws Exception
    {
        for (NodeList.reverse_iterator riter = block.nodes().rbegin(); riter.more(); riter.next())
        {
            if (riter.node().type() != NodeType.Store)
                continue;

            DStore store = (DStore)riter.node();

            DNode coalesce = null;
            if (store.rhs().type() == NodeType.Binary)
            {
                DBinary rhs = (DBinary)store.rhs();
                if (rhs.lhs().type() == NodeType.Load)
                {
                    DLoad load = (DLoad)rhs.lhs();
                    if (load.from() == store.lhs())
                    {
                        coalesce = rhs.rhs();
                    }
                    else if (load.from().type() == NodeType.ArrayRef &&
                             store.lhs().type() == NodeType.Load)
                    {
                        DArrayRef aref = (DArrayRef)load.from();
                        load = (DLoad)store.lhs();
                        if (aref.abase() == load &&
                            aref.index().type() == NodeType.Constant &&
                            ((DConstant)aref.index()).value() == 0)
                        {
                            coalesce = rhs.rhs();
                            store.replaceOperand(0, aref);
                        }
                    }
                }
                if (coalesce != null)
                    store.makeStoreOp(rhs.spop());
            }
            else if (store.rhs().type() == NodeType.Load &&
                     store.rhs().getOperand(0) == store.lhs())
            {
                // AWFUL PATTERN MATCHING AHEAD.
                // This *looks* like a dead store, but there is probably
                // something in between the load and store that changes
                // the reference. We assume this has to be an incdec.
                if (store.prev().type() == NodeType.IncDec &&
                    store.prev().getOperand(0) == store.rhs())
                {
                    // This detects a weird case in ucp.smx:
                    // v0 = ArrayRef
                    // v1 = Load(v0)
                    // --   Dec(v1)
                    // --   Store(v0, v1)
                    // This appears to be:
                    //   *ref = (--*ref)
                    // But, this should suffice:
                    //   --*ref
                    store.removeFromUseChains();
                    block.nodes().remove(riter);
                    assert(riter.node().type() == NodeType.IncDec);
                    riter.node().replaceOperand(0, riter.node().getOperand(0).getOperand(0));
                }
            }

            if (coalesce != null)
                store.replaceOperand(1, coalesce);
        }
    }

    public static void CoalesceLoadStores(NodeGraph graph) throws Exception
    {
        for (int i = 0; i < graph.numBlocks(); i++)
            CoalesceLoadStores(graph.blocks(i));
    }

    private static Signature SignatureOf(DNode node)
    {
        if (node.type() == NodeType.Call)
            return ((DCall)node).function();
        return ((DSysReq)node).nativeX();
    }

    private static boolean AnalyzeHeapNode(NodeBlock block, DHeap node) throws Exception
    {
        // Easy case: compiler needed a lvalue.
        if (node.uses().size() == 2)
        {
            DUse lastUse = node.uses().getLast();
            DUse firstUse = node.uses().getFirst();
            if ((lastUse.node().type() == NodeType.Call ||
                 lastUse.node().type() == NodeType.SysReq) &&
                firstUse.node().type() == NodeType.Store &&
                firstUse.index() == 0)
            {
                lastUse.node().replaceOperand(lastUse.index(), firstUse.node().getOperand(1));
                return true;
            }

            if ((lastUse.node().type() == NodeType.Call ||
                 lastUse.node().type() == NodeType.SysReq) &&
                firstUse.node().type() == NodeType.MemCopy &&
                firstUse.index() == 0)
            {
                // heap -> memcpy always reads from DAT + constant
                DMemCopy memcopy = (DMemCopy)firstUse.node();
                DConstant cv = (DConstant)memcopy.from();
                DInlineArray ia = new DInlineArray(cv.value(), memcopy.bytes());
                block.nodes().insertAfter(node, ia);
                lastUse.node().replaceOperand(lastUse.index(), ia);

                // Give the inline array some type information.
                Signature signature = SignatureOf(lastUse.node());
                TypeUnit tu = TypeUnit.FromArgument(signature.args()[lastUse.index()]);
                ia.addType(tu);
                return true;
            }
        }

        return false;
    }

    private static void AnalyzeHeapUsage(NodeBlock block) throws Exception
    {
        for (NodeList.reverse_iterator riter = block.nodes().rbegin(); riter.more(); riter.next())
        {
            if (riter.node().type() == NodeType.Heap)
            {
                if (AnalyzeHeapNode(block, (DHeap)riter.node()))
                    block.nodes().remove(riter);
            }
        }
    }

    public static void AnalyzeHeapUsage(NodeGraph graph) throws Exception
    {
        for (int i = 0; i < graph.numBlocks(); i++)
            AnalyzeHeapUsage(graph.blocks(i));
    }
}
