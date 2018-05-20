package lysis.lstructure;

import java.util.LinkedList;

import lysis.instructions.LControlInstruction;
import lysis.instructions.LInstruction;

public class LBlock {
	private long pc_;
	private LInstruction[] instructions_;
	private LinkedList<LBlock> predecessors_ = new LinkedList<LBlock>();
	private boolean marked_ = false;
	private int id_;
	private LBlock backedge_ = null;
	private LBlock loop_ = null;

	// Immediate dominator.
	private LBlock idom_ = null;

	// List of blocks which dominate this block.
	private LBlock[] dominators_ = null;

	// List of blocks that are immediately dominated by this block.
	private LBlock[] idominated_ = null;

	public LBlock(long pc) {
		pc_ = pc;
	}

	public void setInstructions(LInstruction[] instructions) {
		instructions_ = instructions;
	}

	public void addPredecessor(LBlock pred) {
		assert (!predecessors_.contains(pred));
		predecessors_.add(pred);
	}

	public void removePredecessor(LBlock pred) {
		assert (predecessors_.contains(pred));
		predecessors_.remove(pred);
	}

	public void mark() {
		assert (!marked_);
		marked_ = true;
	}

	public void unmark() {
		assert (marked_);
		marked_ = false;
	}

	public boolean marked() {
		return marked_;
	}

	public void setId(int id) {
		id_ = id;
	}

	public void setLoopHeader(LBlock backedge) {
		backedge_ = backedge;
		loop_ = this;
	}

	public void setInLoop(LBlock loop) {
		loop_ = loop;
	}

	public void setImmediateDominator(LBlock idom) {
		idom_ = idom;
	}

	public void setDominators(LBlock[] dominators) {
		dominators_ = dominators;
	}

	public void setImmediateDominated(LBlock[] idominated) {
		idominated_ = idominated;
	}

	public int id() {
		return id_;
	}

	public LBlock idom() {
		return idom_;
	}

	public long pc() {
		return pc_;
	}

	public LInstruction[] instructions() {
		return instructions_;
	}

	public LBlock backedge() {
		return backedge_;
	}

	public int numPredecessors() {
		return predecessors_.size();
	}

	public int numSuccessors() {
		return last().numSuccessors();
	}

	public LBlock getSuccessor(int successor) {
		return last().getSuccessor(successor);
	}

	public LBlock getPredecessor(int predecessor) {
		return predecessors_.get(predecessor);
	}

	public LBlock getLoopPredecessor() {
		assert (loop_ == this);
		assert (numPredecessors() == 2);
		if (getPredecessor(0).id() < id()) {
			assert (getPredecessor(1).id() >= id());
			return getPredecessor(0);
		}
		assert (getPredecessor(1).id() < id());
		return getPredecessor(1);
	}

	public LBlock[] dominators() {
		return dominators_;
	}

	public LBlock[] idominated() {
		return idominated_;
	}

	public LBlock loop() {
		return loop_;
	}

	public void replaceSuccessor(int pos, LBlock split) {
		last().replaceSuccessor(pos, split);
	}

	public void replacePredecessor(LBlock from, LBlock split) {
		assert (predecessors_.contains(from));
		for (int i = 0; i < numPredecessors(); i++) {
			if (getPredecessor(i) == from) {
				predecessors_.set(i, split);
				break;
			}
		}
		assert (!predecessors_.contains(from));
	}

	public LControlInstruction last() {
		return (LControlInstruction) instructions()[instructions().length - 1];
	}
}
