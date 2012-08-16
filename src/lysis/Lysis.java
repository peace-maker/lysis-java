package lysis;

import java.io.DataOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;

import lysis.builder.MethodParser;
import lysis.builder.SourceBuilder;
import lysis.builder.structure.ControlBlock;
import lysis.builder.structure.SourceStructureBuilder;
import lysis.lstructure.Function;
import lysis.lstructure.LGraph;
import lysis.nodes.NodeAnalysis;
import lysis.nodes.NodeBlock;
import lysis.nodes.NodeBuilder;
import lysis.nodes.NodeGraph;
import lysis.nodes.NodeRenamer;
import lysis.nodes.NodeRewriter;
import lysis.nodes.types.DNode;
import lysis.sourcepawn.SourcePawnFile;
import lysis.types.BackwardTypePropagation;
import lysis.types.ForwardTypePropagation;

public class Lysis {

	public static final boolean bDebug = false;
	
	static void DumpMethod(SourcePawnFile file, SourceBuilder source, long addr) throws Exception
    {
        MethodParser mp = new MethodParser(file, addr);
        LGraph graph = mp.parse();
        //DebugSpew.DumpGraph(graph.blocks, new DataOutputStream(System.out));

        NodeBuilder nb = new NodeBuilder(file, graph);
        NodeBlock[] nblocks = nb.buildNodes();

        NodeGraph ngraph = new NodeGraph(file, nblocks);

        // Remove dead phis first.
        NodeAnalysis.RemoveDeadCode(ngraph);
        
        NodeRewriter rewriter = new NodeRewriter(ngraph);
        rewriter.rewrite();

        NodeAnalysis.CollapseArrayReferences(ngraph);

        // Propagate type information.
        ForwardTypePropagation ftypes = new ForwardTypePropagation(ngraph);
        ftypes.propagate();

        BackwardTypePropagation btypes = new BackwardTypePropagation(ngraph);
        btypes.propagate();

        // We're not fixpoint, so just iterate again.
        ftypes.propagate();
        btypes.propagate();

        // Try this again now that we have type information.
        NodeAnalysis.CollapseArrayReferences(ngraph);

        ftypes.propagate();
        btypes.propagate();

        // Coalesce x[y] = x[y] + 5 into x[y] += 5
        NodeAnalysis.CoalesceLoadStores(ngraph);

        // After this, it is not legal to run type analysis again, because
        // arguments expecting references may have been rewritten to take
        // constants, for pretty-printing.
        NodeAnalysis.AnalyzeHeapUsage(ngraph);

        // Do another DCE pass, this time, without guards.
        NodeAnalysis.RemoveGuards(ngraph);
        NodeAnalysis.RemoveDeadCode(ngraph);

        NodeRenamer renamer = new NodeRenamer(ngraph);
        renamer.rename();

        // Do a pass to coalesce declaration+stores.
        NodeAnalysis.CoalesceLoadsAndDeclarations(ngraph);

        // Simplify conditional expressions.
        // BlockAnalysis.NormalizeConditionals(ngraph);
        SourceStructureBuilder sb = new SourceStructureBuilder(ngraph);
        ControlBlock structure = sb.build();
        
        source.write(structure);

        //System.in.read();
        //System.in.read();
    }
	
	static Function FunctionByName(SourcePawnFile file, String name)
    {
        for (int i = 0; i < file.functions().length; i++)
        {
            if (file.functions()[i].name() == name)
                return file.functions()[i];
        }
        return null;
    }
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		if (args.length < 1)
        {
            System.err.println("usage: <file.smx> or <file.amxx>");
            return;
        }
		
		PrintStream sysout;
		try {
			sysout = new PrintStream(System.out, true, "UTF-8");
			System.setOut(sysout);
		} catch (UnsupportedEncodingException e2) {
			// TODO Auto-generated catch block
			e2.printStackTrace();
		}
		
		String path = args[0];
        PawnFile file = null;
		try {
			file = PawnFile.FromFile(path);
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
			return;
		}
        
		if(file == null) {
			System.err.println("Failed to parse file.");
			return;
		}
		
		//DataOutputStream dOut = new DataOutputStream(System.out);
		
        SourceBuilder source = new SourceBuilder(file, System.out);
        try {
			source.writeGlobals();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

        for (int i = 0; i < file.functions().length; i++)
        {
            Function fun = file.functions()[i];
//#if 
            try
            {
                DumpMethod((SourcePawnFile)file, source, fun.address());
                System.out.println("");
            }
            catch (Exception e)
            {
            	e.printStackTrace();
            	System.out.println("");
            	System.out.println("/* ERROR! " + e.getMessage() + " */");
            	System.out.println(" function \"" + fun.name() + "\" (number " + i + ")");
                source = new SourceBuilder((SourcePawnFile)file, System.out);
            }
//#endif
        }
	}

}
