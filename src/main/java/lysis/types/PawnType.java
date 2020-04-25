package lysis.types;

import lysis.lstructure.Tag;
import lysis.sourcepawn.OpcodeHelpers;
import lysis.types.rtti.RttiType;
import lysis.types.rtti.TypeFlag;

public class PawnType {
	private CellType type_;
	private Tag tag_;

	public boolean equalTo(PawnType other) {
		return type_ == other.type_ && tag_ == other.tag_;
	}

	public CellType type() {
		return type_;
	}

	public Tag tag() {
		return tag_;
	}

	public PawnType(Tag tag) {
		if (tag == null || tag.name().equals("_")) {
			type_ = CellType.None;
			tag_ = null;
		} else if (tag.isFloat()) {
			type_ = CellType.Float;
			tag_ = null;
		} else if (tag.isBoolean()) {
			type_ = CellType.Bool;
			tag_ = null;
		} else if (tag.isFunction()) {
			type_ = CellType.Function;
			tag_ = null;
		} else {
			type_ = CellType.Tag;
			tag_ = tag;
		}
	}
	
	public PawnType(RttiType type) {
		// Ignore array dimensions and get the base type of the array.
		while (type.isArrayType())
			type = type.getInnerType();

		tag_ = null;
		switch (type.getTypeFlag()) {
		case TypeFlag.Bool:
			type_ = CellType.Bool;
			break;
		case TypeFlag.Char8:
			type_ = CellType.Character;
			break;
		case TypeFlag.Float32:
			type_ = CellType.Float;
			break;
		case TypeFlag.TopFunction:
			type_ = CellType.Function;
			break;
		//case TypeFlag.Int32:
		default:
			type_ = CellType.None;
			break;
		}
	}

	public PawnType(CellType type) {
		type_ = type;
		tag_ = null;
	}

	public PawnType(CellType type, Tag tag) {
		type_ = type;
		tag_ = tag;
	}
}
