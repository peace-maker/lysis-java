package lysis.types.rtti;

import java.util.ArrayList;
import java.util.List;

import lysis.lstructure.VariableType;

public class RttiType {
	private boolean isConst_;
	private boolean isVariadic_;
	private boolean isByRef_;
	private byte typeflag_;
	private long data_;
	private RttiType innerType_;
	private ArrayList<RttiType> arguments_;
	
	public RttiType(byte typeflag) {
		this.typeflag_ = typeflag;
		this.data_ = 0;
		this.isConst_ = false;
		this.isVariadic_ = false;
		this.isByRef_ = false;
		this.arguments_ = new ArrayList<>();
	}
	
	public byte getTypeFlag() {
		return typeflag_;
	}
	
	public boolean isArrayType() {
		return typeflag_ == TypeFlag.Array || typeflag_ == TypeFlag.FixedArray;
	}
	
	public boolean isString() {
		return getArrayBaseType().getTypeFlag() == TypeFlag.Char8;
	}
	
	public boolean isFloat() {
		return getArrayBaseType().getTypeFlag() == TypeFlag.Float32;
	}
	
	public RttiType getArrayBaseType() {
		RttiType type = this;
		while (type.isArrayType())
			type = type.getInnerType();
		return type;
	}
	
	public void setConst() {
		isConst_ = true;
	}
	
	public boolean isConst() {
		return isConst_;
	}
	
	public void setVariadic() {
		isVariadic_ = true;
	}
	
	public boolean isVariadic() {
		return isVariadic_;
	}
	
	public void setByRef() {
		isByRef_ = true;
	}
	
	public boolean isByRef() {
		return isByRef_;
	}
	
	public void setInnerType(RttiType inner) {
		innerType_ = inner;
	}
	
	public RttiType getInnerType() {
		return innerType_;
	}
	
	public void addArgument(RttiType arg) {
		arguments_.add(arg);
	}
	
	public List<RttiType> getArguments() {
		return arguments_;
	}
	
	public void setData(long data) {
		data_ = data;
	}
	
	public long getData() {
		return data_;
	}
	
	public VariableType toVariableType() {
		if (isVariadic_)
			return VariableType.Variadic;
		if (isArrayType()) {
			if (isByRef_)
				return VariableType.ArrayReference;
			return VariableType.Array;
		}
		if (isByRef_)
			return VariableType.Reference;
		return VariableType.Normal;
	}
	
	public String toString() {
		String attributes = "";
		if (isConst_)
			attributes += "const ";
		if (isByRef_)
			attributes += "&";
		
		switch (typeflag_) {
		case TypeFlag.Bool:
			return attributes + "bool";
		case TypeFlag.Int32:
			return attributes + "int";
		case TypeFlag.Float32:
			return attributes + "float";
		case TypeFlag.Char8:
			return attributes + "char";
		case TypeFlag.Any:
			return attributes + "any";
		case TypeFlag.TopFunction:
			return attributes + "Function";
		case TypeFlag.Void:
			return attributes + "void";
		case TypeFlag.FixedArray:
			return attributes + innerType_ + "[" + data_ + "]";
		case TypeFlag.Array:
			return attributes + innerType_ + "[]";
		case TypeFlag.Enum:
			return attributes + "<enum " + data_ + ">";
		case TypeFlag.Typedef:
			return attributes + "<typedef " + data_ + ">";
		case TypeFlag.Typeset:
			return attributes + "<typeset " + data_ + ">";
		case TypeFlag.Classdef:
			return attributes + "<classdef " + data_ + ">";
		case TypeFlag.EnumStruct:
			return attributes + "<enumstruct " + data_ + ">";
		case TypeFlag.Function:
			String signature = "function " + innerType_ + "(";
			for (int i = 0; i < arguments_.size(); i++) {
				if (i > 0)
					signature += ", ";
				signature += arguments_.get(i);
			}
			if (isVariadic_)
				signature += "...";
			signature += ")";
			return signature;
		}
		return "<invalid type " + typeflag_ + ">";
	}
}
