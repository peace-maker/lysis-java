package lysis;

import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.util.LinkedList;

import lysis.builder.MethodParser;
import lysis.builder.SourceBuilder;
import lysis.builder.structure.ControlBlock;
import lysis.builder.structure.SourceStructureBuilder;
import lysis.lstructure.Argument;
import lysis.lstructure.Function;
import lysis.lstructure.LGraph;
import lysis.lstructure.VariableType;
import lysis.nodes.NodeAnalysis;
import lysis.nodes.NodeBlock;
import lysis.nodes.NodeBuilder;
import lysis.nodes.NodeGraph;
import lysis.nodes.NodeRenamer;
import lysis.nodes.NodeRewriter;
import lysis.types.BackwardTypePropagation;
import lysis.types.ForwardTypePropagation;

public class Lysis {

	public static void PreprocessMethod(PawnFile file, Function func) throws Exception {
		MethodParser mp = new MethodParser(file, func);
		mp.preprocess();

		int nargs = mp.getNumArgs();
		
		// This function had no debug info attached :(
		if (func.codeEnd() == file.code().bytes().length + 1)
			func.setCodeEnd(mp.getExitPC() - 4);

		// No argument information for this function :(
		if (func.args() == null || func.args().length < nargs) {
			LinkedList<Argument> args = new LinkedList<Argument>();
			int start = 0;
			int num = nargs;
			if (func.args() != null) {
				start = func.args().length;
				// Copy present args
				for (Argument arg : func.args())
					args.add(arg);
			}
			for (int i = start; i < num; i++) {
				Argument arg = new Argument(VariableType.Normal, "_arg" + i, 0, null, null);
				arg.markGenerated();

				// See if this argument is already there.
				// Implementations of functions for different states don't have their arguments
				// fetched when parsing the debug sections.
				if (!file.addArgumentDummyVar(func, i))
					arg = file.buildArgumentInfo(func, i);

				args.add(arg);
			}
			// Collect any other unused arguments that we have debug info about.
			for (int i = num;; i++) {
				Argument arg = file.buildArgumentInfo(func, i);
				if (arg == null)
					break;
				args.add(arg);
			}
			func.setArguments(args);
		}
	}

	public static void DumpMethod(PawnFile file, SourceBuilder source, Function func) throws Exception {
		MethodParser mp = new MethodParser(file, func);
		LGraph graph = mp.parse();
		if (graph == null)
			return;

		// DebugSpew.DumpGraph(graph.blocks, new DataOutputStream(System.out));

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

		// Print string initializations new String:bla[] = "HALLO";
		NodeAnalysis.HandleMemCopys(ngraph);

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

		// System.in.read();
		// System.in.read();
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		if (args.length < 1) {
			System.err.println("usage: <file.smx> or <file.amxx> or <file.amx>");
			return;
		}

		PrintStream sysout;
		try {
			sysout = new PrintStream(System.out, true, "UTF-8");
			System.setOut(sysout);
		} catch (UnsupportedEncodingException e2) {
			e2.printStackTrace();
		}

		String path = args[0];
		PawnFile file = null;
		try {
			file = PawnFile.FromFile(path);
		} catch (Exception e1) {
			e1.printStackTrace();
			return;
		}

		if (file == null) {
			System.err.println("Failed to parse file.");
			return;
		}

		// DataOutputStream dOut = new DataOutputStream(System.out);

		// Parse methods for calls and globals which don't have debug info attached.
		for (int i = 0; i < file.functions().length; i++) {
			Function fun = file.functions()[i];
			try {
				PreprocessMethod(file, fun);
			} catch (Throwable e) {
				e.printStackTrace();
				System.out.println("");
				System.out.println("/* ERROR PREPROCESSING! " + e.getMessage() + " */");
				System.out.println(" function \"" + fun.name() + "\" (number " + i + ")");
			}
		}

		SourceBuilder source = new SourceBuilder(file, System.out);
		try {
			source.writeGlobals();
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

		for (int i = 0; i < file.functions().length; i++) {
			Function fun = file.functions()[i];
			// #if
			try {
				DumpMethod(file, source, fun);
				System.out.println("");
			} catch (Throwable e) {
				e.printStackTrace();
				System.out.println("");
				System.out.println("/* ERROR! " + e.getMessage() + " */");
				System.out.println(" function \"" + fun.name() + "\" (number " + i + ")");
				source = new SourceBuilder(file, System.out);
			}
			// #endif
		}
	}

}
