package lysis.types;

import lysis.lstructure.Variable;
import lysis.nodes.NodeBlock;
import lysis.nodes.NodeGraph;
import lysis.nodes.NodeList;
import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;
import lysis.nodes.types.*;
import lysis.types.TypeUnit.Kind;

public class ForwardTypePropagation extends NodeVisitor {
	private NodeGraph graph_;
    private NodeBlock block_;

    public ForwardTypePropagation(NodeGraph graph)
    {
        graph_ = graph;
    }

    public void propagate() throws Exception
    {
        for (int i = 0; i < graph_.numBlocks(); i++)
        {
            block_ = graph_.blocks(i);
            for (NodeList.iterator iter = block_.nodes().begin(); iter.more(); iter.next())
                iter.node().accept(this);
        }
    }
    
    @Override
    public void visit(DConstant node)
    {
    }
    
    @Override
    public void visit(DDeclareLocal local)
    {
        Variable var = graph_.file().lookupVariable(local.pc(), local.offset());
        local.setVariable(var);

        if (var != null)
        {
            TypeUnit tu = TypeUnit.FromVariable(var);
            assert(tu != null);
            local.addType(new TypeUnit(tu));
            if(local.value() != null && local.value().type() == NodeType.Constant && var.tag().name().equals("Float"))
            	local.value().addType(TypeUnit.FromTag(var.tag()));
        }
    }
    
    @Override
    public void visit(DLocalRef lref)
    {
        TypeSet localTypes = lref.local().typeSet();
        lref.addTypes(localTypes);
    }
    
    @Override
    public void visit(DJump jump)
    {
    }
    
    @Override
    public void visit(DJumpCondition jcc)
    {
        jcc.typeSet().addType(new TypeUnit(new PawnType(CellType.Bool)));
    }
    
    @Override
    public void visit(DSysReq sysreq)
    {
    }
    
    @Override
    public void visit(DBinary binary)
    {
    }
    
    @Override
    public void visit(DBoundsCheck check)
    {
        check.getOperand(0).setUsedAsArrayIndex();
    }
    
    @Override
    public void visit(DArrayRef aref)
    {
        DNode abase = aref.abase();
        TypeSet baseTypes = abase.typeSet();
        for (int i = 0; i < baseTypes.numTypes(); i++)
            aref.addType(baseTypes.types(i));
    }
    
    @Override
    public void visit(DStore store)
    {
    	// Make sure a constant float is assigned the right type.
    	// new Float:x;
    	// x = 12.0; // 12.0 instead of 1094713344!
    	if(store.getOperand(0).typeSet().numTypes() == 1 && store.getOperand(1).type() == NodeType.Constant)
    	{
    		TypeUnit tu = store.getOperand(0).typeSet().types(0);
    		if((tu.kind() == Kind.Cell && tu.type().type() == CellType.Float)
    		|| (tu.kind() == Kind.Reference && tu.inner().type().type() == CellType.Float))
    			store.getOperand(1).addType(new TypeUnit(new PawnType(CellType.Float)));
    	}
    }
    
    @Override
    public void visit(DLoad load)
    {
        TypeSet fromTypes = load.from().typeSet();
        for (int i = 0; i < fromTypes.numTypes(); i++)
        {
            TypeUnit tu = fromTypes.types(i);
            TypeUnit actual = tu.load();
            if (actual == null)
                actual = tu;
            load.addType(actual);
        }
    }
    
    @Override
    public void visit(DReturn ret)
    {
    }
    
    @Override
    public void visit(DGlobal global)
    {
        if (global.var() == null)
            return;

        TypeUnit tu = TypeUnit.FromVariable(global.var());
        global.addType(tu);
    }
    
    @Override
    public void visit(DString node)
    {
    }
    
    @Override
    public void visit(DCall call)
    {
    }
}
