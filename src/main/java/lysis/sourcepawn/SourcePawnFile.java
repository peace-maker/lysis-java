package lysis.sourcepawn;

import java.io.ByteArrayInputStream;
import java.io.UnsupportedEncodingException;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.Inflater;

import lysis.BitConverter;
import lysis.ExtendedDataInputStream;
import lysis.PawnFile;
import lysis.Public;
import lysis.Similarity;
import lysis.lstructure.Argument;
import lysis.lstructure.Dimension;
import lysis.lstructure.Function;
import lysis.lstructure.Native;
import lysis.lstructure.Scope;
import lysis.lstructure.Tag;
import lysis.lstructure.Variable;
import lysis.lstructure.VariableType;

public class SourcePawnFile extends PawnFile {

	public final static long MAGIC = 0x53504646;
	private final static byte IDENT_VARIABLE = 1;
	private final static byte IDENT_REFERENCE = 2;
	private final static byte IDENT_ARRAY = 3;
	private final static byte IDENT_REFARRAY = 4;
	private final static byte IDENT_FUNCTION = 9;
	private final static byte IDENT_VARARGS = 11;

	private final static byte DIMEN_MAX = 4;

	public enum Compression {
		None, Gzip
	}

	public class Header {
		public long magic;
		public long version;
		public Compression compression;
		public int disksize;
		public int imagesize;
		public int sections;
		public int stringtab;
		public int dataoffs;
	}

	private class Section {
		public int nameoffs;
		public int dataoffs;
		public int size;
		public String name;

		public Section(int nameoffs, int dataoffs, int size, String name) {
			this.nameoffs = nameoffs;
			this.dataoffs = dataoffs;
			this.size = size;
			this.name = name;
		}
	}

	private static VariableType FromIdent(byte ident) {
		switch (ident) {
		case IDENT_VARIABLE:
			return VariableType.Normal;
		case IDENT_REFERENCE:
			return VariableType.Reference;
		case IDENT_ARRAY:
			return VariableType.Array;
		case IDENT_REFARRAY:
			return VariableType.ArrayReference;
		case IDENT_VARARGS:
			return VariableType.Variadic;
		default:
			return VariableType.Normal;
		}
	}

	private static String ReadString(byte[] bytes, long offset) {
		long count = offset;
		for (; count < bytes.length; count++) {
			if (bytes[(int) count] == 0)
				break;
		}
		try {
			return new String(bytes, (int) offset, (int) (count - offset), "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}

		return null;
	}

	private static String ReadStringEx(byte[] bytes, int offset, int maxread) {
		int count = offset;
		int last = count + maxread;
		for (; count < bytes.length && count <= last; count++) {
			if (bytes[count] == 0)
				break;
		}
		try {
			return new String(bytes, (int) offset, (int) (count - offset), "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}

		return null;
	}

	/// <summary>
	/// File proper
	/// </summary>

	private Header header_ = new Header();
	public static boolean debugUnpacked_;
	private HashMap<String, Section> sections_;
	private HashSet<AddressRange> stringRanges_ = new HashSet<>();

	// Detect and match (Float) operators in the .publics and .dbg.symbols tables.
	private Pattern publicOperator = Pattern.compile("^\\.\\d+\\.(\\d+)(.)(\\d+)$");
	private Pattern symbolsOperator = Pattern.compile("^operator(.)\\(([^:]+):,([^:]+):\\)$");

	private static final String[] KNOWN_SECTIONS = new String[] { ".code", ".data", ".publics", ".pubvars", ".natives",
			".tags", ".names", ".dbg.natives", ".dbg.files", ".dbg.lines", ".dbg.symbols", ".dbg.info",
			".dbg.strings" };

	public SourcePawnFile(byte[] binary) throws Exception {
		ExtendedDataInputStream reader = new ExtendedDataInputStream(new ByteArrayInputStream(binary));
		header_.magic = reader.ReadUInt32(); // ReadUInt32();
		if (header_.magic != MAGIC) {
			reader.close();
			throw new Exception("bad magic - not SourcePawn file");
		}
		header_.version = reader.ReadInt16();
		header_.compression = Compression.values()[reader.readByte()];
		header_.disksize = (int) reader.ReadUInt32() & 0xffffffff;
		header_.imagesize = (int) reader.ReadUInt32() & 0xffffffff;
		header_.sections = (int) reader.readByte();
		header_.stringtab = (int) reader.ReadUInt32() & 0xffffffff;
		header_.dataoffs = (int) reader.ReadUInt32() & 0xffffffff;

		sections_ = new HashMap<String, Section>();

		Set<String> knownSections = new HashSet<String>(Arrays.asList(KNOWN_SECTIONS));

		int firstData = 0;
		Section previousSection = null;
		boolean previousUnknown = false;
		LinkedList<Section> unknownSections = new LinkedList<Section>();

		// Read sections.
		for (int i = 0; i < header_.sections; i++) {
			int nameOffset = (int) reader.ReadUInt32();
			int dataoffs = (int) reader.ReadUInt32();
			if (i == 0)
				firstData = dataoffs;
			int size = (int) reader.ReadUInt32();
			String name;
			if (i == header_.sections - 1) {
				int start = header_.stringtab + nameOffset;
				name = ReadStringEx(binary, start, firstData - start - 2);
			} else {
				name = ReadString(binary, header_.stringtab + nameOffset);
			}

			/*
			 * SOME SERIOUS BAD HEURISTICS AHEAD! WATCH OUT!
			 */
			if (previousUnknown) {
				// The previous section got a tampered name.
				// Lets see if we can recover it.
				String recoveredName = "";
				int offset = header_.stringtab + previousSection.nameoffs;
				for (; offset < binary.length && (offset - header_.stringtab) < (nameOffset - 1); offset++) {
					// Read as many bytes until the next section's name starts
					// Replace any null bytes on the way with '_'
					if (binary[offset] == '\0')
						recoveredName += "_";
					else
						recoveredName += new String(binary, offset, 1, "UTF-8");
				}
				System.err.printf("// Recovered name of previous section as \"%s\".%n", recoveredName);
				previousSection.name = recoveredName;
			}

			// We're expecting that section. Good to see ya!
			if (knownSections.contains(name)) {
				previousUnknown = false;
				knownSections.remove(name);
			} else {
				// This section shouldn't be here.
				previousUnknown = true;
				System.err.printf("// Unknown section \"%s\".%n", name);
				if (previousSection != null) {
					// Make sure the nameoffsets are sanely in order.
					int expectedNameOffs = previousSection.nameoffs + previousSection.name.length() + 1;
					if (nameOffset != expectedNameOffs) {
						System.err.printf("// Expected name to start at %d, but says it starts at %d. Correcting..%n",
								expectedNameOffs, nameOffset);
						nameOffset = expectedNameOffs;
					}
				}
			}

			// Sanity check for the sizes of sections
			if (previousSection != null) {
				int nextDataOffs = previousSection.dataoffs + previousSection.size;
				if (dataoffs != nextDataOffs) {
					System.err.printf("// Bad section size for section %s. Trying to repair.%n", previousSection.name);
					previousSection.size = dataoffs - previousSection.dataoffs;
				}
			}

			previousSection = new Section(nameOffset, dataoffs, size, name);

			// Remember that we're not done with this strange section yet.
			if (previousUnknown)
				unknownSections.add(previousSection);
			else
				sections_.put(name, previousSection);
		}
		reader.close();

		for (String sectionName : knownSections) {
			// There was no dbg.natives section in SM 1.0. Don't require it.
			if (header_.version != 0x0101 || !sectionName.equals(".dbg.natives"))
				System.err.printf("// Missing section \"%s\".%n", sectionName);
		}

		// There are some sections missing and some unknown ones there?
		if (knownSections.size() == unknownSections.size()) {
			// Try to match all of them
			while (knownSections.size() > 0) {
				// Start with the ones with the highest similarity
				// Then go down to the more different ones..
				float highestSimilarity = -1.0f;
				String bestMatchingName = null;
				Section bestMatchinSection = null;
				for (String missingSection : knownSections) {
					for (Section unknownSection : unknownSections) {
						float similarity = Similarity.GetSimilarity(missingSection, unknownSection.name);
						if (similarity > highestSimilarity) {
							highestSimilarity = similarity;
							bestMatchingName = missingSection;
							bestMatchinSection = unknownSection;
						}
					}
				}

				// This isn't good enough and we don't want to start parsing random stuff.
				if (highestSimilarity < 0.3) {
					System.err.printf("// Can't find good similarity between sections (only coefficient of %f).%n",
							highestSimilarity);
					break;
				}

				// We have a guess for that section name, save it.
				System.err.printf("// Section \"%s\" is probably (%f) missing section \"%s\".%n",
						bestMatchinSection.name, highestSimilarity, bestMatchingName);
				knownSections.remove(bestMatchingName);
				unknownSections.remove(bestMatchinSection);

				bestMatchinSection.name = bestMatchingName;
				sections_.put(bestMatchingName, bestMatchinSection);
			}
		}

		// There was a brief period of incompatibility, where version == 0x0101
		// and the packing changed, at the same time .dbg.ntvarg was introduced.
		// Once the incompatibility was noted, version was bumped to 0x0102.
		debugUnpacked_ = (header_.version == 0x0101) && !sections_.containsKey(".dbg.natives");
		
		// The .dbg.strings section is obsolete in newer binary versions.
		Section debugStringsSection = sections_.get(".dbg.strings");
		if (debugStringsSection == null)
			debugStringsSection = sections_.get(".names");

		switch (header_.compression) {
		case None: {
			// Nothing to change here. Just keep the binary bytes as is.
			break;
		}

		case Gzip: {
			byte[] bits = new byte[header_.imagesize];
			for (int i = 0; i < header_.dataoffs; i++)
				bits[i] = binary[i];

			int uncompressedSize = header_.imagesize - header_.dataoffs;
			int compressedSize = header_.disksize - header_.dataoffs;

			Inflater gzip = new Inflater(true);
			gzip.setInput(binary, header_.dataoffs + 2, compressedSize - 2);
			int actuallyUncompressed = gzip.inflate(bits, header_.dataoffs, uncompressedSize);
			if (actuallyUncompressed != uncompressedSize)
				System.err.printf("uncompressed size mismatch, bad file? expected %d, got %d\n", uncompressedSize,
						actuallyUncompressed);

			binary = bits;
			break;
		}
		}

		if (sections_.containsKey(".code")) {
			Section sc = sections_.get(".code");
			ExtendedDataInputStream br = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, sc.dataoffs, sc.size));
			long codesize = br.ReadUInt32();
			byte cellsize = br.readByte();
			byte codeversion = br.readByte();
			int flags = br.ReadInt16();
			long main = br.ReadUInt32();
			long codeoffs = br.ReadUInt32();
			byte[] codeBytes = Slice(binary, sc.dataoffs + (int) codeoffs, (int) codesize);
			code_ = new Code(codeBytes, cellsize, flags, main, (int) codeversion);
			br.close();
		}

		if (sections_.containsKey(".data")) {
			Section sc = sections_.get(".data");
			ExtendedDataInputStream br = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, sc.dataoffs, sc.size));
			long datasize = br.ReadUInt32();
			long memsize = br.ReadUInt32();
			long dataoffs = br.ReadUInt32();
			byte[] dataBytes = Slice(binary, sc.dataoffs + (int) dataoffs, (int) datasize);
			data_ = new Data(dataBytes, (int) memsize);
			br.close();
		}

		if (sections_.containsKey(".publics")) {
			Section sc = sections_.get(".publics");
			ExtendedDataInputStream br = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, sc.dataoffs, sc.size));

			// Maybe the .dbg.symbols section was inserted before this one?
			// Merge the lists.
			LinkedList<Function> functions = new LinkedList<Function>();
			if (functions_ != null)
				functions.addAll(Arrays.asList(functions_));

			int numPublics = sc.size / 8;
			publics_ = new Public[numPublics];
			publicLoop: for (int i = 0; i < numPublics; i++) {
				long address = br.ReadUInt32();
				long nameOffset = br.ReadUInt32();
				String name = ReadString(binary, sections_.get(".names").dataoffs + (int) nameOffset);
				publics_[i] = new Public(name, address);

				// Search for this function in the .dbg.symbols table.
				for (Function func : functions) {
					// This function isn't what we're looking for.
					if (func.address() != address)
						continue;

					// That function was in the .dbg.symbols table with the same name.
					// No need to add it again.
					if (name.equals(func.name()))
						continue publicLoop;

					// This is the "private name" of a non-public function in the .publics
					// section used for allowing non-public functions as callbacks.
					// "MyFunc" becomes ".1234.MyFunc"
					if (name.endsWith(func.name()) && name.matches("\\.\\d+\\..+"))
						continue publicLoop;

					// Operators are named differently in .publics and .dbg.symbols
					// "operator-(Float:,_:)" in .dbg.symbols becomes
					// ".1234.40000005-0" in .publics with the first part between the dots
					// being the address of the function again like above and
					// 40000005 being the tag_id of the left operand and 0 being
					// the tag_id of the right operand.
					Matcher pubMatcher = publicOperator.matcher(name);
					Matcher symMatcher = symbolsOperator.matcher(func.name());
					if (pubMatcher.find() && symMatcher.find()) {
						// This operator is for the same operation.
						// TODO: Check tags.
						if (pubMatcher.group(2).equals(symMatcher.group(1)))
							continue publicLoop;
					}

				}
				Function f = new Function(address, address, code().bytes().length + 1, name, null);
				functions.add(f);

			}
			// Add the public functions to the list right away.
			functions_ = functions.toArray(new Function[0]);
			br.close();
		}

		if (sections_.containsKey(".pubvars")) {
			Section sc = sections_.get(".pubvars");
			ExtendedDataInputStream br = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, sc.dataoffs, sc.size));

			// Maybe the .dbg.symbols section was inserted before this one?
			// Merge the lists.
			LinkedList<Variable> globals = new LinkedList<Variable>();
			if (globals_ != null)
				globals.addAll(Arrays.asList(globals_));

			int numPubVars = sc.size / 8;
			pubvars_ = new PubVar[numPubVars];
			pubvarLoop: for (int i = 0; i < numPubVars; i++) {
				long address = br.ReadUInt32();
				long nameOffset = br.ReadUInt32();
				String name = ReadString(binary, sections_.get(".names").dataoffs + (int) nameOffset);
				pubvars_[i] = new PubVar(name, address);

				// Search for this variable in the .dbg.symbols table.
				for (Variable glob : globals) {
					// That variable was in the .dbg.symbols table
					if (name.equals(glob.name()))
						continue pubvarLoop;
				}
				Variable v = new Variable(address, 0, null, 0, code().bytes().length, VariableType.Normal, Scope.Global,
						name, null);
				globals.add(v);
			}
			// Add the public variables to the list right away.
			globals_ = globals.toArray(new Variable[0]);
			br.close();

			// Collect the addresses of strings in structs to be able
			// to ignore them when guessing if a constant is an offset to a
			// string.
			// Can't reference those strings in the code.
			collectStructStringRanges();
		}

		if (sections_.containsKey(".natives")) {
			Section sc = sections_.get(".natives");
			ExtendedDataInputStream br = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, sc.dataoffs, sc.size));
			int numNatives = sc.size / 4;
			natives_ = new Native[numNatives];
			for (int i = 0; i < numNatives; i++) {
				long nameOffset = br.ReadUInt32();
				String name = ReadString(binary, sections_.get(".names").dataoffs + (int) nameOffset);
				natives_[i] = new Native(name, i);
			}
			br.close();
		}

		if (sections_.containsKey(".tags")) {
			Section sc = sections_.get(".tags");
			ExtendedDataInputStream br = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, sc.dataoffs, sc.size));
			int numTags = sc.size / 8;
			tags_ = new Tag[numTags];
			for (int i = 0; i < numTags; i++) {
				long tag_id = br.ReadUInt32();
				long nameOffset = br.ReadUInt32();
				String name = ReadString(binary, sections_.get(".names").dataoffs + (int) nameOffset);
				tags_[i] = new Tag(name, tag_id);
			}
			br.close();
		}

		if (sections_.containsKey(".dbg.info")) {
			Section sc = sections_.get(".dbg.info");
			ExtendedDataInputStream br = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, sc.dataoffs, sc.size));
			debugHeader_.numFiles = (int) br.ReadUInt32();
			debugHeader_.numLines = (int) br.ReadUInt32();
			debugHeader_.numSyms = (int) br.ReadUInt32();
			br.close();
		}

		if (sections_.containsKey(".dbg.files") && debugHeader_.numFiles > 0) {
			Section sc = sections_.get(".dbg.files");
			ExtendedDataInputStream br = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, sc.dataoffs, sc.size));
			debugFiles_ = new DebugFile[debugHeader_.numFiles];
			for (int i = 0; i < debugHeader_.numFiles; i++) {
				long address = br.ReadUInt32();
				long nameOffset = br.ReadUInt32();
				String name = ReadString(binary, debugStringsSection.dataoffs + (int) nameOffset);
				debugFiles_[i] = new DebugFile(name, address);
			}
			br.close();
		}

		if (sections_.containsKey(".dbg.lines") && debugHeader_.numLines > 0) {
			Section sc = sections_.get(".dbg.lines");
			ExtendedDataInputStream br = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, sc.dataoffs, sc.size));
			debugLines_ = new DebugLine[debugHeader_.numLines];
			for (int i = 0; i < debugHeader_.numLines; i++) {
				long address = br.ReadUInt32();
				long line = br.ReadUInt32();
				debugLines_[i] = new DebugLine((int) line, address);
			}
			br.close();
		}

		if (sections_.containsKey(".dbg.symbols") && debugHeader_.numSyms > 0) {
			Section sc = sections_.get(".dbg.symbols");
			ExtendedDataInputStream br = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, sc.dataoffs, sc.size));
			LinkedList<Variable> locals = new LinkedList<Variable>();

			// Merge the list with the .pubvars one
			LinkedList<Variable> globals = new LinkedList<Variable>();
			if (globals_ != null)
				globals.addAll(Arrays.asList(globals_));

			// Merge the list with the .publics one
			LinkedList<Function> functions = new LinkedList<Function>();
			if (functions_ != null)
				functions.addAll(Arrays.asList(functions_));

			for (int i = 0; i < debugHeader_.numSyms; i++) {
				long addr = br.ReadInt32();
				int tagid = br.ReadInt16();
				if (debugUnpacked_)
					br.skip(2);
				long codestart = br.ReadUInt32();
				long codeend = br.ReadUInt32();

				byte ident = br.readByte();
				byte vclassByte = br.readByte();
				Scope vclass = Scope.Local;
				if (vclassByte >= 0 && vclassByte < Scope.values().length)
					vclass = Scope.values()[vclassByte];
				int dimcount = br.ReadInt16();
				long nameOffset = br.ReadUInt32();
				String name = "";
				if (debugStringsSection.size > nameOffset)
					name = ReadString(binary, debugStringsSection.dataoffs + (int) nameOffset);

				// Someone tampered with the .dbg.symbols table :(
				if (addr == 0 || codeend == 0 || codestart > codeend || tagid < 0 || ident < 0 || vclassByte < 0
						|| vclassByte >= Scope.values().length || dimcount < 0 || dimcount > DIMEN_MAX
						|| nameOffset >= debugStringsSection.size) {
					continue;
				}

				if (ident == IDENT_FUNCTION) {
					Tag tag = tagid >= tags_.length ? null : tags_[tagid];

					// Been in .publics as well?
					Function existingFunction = null;
					for (Function func : functions) {
						// That function was in the .dbg.symbols table
						if (name.equals(func.name())) {
							existingFunction = func;
							break;
						}

						// Workaround non-public functions named like .10313.FunctionName in the
						// .publics section for callbacks
						if (func.name().endsWith(name) && func.name().matches("\\.\\d+\\..+")) {
							existingFunction = func;
							break;
						}

						// Operators are named differently in .publics and .dbg.symbols
						// "operator-(Float:,_:)" in .dbg.symbols becomes
						// ".1234.40000005-0" in .publics with the first part between the dots
						// being the address of the function again like above and
						// 40000005 being the tag_id of the left operand and 0 being
						// the tag_id of the right operand.
						Matcher pubMatcher = publicOperator.matcher(func.name());
						Matcher symMatcher = symbolsOperator.matcher(name);
						if (pubMatcher.find() && symMatcher.find()) {
							// This operator is for the same operation.
							// TODO: Check tags.
							if (pubMatcher.group(2).equals(symMatcher.group(1))) {
								existingFunction = func;
								break;
							}
						}
					}

					// This function came up already.
					if (existingFunction != null) {
						if (existingFunction.address() != addr || existingFunction.codeStart() != codestart) {
							System.err.printf(
									"// Duplicate information for symbol \"%s\" at %x with different addresses. Keeping the existing at %x.%n",
									name, addr, existingFunction.address());
							continue;
						}
						// Remove the old one from the list as this might have more info.
						functions.remove(existingFunction);
					}

					Function func = new Function((long) addr, codestart, codeend, name, tag);
					functions.add(func);
				} else {
					VariableType type = FromIdent(ident);
					Dimension[] dims = null;
					if (dimcount > 0) {
						dims = new Dimension[dimcount];
						for (int dim = 0; dim < dimcount; dim++) {
							if (debugUnpacked_)
								br.skip(2);
							short dim_tagid = br.ReadInt16();

							Tag dim_tag = dim_tagid < 0 || dim_tagid >= tags_.length ? null : tags_[dim_tagid];
							long size = br.ReadUInt32();

							dims[dim] = new Dimension(dim_tagid, dim_tag, (int) size);
						}
					}

					Tag tag = tagid < 0 || tagid >= tags_.length ? null : tags_[tagid];
					Variable var = new Variable(addr, tagid, tag, codestart, codeend, type, vclass, name, dims);
					if (vclass == Scope.Global) {
						// Been in .publics as well?
						Variable existingGlobal = null;
						for (Variable glob : globals) {
							if (name.equals(glob.name())) {
								existingGlobal = glob;
								break;
							}
						}

						// This function came up already.
						if (existingGlobal != null) {
							if (existingGlobal.address() != addr) {
								System.err.printf(
										"// Duplicate information for symbol \"%s\" with different addresses. Keeping the existing at %x.%n",
										name, existingGlobal.address());
								continue;
							}
							// Remove the old one from the list as this might have more info.
							globals.remove(existingGlobal);
						}
						globals.add(var);
					} else
						locals.add(var);
				}
			}
			br.close();

			// Fill in public functions and variables, if they're missing from the
			// .dbg.symbols table
			publicLoop: for (Public pub : publics_) {
				// Search for this function in the .dbg.symbols table.
				for (Function func : functions) {
					// That function was in the .dbg.symbols table
					// TODO: Check address as well and change the functions_ entry?
					if (pub.name().equals(func.name()))
						continue publicLoop;

					// Handle non-public functions named like .10313.FunctionName in the .publics
					// section for callbacks
					if (pub.name().endsWith(func.name()) && pub.name().matches("\\.\\d+\\..+"))
						continue publicLoop;
				}
				Function f = new Function(pub.address(), pub.address(), code().bytes().length + 1, pub.name(), null);
				functions.add(f);
			}

			publicVars: for (PubVar pub : pubvars_) {
				// Search for this variable in the .dbg.symbols table.
				for (Variable var : globals) {
					// That function was in the .dbg.symbols table
					// TODO: Check address as well and change the functions_ entry?
					if (pub.name().equals(var.name()))
						continue publicVars;
				}
				Variable var = new Variable(pub.address(), 0, null, pub.address(), code_.bytes().length,
						VariableType.Normal, Scope.Global, pub.name(), null);
				globals.add(var);
			}

			Collections.sort(globals, new Comparator<Variable>() {

				@Override
				public int compare(Variable var1, Variable var2) {
					return (int) (var1.address() - var2.address());
				}

			});
			Collections.sort(functions, new Comparator<Function>() {

				@Override
				public int compare(Function fun1, Function fun2) {
					return (int) (fun1.address() - fun2.address());
				}

			});

			variables_ = locals.toArray(new Variable[0]);
			globals_ = globals.toArray(new Variable[0]);
			functions_ = functions.toArray(new Function[0]);

			// For every function, attempt to build argument information.
			for (int i = 0; i < functions_.length; i++) {
				Function fun = functions_[i];
				int argNum = 0;
				LinkedList<Argument> args = new LinkedList<Argument>();
				do {
					Argument arg = buildArgumentInfo(fun, argNum);
					if (arg == null)
						break;
					args.add(arg);
					argNum++;
				} while (true);
				fun.setArguments(args);
			}
		}

		if (sections_.containsKey(".dbg.natives") && sections_.get(".dbg.natives").size > 0) {
			Section sc = sections_.get(".dbg.natives");
			ExtendedDataInputStream br = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, sc.dataoffs, sc.size));
			long nentries = br.ReadUInt32();
			for (int i = 0; i < (int) nentries; i++) {
				long index = br.ReadUInt32();
				long nameOffset = br.ReadUInt32();
				String name = ReadString(binary, debugStringsSection.dataoffs + (int) nameOffset);
				short tagid = br.ReadInt16();
				Tag tag = tagid >= tags_.length ? null : tags_[tagid];
				int nargs = br.ReadInt16();

				Argument[] args = new Argument[nargs];
				for (int arg = 0; arg < nargs; arg++) {
					byte ident = br.readByte();
					int arg_tagid = br.ReadInt16();
					int dimcount = br.ReadInt16();
					long argNameOffset = br.ReadUInt32();
					String argName = ReadString(binary, debugStringsSection.dataoffs + (int) argNameOffset);
					Tag argTag = arg_tagid >= tags_.length ? null : tags_[arg_tagid];
					VariableType type = FromIdent(ident);

					Dimension[] dims = null;
					if (dimcount > 0) {
						dims = new Dimension[dimcount];
						for (int dim = 0; dim < dimcount; dim++) {
							short dim_tagid = br.ReadInt16();
							Tag dim_tag = dim_tagid >= tags_.length ? null : tags_[dim_tagid];
							long size = br.ReadUInt32();
							dims[dim] = new Dimension(dim_tagid, dim_tag, (int) size);
						}
					}

					args[arg] = new Argument(type, argName, arg_tagid, argTag, dims);
				}

				if ((int) index >= natives_.length)
					continue;

				if (!natives_[(int) index].name().equals("@") && name != null
						&& !name.equals(natives_[(int) index].name()))
					System.err.printf(
							"// Error reading .dbg.natives section. Native %d has different names. (\"%s\" != \"%s\")\n",
							index, natives_[(int) index].name(), name);

				natives_[(int) index].setDebugInfo(tagid, tag, args);
			}
			br.close();
		}
	}

	public Scope getScope(byte b) {
		switch (b) {
		case 0: {
			return Scope.Global;
		}
		case 1: {
			return Scope.Local;
		}
		case 2: {
			return Scope.Static;
		}
		}
		return null;
	}

	class AddressRange {
		public long start;
		public long end;

		public AddressRange(long start, long end) {
			this.start = start;
			this.end = end;
		}
	}

	private void collectStructStringRanges() {

		for (PubVar pub : pubvars_) {
			if (pub.name().equals("myinfo")) {
				long nameOffset = int32FromData(pub.address() + 0);
				long urlOffset = int32FromData(pub.address() + 16);
				String url = stringFromData(urlOffset);
				stringRanges_.add(new AddressRange(nameOffset, urlOffset + url.length()));
				stringRanges_.add(new AddressRange(pub.address(), pub.address() + 20));
			} else if (pub.name().startsWith("__ext_") || pub.name().startsWith("__pl_")) {
				long nameOffset = int32FromData(pub.address() + 0);
				long fileOffset = int32FromData(pub.address() + 4);
				String file = stringFromData(fileOffset);
				stringRanges_.add(new AddressRange(nameOffset, fileOffset + file.length()));
				stringRanges_.add(new AddressRange(pub.address(), pub.address() + 16));
			} else if (pub.name().startsWith("__version")) {
				long fileversOffset = int32FromData(pub.address() + 4);
				long timeOffset = int32FromData(pub.address() + 12);
				String time = stringFromData(timeOffset);
				stringRanges_.add(new AddressRange(fileversOffset, timeOffset + time.length()));
				stringRanges_.add(new AddressRange(pub.address(), pub.address() + 16));
			}
		}
	}

	@Override
	public boolean IsMaybeString(long address) {
		if (!isValidDataAddress(address))
			return false;

		// Can't reference strings in public structs.
		for (AddressRange range : stringRanges_) {
			if (range.start >= address && address <= range.end)
				return false;
		}

		int len = 0;
		for (; address < data().bytes().length; address++, len++) {
			byte cell = data().bytes()[(int) address];

			if (cell == 0)
				break;

			if (!Character.isValidCodePoint(cell))
				return false;
		}

		return len > 0;
	}

	@Override
	public String stringFromData(long address) {
		return ReadString(data().bytes(), address);
	}

	@Override
	public String stringFromData(long address, int maxread) {
		return ReadStringEx(data().bytes(), (int) address, maxread);
	}

	@Override
	public int int32FromData(long address) {
		assert (address >= 0 && data().bytes().length > address);
		if (address >= 0 && data().bytes().length <= address)
			return 0;
		return BitConverter.ToInt32(data().bytes(), (int) address);
	}

	@Override
	public float floatFromData(long address) {
		return BitConverter.ToSingle(data().bytes(), address);
	}

	@Override
	public boolean PassArgCountAsSize() {
		return false;
	}

	@Override
	public Automation lookupAutomation(long automation_id) {
		return null;
	}

	@Override
	public String lookupState(short state_id, short automation_id) {
		return null;
	}

}
