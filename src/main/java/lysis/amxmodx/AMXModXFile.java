package lysis.amxmodx;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedList;
import java.util.List;
import java.util.Stack;
import java.util.zip.Inflater;

import lysis.BitConverter;
import lysis.ExtendedDataInputStream;
import lysis.PawnFile;
import lysis.Public;
import lysis.lstructure.Argument;
import lysis.lstructure.Dimension;
import lysis.lstructure.Function;
import lysis.lstructure.Native;
import lysis.lstructure.Scope;
import lysis.lstructure.Tag;
import lysis.lstructure.Variable;
import lysis.lstructure.VariableType;

public class AMXModXFile extends PawnFile {

	public final static long MAGIC2 = 0x414D5858;
	public final static long MAGIC2_VERSION = 0x0300;
	public final static long AMX_MAGIC = 0xE0F1;
	public final static long AMX_DBG_MAGIC = 0xEFF1;
	public final static long MIN_FILE_VERSION = 6;
	public final static long MIN_DEBUG_FILE_VERSION = 8;
	public final static long CUR_FILE_VERSION = 8;
	public final static int DEFSIZE = 8;
	public final static int AMX_FLAG_DEBUG = 0x2;
	public final static int AMX_FLAG_COMPACT = 0x4;
	public final static byte IDENT_VARIABLE = 1;
	public final static byte IDENT_REFERENCE = 2;
	public final static byte IDENT_ARRAY = 3;
	public final static byte IDENT_REFARRAY = 4;
	public final static byte IDENT_FUNCTION = 9;
	public final static byte IDENT_VARARGS = 11;

	private final static long Q_USER_TAG_STRING = 100500;

	public class PluginHeader {
		public byte cellsize;
		public int disksize;
		public int imagesize;
		public int memsize;
		public int offset;
	}

	private class AMX_HEADER {
		public int size; /* size of the "file" */
		public int magic; /* signature */
		public byte file_version; /* file format version */
		public byte amx_version; /* required version of the AMX */
		public short flags;
		public short defsize; /* size of a definition record */
		public int cod; /* initial value of COD - code block */
		public int dat; /* initial value of DAT - data block */
		public int hea; /* initial value of HEA - start of the heap */
		public int stp; /* initial value of STP - stack top */
		public int cip; /* initial value of CIP - the instruction pointer */
		public int publics; /* offset to the "public functions" table */
		public int natives; /* offset to the "native functions" table */
		public int libraries; /* offset to the table of libraries */
		public int pubvars; /* the "public variables" table */
		public int tags; /* the "public tagnames" table */
		public int nametable; /* name table */
	}

	private class AMX_DEBUG_HDR {
		public int size; /* size of the debug information chunk */
		public int magic; /* signature, must be 0xf1ef */
		public byte file_version; /* file format version */
		public byte amx_version; /* required version of the AMX */
		public short flags; /* currently unused */
		public short files; /* number of entries in the "file" table */
		public short lines; /* number of entries in the "line" table */
		public short symbols; /* number of entries in the "symbol" table */
		public short tags; /* number of entries in the "tag" table */
		public short automatons; /* number of entries in the "automaton" table */
		public short states; /* number of entries in the "state" table */

		public final static int SIZE = 4 + 2 + (1 * 2) + (2 * 7);
	}

	private Variable[] allvars_;
	private Tag stringTag;
	private Automation[] automations_;
	private State[] states_;

	public AMXModXFile(byte[] binary) throws Exception {
		ExtendedDataInputStream reader = new ExtendedDataInputStream(new ByteArrayInputStream(binary));
		long magic = reader.ReadUInt32();

		if (magic == MAGIC2) {
			int version = reader.ReadUInt16();
			if (version > MAGIC2_VERSION)
				throw new Exception("unexpected version");

			PluginHeader ph = null;
			byte numPlugins = reader.readByte();
			for (byte i = 0; i < numPlugins; i++) {
				PluginHeader p = new PluginHeader();
				p.cellsize = reader.readByte();
				p.disksize = reader.ReadInt32();
				p.imagesize = reader.ReadInt32();
				p.memsize = reader.ReadInt32();
				p.offset = reader.ReadInt32();
				if (p.cellsize == 4) {
					ph = p;
					break;
				}
			}
			if (ph == null)
				throw new Exception("could not find applicable cell size");

			int bufferSize = ph.imagesize > ph.memsize ? ph.imagesize + 1 : ph.memsize + 1;
			byte[] bits = new byte[bufferSize];

			Inflater gzip = new Inflater(true);
			gzip.setInput(binary, ph.offset + 2, ph.disksize - 2);
			int read = gzip.inflate(bits, 0, bufferSize);
			if (read != ph.imagesize)
				System.err.printf("uncompressed size mismatch, bad file? expected %d, got %d\n", ph.imagesize, read);

			binary = bits;
		} else {
			throw new Exception("unrecognized file");
		}

		reader.close();
		reader = new ExtendedDataInputStream(new ByteArrayInputStream(binary));
		AMX_HEADER amx = new AMX_HEADER();
		amx.size = reader.ReadInt32();
		amx.magic = reader.ReadUInt16();
		amx.file_version = reader.readByte();
		amx.amx_version = reader.readByte();
		amx.flags = reader.ReadInt16();
		amx.defsize = reader.ReadInt16();
		amx.cod = reader.ReadInt32();
		amx.dat = reader.ReadInt32();
		amx.hea = reader.ReadInt32();
		amx.stp = reader.ReadInt32();
		amx.cip = reader.ReadInt32();
		amx.publics = reader.ReadInt32();
		amx.natives = reader.ReadInt32();
		amx.libraries = reader.ReadInt32();
		amx.pubvars = reader.ReadInt32();
		amx.tags = reader.ReadInt32();
		amx.nametable = reader.ReadInt32();

		if (amx.magic != AMX_MAGIC)
			throw new Exception(String.format("unrecognized amx header %x", amx.magic));

		if (amx.file_version < MIN_FILE_VERSION || amx.file_version > CUR_FILE_VERSION) {
			throw new Exception("unrecognized amx version");
		}

		if (amx.defsize != DEFSIZE)
			throw new Exception("unrecognized header defsize");

		if (amx.publics > 0) {
			int count = (amx.natives - amx.publics) / DEFSIZE;
			publics_ = new Public[count];
			ExtendedDataInputStream r = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, amx.publics, count * DEFSIZE));
			for (int i = 0; i < publics_.length; i++) {
				long address = r.ReadUInt32();
				int nameoffset = r.ReadInt32();
				String name = ReadName(binary, nameoffset);
				publics_[i] = new Public(name, address);
			}
			r.close();
		}

		assert ((amx.flags & AMX_FLAG_COMPACT) == AMX_FLAG_COMPACT || amx.size == amx.hea);
		if ((amx.flags & AMX_FLAG_COMPACT) == AMX_FLAG_COMPACT) {
			binary = decompressCompactCode(amx, binary);
		}

		// .CODE
		{
			byte[] codeBytes = Slice(binary, amx.cod, amx.dat - amx.cod);
			code_ = new Code(codeBytes, (byte) 0, 0, 0, 0);
		}

		// .DATA
		{
			byte[] dataBytes = Slice(binary, amx.dat, amx.hea - amx.dat);
			data_ = new Data(dataBytes, amx.hea - amx.dat);
		}

		// .NATIVES
		if (amx.natives > 0) {
			int count = (amx.libraries - amx.natives) / DEFSIZE;
			natives_ = new Native[count];
			ExtendedDataInputStream r = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, amx.natives, count * DEFSIZE));
			for (int i = 0; i < count; i++) {
				r.ReadUInt32(); // Address
				int nameoffset = r.ReadInt32();
				String name = ReadName(binary, nameoffset);
				natives_[i] = new Native(name, i);
			}
			r.close();
		}

		// .PUBVARS
		if (amx.pubvars > 0) {
			int count = (amx.tags - amx.pubvars) / DEFSIZE;
			pubvars_ = new PubVar[count];
			ExtendedDataInputStream r = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, amx.pubvars, count * DEFSIZE));
			for (int i = 0; i < count; i++) {
				long address = r.ReadUInt32();
				int nameoffset = r.ReadInt32();
				String name = ReadName(binary, nameoffset);
				pubvars_[i] = new PubVar(name, address);
			}
			r.close();
		}

		// Debug stuff.
		if (amx.file_version >= MIN_DEBUG_FILE_VERSION && (amx.flags & AMX_FLAG_DEBUG) == AMX_FLAG_DEBUG) {
			ExtendedDataInputStream r = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, amx.hea, AMX_DEBUG_HDR.SIZE));
			AMX_DEBUG_HDR dbg = new AMX_DEBUG_HDR();
			dbg.size = r.ReadInt32();
			dbg.magic = r.ReadUInt16();
			dbg.file_version = r.readByte();
			dbg.amx_version = r.readByte();
			dbg.flags = r.ReadInt16();
			dbg.files = r.ReadInt16();
			dbg.lines = r.ReadInt16();
			dbg.symbols = r.ReadInt16();
			dbg.tags = r.ReadInt16();
			dbg.automatons = r.ReadInt16();
			dbg.states = r.ReadInt16();

			if (dbg.magic != AMX_DBG_MAGIC)
				throw new Exception("unrecognized debug magic");

			r = new ExtendedDataInputStream(
					new ByteArrayInputStream(binary, amx.hea + AMX_DEBUG_HDR.SIZE, dbg.size - AMX_DEBUG_HDR.SIZE));

			// Fill sp struct
			debugHeader_.numFiles = dbg.files;
			debugHeader_.numLines = dbg.lines;
			debugHeader_.numSyms = dbg.symbols;

			// Read files.
			debugFiles_ = new DebugFile[dbg.files];
			for (short i = 0; i < dbg.files; i++) {
				long offset = r.ReadUInt32();
				String name = ReadName(r);
				debugFiles_[i] = new DebugFile(name, offset);
				// System.out.println(i + ": " + debugFiles_[i]);
			}

			// Read lines.
			debugLines_ = new DebugLine[dbg.lines];
			for (short i = 0; i < dbg.lines; i++) {
				long offset = r.ReadUInt32();
				int lineno = r.ReadInt32();
				debugLines_[i] = new DebugLine(lineno, offset);
				// System.out.println(i + ": " + debugLines_[i]);
			}

			List<Function> functions = new LinkedList<Function>();
			List<Variable> globals = new LinkedList<Variable>();
			List<Variable> locals = new LinkedList<Variable>();
			List<Variable> allvars = new LinkedList<Variable>();

			// Read symbols.
			for (short i = 0; i < dbg.symbols; i++) {
				int addr = r.ReadInt32();
				int tagid = r.ReadUInt16();
				long codestart = r.ReadUInt32();
				long codeend = r.ReadUInt32();
				byte ident = r.readByte();
				byte vclassByte = r.readByte();
				Scope vclass = Scope.Local;
				if (vclassByte >= 0 && vclassByte < Scope.values().length)
					vclass = Scope.values()[vclassByte];
				int dimcount = r.ReadInt16();
				String name = ReadName(r);
				// System.out.printf("addr %x, tagid %x, codestart %x, codeend %x, ident %x,
				// vclass %x, dimcount %d, name %s%n", addr, tagid, codestart, codeend, ident,
				// vclassByte, dimcount, name);

				if (ident == IDENT_FUNCTION) {
					Function func = new Function(addr, codestart, codeend, name, tagid);
					functions.add(func);
				} else {
					VariableType type = FromIdent(ident);
					Dimension[] dims = null;
					if (dimcount > 0) {
						dims = new Dimension[dimcount];
						for (int j = 0; j < dimcount; j++) {
							short tag_id = r.ReadInt16();
							int size = r.ReadInt32();
							dims[j] = new Dimension(tag_id, null, size);
						}
					}

					Variable var = new Variable(addr, tagid, null, codestart, codeend, type, vclass, name, dims);
					if (vclass == Scope.Global)
						globals.add(var);
					else
						locals.add(var);
				}
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

			allvars.addAll(locals);
			allvars.addAll(globals);
			Collections.sort(allvars, new Comparator<Variable>() {
				@Override
				public int compare(Variable var1, Variable var2) {
					return (int) (var1.address() - var2.address());
				}
			});

			variables_ = locals.toArray(new Variable[0]);
			globals_ = globals.toArray(new Variable[0]);
			functions_ = functions.toArray(new Function[0]);
			allvars_ = allvars.toArray(new Variable[0]);

			// Find tags.
			tags_ = new Tag[dbg.tags + 1];
			for (short i = 0; i < dbg.tags; i++) {
				int tag_id = r.ReadUInt16();
				String name = ReadName(r);
				tags_[i] = new Tag(name, tag_id);

				// System.out.printf("%d: %s%n", i, tags_[i]);
			}

			// Automations
			automations_ = new Automation[dbg.automatons];
			for (short i = 0; i < dbg.automatons; i++) {
				short automation_id = r.ReadInt16();
				int addr = r.ReadInt32(); // address of state variable
				String name = ReadName(r);
				automations_[i] = new Automation(automation_id, addr, name);

				// System.out.printf("%d: %s%n", i, automations_[i]);
			}

			// States.
			states_ = new State[dbg.states];
			for (short i = 0; i < dbg.states; i++) {
				short state_id = r.ReadInt16();
				short automation_id = r.ReadInt16();
				String name = ReadName(r);
				states_[i] = new State(state_id, automation_id, name);

				// System.out.printf("%d: %s%n", i, states_[i]);
			}

			stringTag = new Tag("String", Q_USER_TAG_STRING);
			tags_[dbg.tags] = stringTag;

			// Update symbols.
			for (int i = 0; i < functions_.length; i++)
				functions_[i].setTag(findTag(functions_[i].tag_id()));
			for (int i = 0; i < variables_.length; i++)
				variables_[i].setTag(findTag(variables_[i].tag_id(), variables_[i]));
			for (int i = 0; i < globals_.length; i++)
				globals_[i].setTag(findTag(globals_[i].tag_id(), globals_[i]));

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
	}

	@Override
	public Argument buildArgumentInfo(Function func, int argNum) {
		int argOffset = 12 + 4 * argNum;

		Variable var = lookupVariable(func.address(), argOffset);
		if (var == null)
			return null;

		// Add string tag to possible string arguments.
		if (var.type() == VariableType.ArrayReference && var.dims() != null && var.dims().length == 1
				&& var.dims()[0].size() == 0 && var.tag() != null && var.tag().name() == "_") {
			var.setTag(stringTag);
			var.setTagId(Q_USER_TAG_STRING);
		}

		return new Argument(var.type(), var.name(), (int) var.tag().tag_id(), var.tag(), var.dims());
	}

	private static String ReadName(byte[] bytes, int offset) {
		int count = offset;
		for (; count < bytes.length; count++) {
			if (bytes[count] == 0)
				break;
		}
		try {
			return new String(bytes, offset, count - offset, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}

		return null;
	}

	private static String ReadName(DataInputStream r) throws IOException {
		LinkedList<Byte> buffer = new LinkedList<>();
		do {
			byte b = r.readByte();
			if (b == 0)
				break;
			buffer.add(b);
		} while (true);

		try {
			byte[] bytes = new byte[buffer.size()];
			for (int i = 0; i < bytes.length; i++)
				bytes[i] = buffer.get(i);

			return new String(bytes, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}

		return null;
	}

	private static String ReadString(byte[] bytes, int offset) {
		List<Byte> buffer = new LinkedList<>();
		int count = offset;
		for (; count < bytes.length; count += 4) {
			if (bytes[count] == 0)
				break;
			int cell = BitConverter.ToInt32(bytes, count);
			buffer.add((byte) cell);
		}
		try {
			byte[] chars = new byte[buffer.size()];
			for (int i = 0; i < chars.length; i++)
				chars[i] = buffer.get(i);

			return new String(chars, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}

		return null;
	}

	private static String ReadStringEx(byte[] bytes, int offset, int maxread) {
		List<Byte> buffer = new LinkedList<>();
		int count = offset;
		int last = count + maxread;
		for (; count < bytes.length && count <= last; count += 4) {
			if (bytes[count] == 0)
				break;
			int cell = BitConverter.ToInt32(bytes, count);
			buffer.add((byte) cell);
		}

		try {
			byte[] chars = new byte[buffer.size()];
			for (int i = 0; i < chars.length; i++)
				chars[i] = buffer.get(i);

			return new String(chars, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}

		return null;
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

	private Tag findTag(long tag_id, Variable var) {
		Tag tag = findTag(tag_id);

		if ("_".equals(tag.name()))
			return tag;

		Tag maybe = findTagString(var);
		if (maybe != null)
			return maybe;

		return tag;
	}

	private Tag findTagString(Variable var) {
		if (var.scope() == Scope.Local)
			return null;

		if (var.dims() == null)
			return null;

		if (var.dims().length == 1 && (var.type() == VariableType.ArrayReference || var.type() == VariableType.Array
				|| var.type() == VariableType.Reference)) {

			long size = 0;
			for (int i = 0; i < allvars_.length - 1; i++) {
				if (allvars_[i] != var)
					continue;

				size = allvars_[i + 1].address() - var.address();
			}

			// last string not detected
			if (size <= 0)
				return null;

			int end = (int) (var.address() + size - 1);

			if (DAT()[end] != 0)
				return null;

			// See if it contains only valid characters.
			int addr = (int) var.address();
			for (; addr < DAT().length && addr < end && DAT()[addr] != 0; addr += 4) {
				int cell = BitConverter.ToInt32(DAT(), addr);
				if (!Character.isValidCodePoint(cell))
					return null;
			}

			// Null character in the middle of the string.
			if (addr != end)
				return null;

			return stringTag;
		}

		return null;
	}

	@Override
	public boolean IsMaybeString(long address) {
		if (!isValidDataAddress(address))
			return false;

		// See if we're in the middle of a string.
		// Don't allow addressing of strings other than the from the beginning.
		// Better to miss some strings than to have too many false positives.
		if (address >= 4) {
			int cell = BitConverter.ToInt32(DAT(), (int) (address - 4));
			if (cell > 0 && Character.isValidCodePoint(cell))
				return false;
		}

		int len = 0;
		for (; address < DAT().length; address += 4, len++) {
			int cell = BitConverter.ToInt32(DAT(), (int) address);

			if (cell == 0)
				break;

			if (!Character.isValidCodePoint(cell))
				return false;
		}

		return len > 1;
	}

	// https://github.com/alliedmodders/amxmodx/blob/e95099817b1383fe5d9c797f761017a862fa8a97/amxmodx/amx.cpp#L786
	public byte[] decompressCompactCode(AMX_HEADER amx, byte[] binary) throws IOException {
		ByteArrayOutputStream out = new ByteArrayOutputStream(binary.length);
		// Copy everything before the compressed code section of the file.
		out.write(binary, 0, amx.cod);

		int codesize = amx.size - amx.cod;
		byte[] code = Slice(binary, amx.cod, codesize);

		Stack<Long> stack = new Stack<>();
		long c;
		short shift;
		while (codesize > 0) {
			c = 0;
			shift = 0;

			do {
				codesize--;
				// no input byte should be shifted out completely
				assert (shift < 8 * 4);
				// we work from the end of a sequence backwards; the final code in
				// a sequence may not have the continuation bit set
				assert (shift > 0 || (code[codesize] & 0x80) == 0);
				c |= (code[codesize] & 0x7f) << shift;
				shift += 7;
			} while (codesize > 0 && (code[codesize - 1] & 0x80) != 0);

			// sign expand
			if ((code[codesize] & 0x40) != 0) {
				while (shift < 8 * 4) {
					c |= 0xff << shift;
					shift += 8;
				}
			}

			// store
			stack.push(c);
		}

		// Write the expanded opcodes back.
		while (!stack.empty())
			out.write(IntToBigEndianByteArray(stack.pop()));

		// Copy all the remaining data.
		out.write(binary, amx.size, binary.length - amx.size);

		return out.toByteArray();
	}

	private byte[] IntToBigEndianByteArray(long value) {
		byte[] bytes = new byte[4];
		bytes[0] = (byte) (value >> 0);
		bytes[1] = (byte) (value >> 8);
		bytes[2] = (byte) (value >> 16);
		bytes[3] = (byte) (value >> 24);
		return bytes;
	}

	@Override
	public String stringFromData(long address) {
		return ReadString(DAT(), (int) address);
	}

	@Override
	public String stringFromData(long address, int maxread) {
		return ReadStringEx(DAT(), (int) address, maxread);
	}

	@Override
	public float floatFromData(long address) {
		return BitConverter.ToSingle(DAT(), address);
	}

	@Override
	public int int32FromData(long address) {
		assert (address >= 0 && DAT().length > address);
		if (address >= 0 && DAT().length <= address)
			return 0;
		return BitConverter.ToInt32(DAT(), (int) address);
	}

	@Override
	public boolean PassArgCountAsSize() {
		return true;
	}

	@Override
	public Automation lookupAutomation(long state_addr) {
		for (Automation auto : automations_) {
			if (auto.address() == state_addr)
				return auto;
		}
		return null;
	}

	@Override
	public String lookupState(short state_id, short automation_id) {
		for (State state : states_) {
			if (state.automation_id() == automation_id && state.state_id() == state_id)
				return state.name();
		}
		return null;
	}

}
