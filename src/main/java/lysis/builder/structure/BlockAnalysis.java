package lysis.builder.structure;

import java.util.BitSet;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Stack;

import lysis.PawnFile;
import lysis.instructions.LAddConstant;
import lysis.instructions.LControlInstruction;
import lysis.instructions.LGenArray;
import lysis.instructions.LGoto;
import lysis.instructions.LInstruction;
import lysis.instructions.LJumpCondition;
import lysis.instructions.LPushConstant;
import lysis.instructions.LStack;
import lysis.instructions.LStackAdjust;
import lysis.instructions.LStoreCtrl;
import lysis.instructions.Opcode;
import lysis.lstructure.LBlock;
import lysis.nodes.NodeBlock;
import lysis.nodes.NodeType;
import lysis.nodes.types.DJump;

//Currently, we expect that Pawn emits reducible control flow graphs.
// This seems like a reasonable assumption as the language does not have
// "goto", however I'm not familiar with the compiler enough to make a better assertion.
public class BlockAnalysis {
	// Return a reverse post-order listing of reachable blocks.
	public static LBlock[] Order(LBlock entry) {
		// Postorder traversal without recursion.
		Stack<LBlock> pending = new Stack<LBlock>();
		Stack<Integer> successors = new Stack<Integer>();
		Stack<LBlock> done = new Stack<LBlock>();

		LBlock current = entry;
		int nextSuccessor = 0;

		for (;;) {
			if (!current.marked()) {
				current.mark();
				if (nextSuccessor < current.numSuccessors()) {
					pending.push(current);
					successors.push(nextSuccessor);
					current = current.getSuccessor(nextSuccessor);
					nextSuccessor = 0;
					continue;
				}

				done.push(current);
			}

			if (pending.size() == 0)
				break;

			current = pending.pop();
			current.unmark();
			nextSuccessor = successors.pop() + 1;
		}

		LinkedList<LBlock> blocks = new LinkedList<LBlock>();

		while (done.size() > 0) {
			current = done.pop();
			current.unmark();
			current.setId(blocks.size());
			blocks.add(current);
		}

		return blocks.toArray(new LBlock[0]);
	}

	// Split critical edges in the graph. A critical edge is an edge which
	// is neither its successor's only predecessor, nor its predecessor's
	// only successor. Critical edges must be split to prevent copy-insertion
	// and code motion from affecting other edges. It is probably not strictly
	// needed here.
	public static void SplitCriticalEdges(LBlock[] blocks) {
		for (int i = 0; i < blocks.length; i++) {
			LBlock block = blocks[i];
			if (block.numSuccessors() < 2)
				continue;
			for (int j = 0; j < block.numSuccessors(); j++) {
				LBlock target = block.getSuccessor(j);
				if (target.numPredecessors() < 2)
					continue;

				// Create a new block inheriting from the predecessor.
				LBlock split = new LBlock(block.pc());
				LGoto ins = new LGoto(target);
				LInstruction[] instructions = { ins };
				split.setInstructions(instructions);
				block.replaceSuccessor(j, split);
				target.replacePredecessor(block, split);
				split.addPredecessor(block);
			}
		}
	}

	private static class RBlock {
		public LinkedList<RBlock> predecessors = new LinkedList<RBlock>();
		public LinkedList<RBlock> successors = new LinkedList<RBlock>();

		public RBlock() {
		}
	}

	// From Engineering a Compiler (Cooper, Torczon)
	public static boolean IsReducible(LBlock[] blocks) {
		// Copy the graph into a temporary mutable structure.
		RBlock[] rblocks = new RBlock[blocks.length];
		for (int i = 0; i < blocks.length; i++)
			rblocks[i] = new RBlock();

		for (int i = 0; i < blocks.length; i++) {
			LBlock block = blocks[i];
			RBlock rblock = rblocks[i];
			for (int j = 0; j < block.numPredecessors(); j++)
				rblock.predecessors.add(rblocks[block.getPredecessor(j).id()]);
			for (int j = 0; j < block.numSuccessors(); j++)
				rblock.successors.add(rblocks[block.getSuccessor(j).id()]);
		}

		// Okay, start reducing.
		LinkedList<RBlock> queue = new LinkedList<RBlock>();
		for (int i = 0; i < rblocks.length; i++)
			queue.add(rblocks[i]);
		for (;;) {
			LinkedList<RBlock> deleteQueue = new LinkedList<RBlock>();
			for (RBlock rblock : queue) {
				// Transformation T1, remove self-edges.
				if (rblock.predecessors.contains(rblock))
					rblock.predecessors.remove(rblock);
				if (rblock.successors.contains(rblock))
					rblock.successors.remove(rblock);

				// Transformation T2, remove blocks with one predecessor,
				// reroute successors' predecessors.
				if (rblock.predecessors.size() == 1) {
					// Mark this node for removal since C# sucks and can't delete during iteration.
					deleteQueue.add(rblock);

					RBlock predecessor = rblock.predecessors.get(0);

					// Delete the edge from pred -> me
					predecessor.successors.remove(rblock);

					for (int i = 0; i < rblock.successors.size(); i++) {
						RBlock successor = rblock.successors.get(i);
						assert (successor.predecessors.contains(rblock));
						successor.predecessors.remove(rblock);
						if (!successor.predecessors.contains(predecessor))
							successor.predecessors.add(predecessor);

						if (!predecessor.successors.contains(successor))
							predecessor.successors.add(successor);
					}
				}
			}

			if (deleteQueue.size() == 0)
				break;

			for (RBlock rblock : deleteQueue)
				queue.remove(rblock);
		}

		// If the graph reduced to one node, it was reducible.
		return queue.size() == 1;
	}

	private static boolean CompareBitSets(BitSet b1, BitSet b2) {
		assert (b1 != b2 && b1.size() == b2.size());
		for (int i = 0; i < b1.size(); i++) {
			if (b1.get(i) != b2.get(i))
				return false;
		}
		return true;
	}

	public static void ComputeDominators(LBlock[] blocks) {
		BitSet[] doms = new BitSet[blocks.length];
		for (int i = 0; i < doms.length; i++)
			doms[i] = new BitSet(doms.length);

		doms[0].set(0, true);

		for (int i = 1; i < blocks.length; i++) {
			for (int j = 0; j < blocks.length; j++)
				doms[i].set(0, doms.length + 1);
		}

		// Compute dominators.
		boolean changed;
		do {
			changed = false;
			for (int i = 1; i < blocks.length; i++) {
				LBlock block = blocks[i];
				for (int j = 0; j < block.numPredecessors(); j++) {
					LBlock pred = block.getPredecessor(j);
					BitSet u = (BitSet) doms[i].clone();
					doms[block.id()].and(doms[pred.id()]);
					doms[block.id()].set(block.id(), true);
					if (!CompareBitSets(doms[block.id()], u))
						changed = true;
				}
			}
		} while (changed);

		// Turn the bit vectors into lists.
		for (int i = 0; i < blocks.length; i++) {
			LBlock block = blocks[i];
			LinkedList<LBlock> list = new LinkedList<LBlock>();
			for (int j = 0; j < blocks.length; j++) {
				if (doms[block.id()].get(j))
					list.add(blocks[j]);
			}
			LBlock[] tempBlocks;
			if (list.size() == 0)
				tempBlocks = new LBlock[0];
			else
				tempBlocks = list.toArray(new LBlock[1]);
			block.setDominators(tempBlocks);
		}
	}

	private static boolean StrictlyDominatesADominator(LBlock from, LBlock dom) {
		for (int i = 0; i < from.dominators().length; i++) {
			LBlock other = from.dominators()[i];
			if (other == from || other == dom)
				continue;
			for (int x = 0; x < other.dominators().length; x++) {
				if (other.dominators()[x] == dom)
					return true;
			}
		}
		return false;
	}

	// The immediate dominator or idom of a node n is the unique node that
	// strictly dominates n but does not strictly dominate any other node
	// that strictly dominates n.
	private static void ComputeImmediateDominator(LBlock block) {
		for (int i = 0; i < block.dominators().length; i++) {
			LBlock dom = block.dominators()[i];
			if (dom == block)
				continue;

			if (!StrictlyDominatesADominator(block, dom)) {
				block.setImmediateDominator(dom);
				return;
			}
		}
		assert (false); // , "not reached"
	}

	public static void ComputeImmediateDominators(LBlock[] blocks) {
		blocks[0].setImmediateDominator(blocks[0]);

		for (int i = 1; i < blocks.length; i++)
			ComputeImmediateDominator(blocks[i]);
	}

	public static void ComputeDominatorTree(LBlock[] blocks) {
		// Cannot create a generic array of LinkedList<LBlock> ...
		@SuppressWarnings("serial")
		class LinkedListLBlock extends LinkedList<LBlock> {
		}

		LinkedList<LBlock>[] idominated = new LinkedListLBlock[blocks.length];
		for (int i = 0; i < blocks.length; i++)
			idominated[i] = new LinkedListLBlock();

		for (int i = 1; i < blocks.length; i++) {
			LBlock block = blocks[i];
			idominated[block.idom().id()].add(block);
		}

		// LBlock[] tempBlocks;
		for (int i = 0; i < blocks.length; i++) {
			blocks[i].setImmediateDominated(idominated[i].toArray(new LBlock[0]));
		}
	}

	public static LBlock FollowGoto(LBlock block) {
		if (block.instructions().length > 1)
			return block;
		LControlInstruction last = block.last();
		if (last.op() != Opcode.Goto)
			return block;
		LGoto go = (LGoto) last;
		return FollowGoto(go.target());
	}

	private static LBlock FindSkippingParent(LBlock[] blocks, int unbalanced_id, LBlock block) {
		LBlock idomBlock = blocks[block.idom().id()];
		LControlInstruction lastIns = idomBlock.last();

		if (lastIns.op() == Opcode.JumpCondition) {
			LJumpCondition jcc = (LJumpCondition) lastIns;
			LBlock target;
			if (jcc.trueTarget() == block)
				target = jcc.falseTarget();
			else if (jcc.falseTarget() == block)
				target = jcc.trueTarget();
			else
				return FindSkippingParent(blocks, unbalanced_id, idomBlock);

			if (target.id() > unbalanced_id)
				return target;
			return FindSkippingParent(blocks, unbalanced_id, idomBlock);
		}
		return null;
	}

	public static LBlock EnforceStackBalance(PawnFile file, LBlock[] blocks) {
		StackBalanceValidator validator = new StackBalanceValidator(file, blocks);
		LBlock unbalanced = validator.FindUnbalancedBlock(blocks[0]);
		if (unbalanced == null)
			return null;

		// System.err.printf("// Unbalanced stack at block %d%n", unbalanced.id());
		LBlock idomBlock = blocks[unbalanced.idom().id()];
		LControlInstruction lastIns = idomBlock.last();
		assert (lastIns.op() == Opcode.JumpCondition);
		return FindSkippingParent(blocks, unbalanced.id(), unbalanced);
	}

	private static class StackBalanceValidator {
		private int[] stack_levels_;
		private PawnFile file_;

		public StackBalanceValidator(PawnFile file, LBlock[] blocks) {
			stack_levels_ = new int[blocks.length];
			file_ = file;
		}

		public LBlock FindUnbalancedBlock(LBlock block) {
			for (int i = 0; i < block.numPredecessors(); i++) {
				LBlock pred = block.getPredecessor(i);

				// Don't bother with backedges yet.
				if (pred.id() >= block.id())
					continue;

				if (stack_levels_[block.id()] == 0)
					stack_levels_[block.id()] = stack_levels_[pred.id()];
			}

			Long lastConstant = null;
			for (LInstruction ins : block.instructions()) {
				switch (ins.op()) {
				case Stack: {
					LStack stk = (LStack) ins;
					if (stk.amount() < 0)
						stack_levels_[block.id()] += stk.amount() / -4;
					else
						stack_levels_[block.id()] -= stk.amount() / 4;
					break;
				}
				case PushConstant: {
					LPushConstant pushc = (LPushConstant) ins;
					lastConstant = pushc.val();
					stack_levels_[block.id()]++;
					continue;
				}
				case PushGlobal:
				case PushLocal:
				case PushReg:
				case PushStackAddress: {
					stack_levels_[block.id()]++;
					break;
				}
				case AddConstant: {
					LAddConstant addc = (LAddConstant) ins;
					lastConstant = addc.amount();
					continue;
				}
				case StoreCtrl: {
					assert (lastConstant != null);
					// Hack in old |goto| support.
					LStoreCtrl sctrl = (LStoreCtrl) ins;
					assert (sctrl.ctrlregindex() == 4); // STK = PRI
					stack_levels_[block.id()] = (int) (lastConstant / -4);
					break;
				}
				case StackAdjust: {
					LStackAdjust stkadj = (LStackAdjust) ins;
					stack_levels_[block.id()] = stkadj.value() / -4;
					break;
				}
				case Call:
				case SysReq: {
					assert (lastConstant != null);
					if (file_.PassArgCountAsSize())
						lastConstant /= 4;
					stack_levels_[block.id()] -= lastConstant;
					stack_levels_[block.id()]--;
					break;
				}
				case GenArray: {
					LGenArray genarray = (LGenArray) ins;
					stack_levels_[block.id()] -= genarray.dims();
					stack_levels_[block.id()]++;
					break;
				}
				case Pop: {
					stack_levels_[block.id()]--;
					break;
				}
				default:
					break;
				}

				lastConstant = null;
				if (stack_levels_[block.id()] < 0)
					return block;
			}

			for (int i = 0; i < block.idominated().length; i++) {
				LBlock lir = block.idominated()[i];
				if (lir == null)
					continue;

				LBlock unbalanced = FindUnbalancedBlock(lir);
				if (unbalanced != null)
					return unbalanced;
			}

			return null;
		}
	}

	private static LBlock SkipContainedLoop(LBlock block, LBlock header) {
		while (block.loop() != null && block.loop() == block) {
			if (block.loop() != null)
				block = block.loop();
			if (block == header)
				break;
			block = block.getLoopPredecessor();
		}
		return block;
	}

	private static class LoopBodyWorklist {
		private Stack<LBlock> stack_ = new Stack<LBlock>();
		private LBlock backedge_;

		public LoopBodyWorklist(LBlock backedge) {
			backedge_ = backedge;
		}

		public void scan(LBlock block) {
			for (int i = 0; i < block.numPredecessors(); i++) {
				LBlock pred = block.getPredecessor(i);

				// Has this block already been scanned?
				if (pred.loop() == backedge_.loop())
					continue;

				pred = SkipContainedLoop(pred, backedge_.loop());

				// If this assert hits, there is probably a |break| keyword.
				assert (pred.loop() == null || pred.loop() == backedge_.loop());
				if (pred.loop() != null)
					continue;

				stack_.push(pred);
			}
		}

		public boolean empty() {
			return stack_.size() == 0;
		}

		public LBlock pop() {
			return stack_.pop();
		}
	}

	private static void MarkLoop(LBlock backedge) {
		LoopBodyWorklist worklist = new LoopBodyWorklist(backedge);

		worklist.scan(backedge);
		while (!worklist.empty()) {
			LBlock block = worklist.pop();
			worklist.scan(block);
			block.setInLoop(backedge.loop());
		}
	}

	public static void FindLoops(LBlock[] blocks) {
		// Mark backedges and headers.
		for (int i = 1; i < blocks.length; i++) {
			LBlock block = blocks[i];
			for (int j = 0; j < block.numSuccessors(); j++) {
				LBlock successor = block.getSuccessor(j);
				if (successor.id() < block.id()) {
					successor.setLoopHeader(block);
					block.setInLoop(successor);
					break;
				}
			}
		}

		for (int i = 0; i < blocks.length; i++) {
			LBlock block = blocks[i];
			if (block.backedge() != null)
				MarkLoop(block.backedge());
		}
	}

	public static NodeBlock GetSingleTarget(NodeBlock block) {
		if (block.nodes().last().type() != NodeType.Jump)
			return null;
		DJump jump = (DJump) block.nodes().last();
		return jump.target();
	}

	public static NodeBlock GetEmptyTarget(NodeBlock block) {
		if (block.nodes().last() != block.nodes().first())
			return null;
		return GetSingleTarget(block);
	}

//	private static NodeBlock FindJoinBlock(NodeGraph graph, NodeBlock block) {
//		if (block.nodes().last().type() == NodeType.JumpCondition && block.lir().idominated().length == 3)
//			return graph.blocks(block.lir().idominated()[2].id());
//		if (block.lir().idom() == null)
//			return null;
//		if (block.lir().idom() == block.lir())
//			return null;
//		return FindJoinBlock(graph, graph.blocks(block.lir().idom().id()));
//	}
//
//	private static NodeBlock InLoop(NodeGraph graph, NodeBlock block) {
//		while (true) {
//			if (block.lir().backedge() != null)
//				return block;
//			NodeBlock next = graph.blocks(block.lir().idom().id());
//			if (block == next)
//				return null;
//			block = next;
//		}
//	}

	public static NodeBlock EffectiveTargetNoLoop(NodeBlock block) {
		if (block == null)
			return null;

		NodeBlock target = block;
		HashSet<NodeBlock> recursionCheck = new HashSet<>();
		recursionCheck.add(block);
		for (;;) {
			block = GetEmptyTarget(block);
			if (block == null)
				return target;

			// Infinite loop?
			if (recursionCheck.contains(block))
				return null;

			recursionCheck.add(block);
			target = block;
		}
	}

	public static NodeBlock EffectiveTarget(NodeBlock block) {
		NodeBlock target = block;
		for (;;) {
			block = GetEmptyTarget(block);
			if (block == null)
				return target;
			target = block;
		}
	}

	public static NodeBlock ConstantSettingTarget(NodeBlock block) {
		NodeBlock target = block;
		for (;;) {
			if (target.lir().instructions().length == 2 && target.lir().instructions()[0].op() == Opcode.Constant
					&& (target.lir().instructions()[1].op() == Opcode.Jump
							|| target.lir().instructions()[1].op() == Opcode.Goto)) {
				return target;
			}
			block = GetEmptyTarget(block);
			if (block == null)
				return null;
			target = block;
		}
	}
}
