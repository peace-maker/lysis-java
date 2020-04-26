import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.PrintStream;
import java.util.Collection;
import java.util.LinkedList;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameter;
import org.junit.runners.Parameterized.Parameters;

import lysis.Lysis;
import lysis.PawnFile;
import lysis.builder.SourceBuilder;
import lysis.lstructure.Function;

@RunWith(Parameterized.class)
public class LysisTest {

	public static final String TEST_FOLDER = "./tests";
	public static final boolean UPDATE_OUTPUT_FILES = false;

	@Parameter(0)
	public String path;

	private static void collectFiles(Collection<Object[]> files, File folder) {
		assertTrue("Folder containing test binaries doesn't exist.", folder.exists());

		File[] nodes = folder.listFiles(new FileFilter() {

			@Override
			public boolean accept(File file) {
				if (file.isDirectory() && !file.getName().equals("disabled"))
					return true;

				return file.getName().endsWith(".smx") || file.getName().endsWith(".amxx");
			}
		});

		for (File file : nodes) {
			if (file.isFile())
				files.add(new String[] { file.getAbsolutePath() });
			else if (file.isDirectory())
				collectFiles(files, file);

			// System.out.println("Collecting file " + file.getAbsolutePath());
		}
	}

	@Parameters(name = "{index} {0}")
	public static Collection<Object[]> files() {
		Collection<Object[]> files = new LinkedList<Object[]>();

		File testFolder = new File(TEST_FOLDER);
		collectFiles(files, testFolder);
		return files;
	}

	@Test
	public void testPluginResult() throws Exception {

		System.out.println("Running test file: " + path);
		// Get the matching file containing the expected output.
		File outFile = new File(path.replaceFirst("\\.(smx|amxx)$", ".out"));
		if (!UPDATE_OUTPUT_FILES) {
			assertTrue("Out-file missing.", outFile.exists() || outFile.canRead());
		}

		ByteArrayOutputStream bout = new ByteArrayOutputStream();
		PrintStream out = new PrintStream(new BufferedOutputStream(bout), true, "UTF-8");

		// Try to parse the file as pawn file.
		PawnFile file = PawnFile.FromFile(path);
		assertNotNull("Failed to parse file.", file);

		// Parse methods for calls and globals which don't have debug info attached.
		for (int i = 0; i < file.functions().length; i++) {
			Function fun = file.functions()[i];
			try {
				Lysis.PreprocessMethod(file, fun);
			} catch (Throwable e) {
				out.println("");
				out.println("/* ERROR PREPROCESSING! " + e.getMessage() + " */");
				out.println(" function \"" + fun.name() + "\" (number " + i + ")");
			}
			// System.out.println(" function \"" + fun.name() + "\" (number " + i + ")");
		}

		// Dump all global variables and structures.
		SourceBuilder source = new SourceBuilder(file, out);
		source.writeGlobals();

		// Go through all functions and try to print them.
		for (int i = 0; i < file.functions().length; i++) {
			Function fun = file.functions()[i];
			try {
				Lysis.DumpMethod(file, source, fun);
			} catch (Throwable e) {
				out.println("");
				out.println("/* ERROR! " + e.getMessage() + " */");
				out.println(" function \"" + fun.name() + "\" (number " + i + ")");
				source = new SourceBuilder(file, out);
			}
			// System.out.println(" function \"" + fun.name() + "\" (number " + i + ")");
			out.println("");
		}

		String result = new String(bout.toByteArray(), "UTF-8");

		if (!UPDATE_OUTPUT_FILES) {
			// Get the expected result from the .out file.
			StringBuilder expectedResult = new StringBuilder();
			try (BufferedReader br = new BufferedReader(new FileReader(outFile.getAbsolutePath()))) {
				String line;
				while ((line = br.readLine()) != null) {
					expectedResult.append(line + System.lineSeparator());
				}
			}

			// Make sure we produce the same result still.
			assertEquals("Mismatching decompilation output", expectedResult.toString(), result);
		} else {
			try (BufferedWriter bw = new BufferedWriter(new FileWriter(outFile.getAbsolutePath()))) {
				bw.append(result);
			}
		}
	}
}
