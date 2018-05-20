package lysis.types;

import lysis.lstructure.Tag;
import lysis.sourcepawn.OpcodeHelpers;

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

	public boolean isString() {
		return type_ == CellType.Tag && tag_.name().equals("String");
	}

	public PawnType(Tag tag) {
		if (tag == null || tag.name().equals("_")) {
			type_ = CellType.None;
			tag_ = null;
		} else if (tag.name().equals("Float")) {
			type_ = CellType.Float;
			tag_ = null;
		} else if (tag.name().equals("bool")) {
			type_ = CellType.Bool;
			tag_ = null;
		} else if (OpcodeHelpers.IsFunctionTag(tag)) {
			type_ = CellType.Function;
			tag_ = null;
		} else {
			type_ = CellType.Tag;
			tag_ = tag;
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
