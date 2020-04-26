package lysis.types.rtti;

import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;

import lysis.ExtendedDataInputStream;
import lysis.sourcepawn.SourcePawnFile;

public class TypeBuilder {
	private BufferedInputStream bufferedInput;
	private ExtendedDataInputStream dataInput;
	private boolean isConst;
	
	private final static int TYPEID_INLINE = 0;
	private final static int TYPEID_COMPLEX = 1;
	
	public static RttiType TypeFromTypeId(SourcePawnFile file, int typeid) throws IOException {
		int kind = typeid & 0xf;
		int payload = (typeid >> 4) & 0xfffffff;
		if (kind == TYPEID_INLINE) {
			byte[] array = new byte[4];
			array[0] = (byte) (payload & 0xff);
			array[1] = (byte) ((payload >> 8) & 0xff);
			array[2] = (byte) ((payload >> 16) & 0xff);
			array[3] = (byte) ((payload >> 24) & 0xff);
			ByteArrayInputStream bIn = new ByteArrayInputStream(array);
			return new TypeBuilder(file, bIn, 0).decodeNew();
		}
		else if (kind == TYPEID_COMPLEX) {
			return new TypeBuilder(file, file.getRTTIDataBytes(), payload).decodeNew();
		}
		else {
			throw new IOException("Unknown type id kind: " + kind);
		}
	}
	
	public static RttiType FunctionFromOffset(SourcePawnFile file, int offset) throws IOException {
		return new TypeBuilder(file, file.getRTTIDataBytes(), offset).decodeFunction();
	}
	
	public static RttiType TypesetFromOffset(SourcePawnFile file, int offset) throws IOException {
		return new TypeBuilder(file, file.getRTTIDataBytes(), offset).decodeTypeset();
	}
	
	public TypeBuilder(SourcePawnFile file, InputStream input, int offset) throws IOException {
		this.bufferedInput = new BufferedInputStream(input);
		this.dataInput = new ExtendedDataInputStream(this.bufferedInput);
		this.dataInput.skipBytes(offset);
	}
	
	// Decode a type, but reset the |is_const| indicator for non-
	// dependent type.
	public RttiType decodeNew() throws IOException {
		boolean wasConst = this.isConst;
		this.isConst = false;

		RttiType result = this.decode();
		if (this.isConst)
			result.setConst();

		this.isConst = wasConst;
		return result;
	}

	public RttiType decodeFunction() throws IOException {
		byte argc = dataInput.readByte();

		RttiType func = new RttiType(TypeFlag.Function);
		if (match(TypeFlag.Variadic))
			func.setVariadic();

		if (match(TypeFlag.Void))
			func.setInnerType(new RttiType(TypeFlag.Void));
		else
			func.setInnerType(decodeNew());

		for (int i = 0; i < argc; i++) {
			boolean isByRef = match(TypeFlag.ByRef);
			RttiType arg = decodeNew();
			if (isByRef)
				arg.setByRef();
			func.addArgument(arg);
		}
		return func;
	}
	
	public RttiType decodeTypeset() throws IOException {
		RttiType typeset = new RttiType(TypeFlag.Typeset);
		long count = decodeUint32();
		
		for (int i = 0; i < count; i++) {
			typeset.addArgument(decodeNew());
		}
		return typeset;
	}

	private RttiType decode() throws IOException {
		this.isConst = match(TypeFlag.Const) || this.isConst;

		byte typeFlag = this.dataInput.readByte();
		switch (typeFlag) {
		case TypeFlag.Bool:
		case TypeFlag.Int32:
		case TypeFlag.Float32:
		case TypeFlag.Char8:
		case TypeFlag.Any:
		case TypeFlag.TopFunction:
			return new RttiType(typeFlag);
		case TypeFlag.FixedArray: {
			RttiType type = new RttiType(typeFlag);
			type.setData(decodeUint32());
			type.setInnerType(decode());
			return type;
		}
		case TypeFlag.Array: {
			RttiType type = new RttiType(typeFlag);
			type.setInnerType(decode());
			return type;
		}
		case TypeFlag.Enum:
		case TypeFlag.Typedef:
		case TypeFlag.Typeset:
		case TypeFlag.Classdef:
		case TypeFlag.EnumStruct: {
			RttiType type = new RttiType(typeFlag);
			type.setData(decodeUint32());
			return type;
		}
		case TypeFlag.Function:
			return decodeFunction();
		}
		throw new IOException("Invalid RTTI type flag: " + typeFlag);
	}

	private boolean match(int flag) throws IOException {
		bufferedInput.mark(1);
		if (dataInput.readByte() != flag) {
			bufferedInput.reset();
			return false;
		}
		return true;
	}
	
	private long decodeUint32() throws IOException {
		long value = 0;
		int shift = 0;
		for (;;) {
			byte b = dataInput.readByte();
			value |= (b & 0x7f) << shift;
			if ((b & 0x80) == 0)
				break;
			shift += 7;
		}
		return value;
	}
}
