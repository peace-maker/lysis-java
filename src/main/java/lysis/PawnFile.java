package lysis;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.util.Arrays;
import java.util.LinkedList;

import lysis.amxmodx.AMXModXFile;
import lysis.lstructure.Argument;
import lysis.lstructure.Dimension;
import lysis.lstructure.Function;
import lysis.lstructure.Native;
import lysis.lstructure.Scope;
import lysis.lstructure.Tag;
import lysis.lstructure.Variable;
import lysis.lstructure.VariableType;
import lysis.sourcepawn.SourcePawnFile;
import lysis.types.rtti.RttiType;

public abstract class PawnFile {
	protected Function[] functions_;
	protected Public[] publics_;
	protected Variable[] globals_;
	protected Variable[] variables_ = new Variable[0];
	protected Tag[] tags_;

	protected Code code_;
	protected Data data_;

	protected PubVar[] pubvars_;
	protected Native[] natives_;

	protected DebugFile[] debugFiles_;
	protected DebugLine[] debugLines_;
	protected DebugHeader debugHeader_ = new DebugHeader();

	public static PawnFile FromFile(String path) throws Exception {
		FileInputStream fs = new FileInputStream(path);
		ByteArrayOutputStream bytes = new ByteArrayOutputStream();
		int b;
		while ((b = fs.read()) >= 0)
			bytes.write(b);
		fs.close();
		byte[] vec = bytes.toByteArray();
		long magic = BitConverter.ToUInt32(vec, 0);
		if (magic == SourcePawnFile.MAGIC)
			return new SourcePawnFile(vec);
		if (magic == AMXModXFile.MAGIC2)
			return new AMXModXFile(vec);
		throw new Exception("not a .amxx or .smx file!");
	}

	public abstract String stringFromData(long address);

	public abstract String stringFromData(long address, int maxread);

	public abstract float floatFromData(long address);

	public abstract int int32FromData(long address);

	public boolean isValidDataAddress(long address) {
		return address >= 0 && address < DAT().length;
	}

	protected Tag findTag(long tag_id) {
		for (int i = 0; i < tags_.length; i++) {
			if (tags_[i].tag_id() == tag_id)
				return tags_[i];
		}
		return null;
	}

	protected Tag findTag(String name) {
		for (int i = 0; i < tags_.length; i++) {
			if (name.equals(tags_[i].name()))
				return tags_[i];
		}
		return null;
	}

	protected Tag findOrCreateTag(String name) {
		return addTag(name, tags_[tags_.length - 1].tag_id() + 1);
	}

	protected Tag addTag(String name, long tag_id) {
		Tag tag = findTag(name);
		if (tag != null) {
			assert (tag.tag_id() == tag_id);
			return tag;
		}
		tag = findTag(tag_id);
		if (tag != null) {
			assert (name.equals(tag.name()));
			return tag;
		}

		tag = new Tag(name, tag_id);
		tags_ = Arrays.copyOf(tags_, tags_.length + 1);
		tags_[tags_.length - 1] = tag;
		return tag;
	}

	public Function lookupFunction(long pc) {
		for (int i = 0; i < functions_.length; i++) {
			Function f = functions_[i];
			if (pc >= f.codeStart() && pc < f.codeEnd())
				return f;
		}
		return null;
	}

	public Public lookupPublic(String name) {
		for (int i = 0; i < publics_.length; i++) {
			if (publics_[i].name() == name)
				return publics_[i];
		}
		return null;
	}

	public Public lookupPublic(long addr) {
		for (int i = 0; i < publics_.length; i++) {
			if (publics_[i].address() == addr)
				return publics_[i];
		}
		return null;
	}

	public String lookupFile(long address) {
		if (debugFiles_ == null)
			return null;

		int high = debugFiles_.length;
		int low = -1;

		while (high - low > 1) {
			int mid = (low + high) >> 1;
			if (debugFiles_[mid].address() <= address)
				low = mid;
			else
				high = mid;
		}
		if (low == -1)
			return null;
		return debugFiles_[low].name();
	}

	public int lookupLine(long address) {
		if (debugLines_ == null)
			return -1;

		int high = debugLines_.length;
		int low = -1;

		while (high - low > 1) {
			int mid = (low + high) >> 1;
			if (debugLines_[mid].address() <= address)
				low = mid;
			else
				high = mid;
		}
		if (low == -1)
			return -1;
		return debugLines_[low].line();
	}

	public Variable lookupDeclarations(long pc, StupidWrapper i, Scope scope) {
		for (i.i++; i.i < variables_.length; i.i++) {
			Variable var = variables_[i.i];
			if (pc != var.codeStart())
				continue;
			if (var.scope() == scope)
				return var;
		}
		return null;
	}

	public Variable lookupDeclarations(long pc, StupidWrapper i) {
		return lookupDeclarations(pc, i, Scope.Local);
	}

	public Variable lookupVariable(long pc, long offset, Scope scope) {
		for (int i = 0; i < variables_.length; i++) {
			Variable var = variables_[i];
			if ((pc >= var.codeStart() && pc < var.codeEnd()) && (offset == var.address() && var.scope() == scope)) {
				return var;
			}
		}
		return null;
	}

	public Variable lookupVariable(long pc, long offset) {
		return lookupVariable(pc, offset, Scope.Local);
	}

	public Variable lookupGlobal(long address) {
		for (int i = 0; i < globals_.length; i++) {
			Variable var = globals_[i];
			if (var.address() == address)
				return var;
		}
		return null;
	}

	public Function addFunction(long addr) {
		for (int i = 0; i < functions_.length; i++) {
			// This function already exists.
			if (functions_[i].address() == addr)
				return functions_[i];
		}

		functions_ = Arrays.copyOf(functions_, functions_.length + 1);
		Function f = new Function(addr, addr, code().bytes().length + 1, "sub_" + Long.toHexString(addr), 0);
		functions_[functions_.length - 1] = f;
		return f;
	}

	public boolean addArgumentDummyVar(Function func, int num) {
		long varAddr = 12 + num * 4;

		// Variable already exists.
		if (lookupVariable(func.address(), varAddr) != null)
			return false;

		Variable var = new Variable(varAddr, 0, null, func.codeStart(), func.codeEnd(),
				VariableType.Normal, Scope.Local, "_arg" + num, null);
		variables_ = Arrays.copyOf(variables_, variables_.length + 1);
		variables_[variables_.length - 1] = var;
		return true;
	}

	public Argument buildArgumentInfo(Function func, int argNum) {
		int argOffset = 12 + 4 * argNum;

		Variable var = lookupVariable(func.address(), argOffset);
		if (var == null)
			return null;

		return new Argument(var.type(), var.name(), (int) var.tag_id(), var.tag(), var.dims());
	}

	public void addGlobal(long addr) {
		// This global variable already exists.
		if (lookupGlobal(addr) != null)
			return;

		for (int i = 0; i < variables_.length; i++) {
			Variable var = variables_[i];
			// This variable already exists as a static variable
			if (addr == var.address() && var.scope() == Scope.Static)
				return;
		}

		globals_ = Arrays.copyOf(globals_, globals_.length + 1);
		globals_[globals_.length - 1] = new Variable(addr, 0, null, 0, code().bytes().length, VariableType.Normal,
				Scope.Global, "g_var" + Long.toHexString(addr), null);
	}

	public Function[] functions() {
		return functions_;
	}

	public Public[] publics() {
		return publics_;
	}

	public Variable[] globals() {
		return globals_;
	}

	public Code code() {
		return code_;
	}

	public Data data() {
		return data_;
	}

	public PubVar[] pubvars() {
		return pubvars_;
	}

	public Native[] natives() {
		return natives_;
	}

	public byte[] DAT() {
		return data().bytes();
	}

	public abstract boolean PassArgCountAsSize();

	public abstract Automation lookupAutomation(long state_addr);

	public abstract String lookupState(short state_id, short automation_id);

	protected static byte[] Slice(byte[] bytes, int offset, int length) {
		byte[] shadow = new byte[length];
		for (int i = 0; i < length; i++)
			shadow[i] = bytes[offset + i];
		return shadow;
	}

	// Generic structures mostly shared between sp and amxx.
	public class DebugHeader {
		public int numFiles;
		public int numLines;
		public int numSyms;
	}

	public class Code {
		private byte[] code_;
		private byte cellsize_;
		private int flags_;
		private long main_;
		private int version_;

		public Code(byte[] code, byte cellsize, int flags, long main, int version) {
			code_ = code;
			cellsize_ = cellsize;
			flags_ = flags;
			main_ = main;
			version_ = version;
		}

		public byte[] bytes() {
			return code_;
		}

		public byte cellsize() {
			return cellsize_;
		}

		public int flags() {
			return flags_;
		}

		public long main() {
			return main_;
		}

		public int version() {
			return version_;
		}
	}

	public class Data {
		private byte[] data_;
		private int memory_;

		public Data(byte[] data, int memory) {
			data_ = data;
			memory_ = memory;
		}

		public byte[] bytes() {
			return data_;
		}

		public int memory() {
			return memory_;
		}
	}

	public class PubVar {
		private long address_;
		private String name_;

		public PubVar(String name, long address) {
			name_ = name;
			address_ = address;
		}

		public String name() {
			return name_;
		}

		public long address() {
			return address_;
		}
	}

	public class DebugFile {
		private long address_;
		private String name_;

		public DebugFile(String name, long address) {
			name_ = name;
			address_ = address;
		}

		public String name() {
			return name_;
		}

		public long address() {
			return address_;
		}

		@Override
		public String toString() {
			return String.format("File %s @ %x", name_, address_);
		}
	}

	public class DebugLine {
		private long address_;
		private int line_;

		public DebugLine(int line, long address) {
			line_ = line;
			address_ = address;
		}

		public int line() {
			return line_;
		}

		public long address() {
			return address_;
		}

		@Override
		public String toString() {
			return String.format("Line %d @ %x", line_, address_);
		}
	}

	public class Automation {
		private short automation_id_;
		private long address_;
		private String name_;

		public Automation(short automation_id, long address, String name) {
			this.automation_id_ = automation_id;
			this.address_ = address;
			this.name_ = name;
		}

		public short automation_id() {
			return automation_id_;
		}

		public long address() {
			return address_;
		}

		public String name() {
			return name_;
		}

		@Override
		public String toString() {
			return String.format("Automation %d @ %x : %s", automation_id_, address_, name_);
		}
	}

	public class State {
		private short state_id_;
		private short automation_id_;
		private String name_;

		public State(short state_id, short automation_id, String name) {
			this.state_id_ = state_id;
			this.automation_id_ = automation_id;
			this.name_ = name;
		}

		public short state_id() {
			return state_id_;
		}

		public short automation_id() {
			return automation_id_;
		}

		public String name() {
			return name_;
		}

		@Override
		public String toString() {
			return String.format("State %d of automation %d : %s", state_id_, automation_id_, name_);
		}
	}

	public abstract boolean IsMaybeString(long address);
}
