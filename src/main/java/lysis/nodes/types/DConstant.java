package lysis.nodes.types;

import lysis.lstructure.Scope;
import lysis.lstructure.Tag;
import lysis.lstructure.Variable;
import lysis.lstructure.VariableType;
import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;
import lysis.sourcepawn.SourcePawnFile;

public class DConstant extends DNullaryNode {

	private long value_;
	private long pc_;

	public DConstant(long value) {
		value_ = value;
	}

	public DConstant(long value, long pc) {
		value_ = value;
		pc_ = pc;
	}

	public long value() {
		if (usedAsArrayIndex())
			return value_ / 4;

		return value_;
	}

	public long pc() {
		return pc_;
	}

	@Override
	public NodeType type() {
		return NodeType.Constant;
	}

	@Override
	public void accept(NodeVisitor visitor) throws Exception {
		visitor.visit(this);
	}

	@Override
	public DNode applyType(SourcePawnFile file, Tag tag, VariableType type) {
		switch (type) {
		case Array:
		case ArrayReference:
		case Reference:
		case Variadic: {
			Variable global = file.lookupGlobal(value());
			if (global == null)
				global = file.lookupVariable(pc(), value(), Scope.Static);
			if (global != null)
				return new DGlobal(global);
			if (tag.isString())
				return new DString(file.stringFromData(value()));
			break;
		}
		default:
			break;
		}
		return this;
	}

}
