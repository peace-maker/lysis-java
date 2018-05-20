package lysis.builder.structure;

import java.util.LinkedList;

import lysis.nodes.NodeBlock;

public class SwitchBlock extends ControlBlock {
	public static class Case {
		private LinkedList<Long> values_;
		private ControlBlock target_;

		public Case(LinkedList<Long> values, ControlBlock target) {
			values_ = values;
			target_ = target;
		}

		public long value(int i) {
			return values_.get(i);
		}

		public int numValues() {
			return values_.size();
		}

		public ControlBlock target() {
			return target_;
		}
	}

	ControlBlock defaultCase_;
	LinkedList<Case> cases_;
	ControlBlock join_;

	public SwitchBlock(NodeBlock source, ControlBlock defaultCase, LinkedList<Case> cases, ControlBlock join) {
		super(source);
		defaultCase_ = defaultCase;
		cases_ = cases;
		join_ = join;
	}

	@Override
	public ControlType type() {
		return ControlType.Switch;
	}

	public int numCases() {
		return cases_.size();
	}

	public ControlBlock defaultCase() {
		return defaultCase_;
	}

	public Case getCase(int i) {
		return cases_.get(i);
	}

	public ControlBlock join() {
		return join_;
	}
}
