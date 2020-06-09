package lysis.builder;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

import lysis.BitConverter;
import lysis.PawnFile;
import lysis.builder.structure.BlockAnalysis;
import lysis.instructions.LAddConstant;
import lysis.instructions.LBinary;
import lysis.instructions.LBounds;
import lysis.instructions.LCall;
import lysis.instructions.LConstant;
import lysis.instructions.LDebugBreak;
import lysis.instructions.LDecGlobal;
import lysis.instructions.LDecI;
import lysis.instructions.LDecLocal;
import lysis.instructions.LDecReg;
import lysis.instructions.LEqualConstant;
import lysis.instructions.LExchange;
import lysis.instructions.LFill;
import lysis.instructions.LGenArray;
import lysis.instructions.LGoto;
import lysis.instructions.LHeap;
import lysis.instructions.LIncGlobal;
import lysis.instructions.LIncI;
import lysis.instructions.LIncLocal;
import lysis.instructions.LIncReg;
import lysis.instructions.LIndexAddress;
import lysis.instructions.LInstruction;
import lysis.instructions.LJump;
import lysis.instructions.LJumpCondition;
import lysis.instructions.LLoad;
import lysis.instructions.LLoadCtrl;
import lysis.instructions.LLoadGlobal;
import lysis.instructions.LLoadIndex;
import lysis.instructions.LLoadLocal;
import lysis.instructions.LLoadLocalRef;
import lysis.instructions.LMemCopy;
import lysis.instructions.LMove;
import lysis.instructions.LMulConstant;
import lysis.instructions.LPop;
import lysis.instructions.LPushConstant;
import lysis.instructions.LPushGlobal;
import lysis.instructions.LPushLocal;
import lysis.instructions.LPushReg;
import lysis.instructions.LPushStackAddress;
import lysis.instructions.LReturn;
import lysis.instructions.LShiftLeftConstant;
import lysis.instructions.LStack;
import lysis.instructions.LStackAddress;
import lysis.instructions.LStackAdjust;
import lysis.instructions.LStore;
import lysis.instructions.LStoreCtrl;
import lysis.instructions.LStoreGlobal;
import lysis.instructions.LStoreGlobalConstant;
import lysis.instructions.LStoreLocal;
import lysis.instructions.LStoreLocalConstant;
import lysis.instructions.LStoreLocalRef;
import lysis.instructions.LStradjustPri;
import lysis.instructions.LSwap;
import lysis.instructions.LSwitch;
import lysis.instructions.LSysReq;
import lysis.instructions.LTrackerPopSetHeap;
import lysis.instructions.LTrackerPushC;
import lysis.instructions.LUnary;
import lysis.instructions.LZeroGlobal;
import lysis.instructions.LZeroLocal;
import lysis.instructions.SwitchCase;
import lysis.lstructure.Function;
import lysis.lstructure.LBlock;
import lysis.lstructure.LGraph;
import lysis.lstructure.Register;
import lysis.lstructure.Variable;
import lysis.sourcepawn.SPOpcode;

public class MethodParser {
	private class LIR {
		public LBlock entry;
		public List<LInstruction> instructions = new ArrayList<LInstruction>();
		public HashMap<Long, LBlock> targets = new HashMap<Long, LBlock>();
		public long entry_pc = 0;
		public long exit_pc = 0;
		public int argDepth = 0;

		public boolean isTarget(long offs) {
			assert (offs >= entry_pc && offs < exit_pc);
			return targets.containsKey(offs);
		}

		public LBlock blockOfTarget(long offs) {
			assert (offs >= entry_pc && offs < exit_pc);
			assert (targets.get(offs) != null);
			return targets.get(offs);
		}
	}

	private PawnFile file_;
	private Function func_;
	private long pc_;
	private long current_pc_;
	private LIR lir_ = new LIR();
	private boolean need_proc_;

	private int readInt32() {
		pc_ += 4;
		return BitConverter.ToInt32(file_.code().bytes(), (int) pc_ - 4);
	}

	private long readUInt32() {
		pc_ += 4;
		return BitConverter.ToUInt32(file_.code().bytes(), (int) pc_ - 4);
	}

	private SPOpcode readOp() {
		return SPOpcode.values()[(int) readUInt32()];
	}

	private SPOpcode peekOp() {
		long op = readUInt32();
		pc_ -= 4;
		return SPOpcode.values()[(int) op];
	}

	private LInstruction add(LInstruction ins) {
		ins.setPc(current_pc_);
		lir_.instructions.add(ins);
		return ins;
	}

	private LBlock prepareJumpTarget(long offset) {
		if (!lir_.targets.containsKey(offset))
			lir_.targets.put(offset, new LBlock(offset));
		return lir_.targets.get(offset);
	}

	private int trackStack(int offset) {
		if (offset < 0)
			return offset;
		// 32 is max args
		if (offset > lir_.argDepth && ((offset - 12) / 4) + 1 <= 32)
			lir_.argDepth = offset;
		return offset;
	}

	private int trackGlobal(int addr) {
		file_.addGlobal(addr);
		return addr;
	}

	private LInstruction readInstruction(SPOpcode op) throws Exception {
		switch (op) {
		case load_pri:
		case load_alt: {
			Register reg = (op == SPOpcode.load_pri) ? Register.Pri : Register.Alt;
			return new LLoadGlobal(trackGlobal(readInt32()), reg);
		}

		case load_s_pri:
		case load_s_alt: {
			Register reg = (op == SPOpcode.load_s_pri) ? Register.Pri : Register.Alt;
			return new LLoadLocal(trackStack(readInt32()), reg);
		}

		case lref_s_pri:
		case lref_s_alt: {
			Register reg = (op == SPOpcode.lref_s_pri) ? Register.Pri : Register.Alt;
			return new LLoadLocalRef(trackStack(readInt32()), reg);
		}

		case stor_s_pri:
		case stor_s_alt: {
			Register reg = (op == SPOpcode.stor_s_pri) ? Register.Pri : Register.Alt;
			return new LStoreLocal(reg, trackStack(readInt32()));
		}

		case sref_s_pri:
		case sref_s_alt: {
			Register reg = (op == SPOpcode.sref_s_pri) ? Register.Pri : Register.Alt;
			return new LStoreLocalRef(reg, trackStack(readInt32()));
		}

		case load_i:
			return new LLoad(4);

		case lodb_i:
			return new LLoad(readInt32());

		case const_pri:
		case const_alt: {
			Register reg = (op == SPOpcode.const_pri) ? Register.Pri : Register.Alt;
			return new LConstant(readInt32(), reg);
		}

		case addr_pri:
		case addr_alt: {
			Register reg = (op == SPOpcode.addr_pri) ? Register.Pri : Register.Alt;
			return new LStackAddress(trackStack(readInt32()), reg);
		}

		case stor_pri:
		case stor_alt: {
			Register reg = (op == SPOpcode.stor_pri) ? Register.Pri : Register.Alt;
			return new LStoreGlobal(trackGlobal(readInt32()), reg);
		}

		case stor_i:
			return new LStore(4);

		case strb_i:
			return new LStore(readInt32());

		case lidx:
			return new LLoadIndex(4);

		case lidx_b:
			return new LLoadIndex(readInt32());

		case idxaddr:
			return new LIndexAddress(2);

		case idxaddr_b:
			return new LIndexAddress(readInt32());

		case move_pri:
		case move_alt: {
			Register reg = (op == SPOpcode.move_pri) ? Register.Pri : Register.Alt;
			return new LMove(reg);
		}

		case xchg:
			return new LExchange();

		case push_pri:
		case push_alt: {
			Register reg = (op == SPOpcode.push_pri) ? Register.Pri : Register.Alt;
			return new LPushReg(reg);
		}

		case push_c:
			return new LPushConstant(readInt32());

		case push:
			return new LPushGlobal(trackGlobal(readInt32()));

		case push_s:
			return new LPushLocal(trackStack(readInt32()));

		case pop_pri:
		case pop_alt: {
			Register reg = (op == SPOpcode.pop_pri) ? Register.Pri : Register.Alt;
			return new LPop(reg);
		}

		case stack:
			return new LStack(readInt32());

		case retn:
			return new LReturn();

		case call: {
			long addr = readInt32();
			file_.addFunction(addr);
			return new LCall(addr);
		}

		case jump: {
			long offset = readUInt32();
			return new LJump(prepareJumpTarget(offset), offset);
		}

		case jeq:
		case jneq:
		case jnz:
		case jzer:
		case jsgeq:
		case jsless:
		case jsgrtr:
		case jsleq: {
			long offset = readUInt32();
			if (offset == pc_)
				return new LJump(prepareJumpTarget(offset), offset);
			return new LJumpCondition(op, prepareJumpTarget(offset), prepareJumpTarget(pc_), offset);
		}

		case sdiv_alt:
		case sub_alt:
			return new LBinary(op, Register.Alt, Register.Pri);

		case add:
		case and:
		case or:
		case smul:
		case sdiv:
		case shr:
		case shl:
		case sub:
		case sshr:
		case xor:
			return new LBinary(op, Register.Pri, Register.Alt);
			
		case shl_c_pri:
		case shl_c_alt: {
			// Only generated without the peephole optimizer.
			Register reg = (op == SPOpcode.shl_c_pri) ? Register.Pri : Register.Alt;
			return new LShiftLeftConstant(readInt32(), reg);
		}

		case not:
		case neg:
		case invert:
			return new LUnary(op, Register.Pri);

		case add_c:
			return new LAddConstant(readInt32());

		case smul_c:
			return new LMulConstant(readInt32());

		case zero_pri:
		case zero_alt: {
			Register reg = (op == SPOpcode.zero_pri) ? Register.Pri : Register.Alt;
			return new LConstant(0, reg);
		}

		case zero_s:
			return new LZeroLocal(trackStack(readInt32()));

		case zero:
			return new LZeroGlobal(trackGlobal(readInt32()));

		case eq:
		case neq:
		case sleq:
		case sgeq:
		case sgrtr:
		case sless:
			return new LBinary(op, Register.Pri, Register.Alt);

		case eq_c_pri:
		case eq_c_alt: {
			Register reg = (op == SPOpcode.eq_c_pri) ? Register.Pri : Register.Alt;
			return new LEqualConstant(reg, readInt32());
		}

		case inc:
			return new LIncGlobal(trackGlobal(readInt32()));

		case dec:
			return new LDecGlobal(trackGlobal(readInt32()));

		case inc_s:
			return new LIncLocal(trackStack(readInt32()));

		case dec_s:
			return new LDecLocal(trackStack(readInt32()));

		case inc_i:
			return new LIncI();

		case inc_pri:
		case inc_alt: {
			Register reg = (op == SPOpcode.inc_pri) ? Register.Pri : Register.Alt;
			return new LIncReg(reg);
		}

		case dec_pri:
		case dec_alt: {
			Register reg = (op == SPOpcode.dec_pri) ? Register.Pri : Register.Alt;
			return new LDecReg(reg);
		}

		case dec_i:
			return new LDecI();

		case fill:
			return new LFill(readInt32());

		case bounds:
			return new LBounds(readInt32());

		case swap_pri:
		case swap_alt: {
			Register reg = (op == SPOpcode.swap_pri) ? Register.Pri : Register.Alt;
			return new LSwap(reg);
		}

		case push_adr:
			return new LPushStackAddress(trackStack(readInt32()));

		case sysreq_c: {
			long index = readUInt32();
			long prePeep = pc_;
			SPOpcode nextOp = readOp();
			int nextValue = readInt32();
			// Assert, that we really clear the stack from the arguments after this.
			long argSize = ((LPushConstant) lir_.instructions.get(lir_.instructions.size() - 1)).val();
			if (!file_.PassArgCountAsSize())
				argSize *= 4;
			argSize += 4;
			assert (nextOp == SPOpcode.stack && nextValue == argSize);
			// Skip the stack op, if it's popping the arguments again.
			if (nextOp != SPOpcode.stack || nextValue != argSize)
				pc_ = prePeep;
			return new LSysReq(file_.natives()[(int) index]);
		}

		case sysreq_n: {
			long index = readUInt32();
			add(new LPushConstant((int) readUInt32()));
			return new LSysReq(file_.natives()[(int) index]);
		}

		case dbreak:
			return new LDebugBreak();

		case endproc:
			return null;

		case push2_s: {
			add(new LPushLocal(trackStack(readInt32())));
			return new LPushLocal(trackStack(readInt32()));
		}

		case push2_adr: {
			add(new LPushStackAddress(trackStack(readInt32())));
			return new LPushStackAddress(trackStack(readInt32()));
		}

		case push2_c: {
			add(new LPushConstant(readInt32()));
			return new LPushConstant(readInt32());
		}

		case push2: {
			add(new LPushGlobal(trackGlobal(readInt32())));
			return new LPushGlobal(trackGlobal(readInt32()));
		}

		case push3_s: {
			add(new LPushLocal(trackStack(readInt32())));
			add(new LPushLocal(trackStack(readInt32())));
			return new LPushLocal(trackStack(readInt32()));
		}

		case push3_adr: {
			add(new LPushStackAddress(trackStack(readInt32())));
			add(new LPushStackAddress(trackStack(readInt32())));
			return new LPushStackAddress(trackStack(readInt32()));
		}

		case push3_c: {
			add(new LPushConstant(readInt32()));
			add(new LPushConstant(readInt32()));
			return new LPushConstant(readInt32());
		}

		case push3: {
			add(new LPushGlobal(trackGlobal(readInt32())));
			add(new LPushGlobal(trackGlobal(readInt32())));
			return new LPushGlobal(trackGlobal(readInt32()));
		}

		case push4_s: {
			add(new LPushLocal(trackStack(readInt32())));
			add(new LPushLocal(trackStack(readInt32())));
			add(new LPushLocal(trackStack(readInt32())));
			return new LPushLocal(trackStack(readInt32()));
		}

		case push4_adr: {
			add(new LPushStackAddress(trackStack(readInt32())));
			add(new LPushStackAddress(trackStack(readInt32())));
			add(new LPushStackAddress(trackStack(readInt32())));
			return new LPushStackAddress(trackStack(readInt32()));
		}

		case push4_c: {
			add(new LPushConstant(readInt32()));
			add(new LPushConstant(readInt32()));
			add(new LPushConstant(readInt32()));
			return new LPushConstant(readInt32());
		}

		case push4: {
			add(new LPushGlobal(trackGlobal(readInt32())));
			add(new LPushGlobal(trackGlobal(readInt32())));
			add(new LPushGlobal(trackGlobal(readInt32())));
			return new LPushGlobal(trackGlobal(readInt32()));
		}

		case push5_s: {
			add(new LPushLocal(trackStack(readInt32())));
			add(new LPushLocal(trackStack(readInt32())));
			add(new LPushLocal(trackStack(readInt32())));
			add(new LPushLocal(trackStack(readInt32())));
			return new LPushLocal(trackStack(readInt32()));
		}

		case push5_c: {
			add(new LPushConstant(readInt32()));
			add(new LPushConstant(readInt32()));
			add(new LPushConstant(readInt32()));
			add(new LPushConstant(readInt32()));
			return new LPushConstant(readInt32());
		}

		case push5_adr: {
			add(new LPushStackAddress(trackStack(readInt32())));
			add(new LPushStackAddress(trackStack(readInt32())));
			add(new LPushStackAddress(trackStack(readInt32())));
			add(new LPushStackAddress(trackStack(readInt32())));
			return new LPushStackAddress(trackStack(readInt32()));
		}

		case push5: {
			add(new LPushGlobal(trackGlobal(readInt32())));
			add(new LPushGlobal(trackGlobal(readInt32())));
			add(new LPushGlobal(trackGlobal(readInt32())));
			add(new LPushGlobal(trackGlobal(readInt32())));
			return new LPushGlobal(trackGlobal(readInt32()));
		}

		case load_both: {
			add(new LLoadGlobal(trackGlobal(readInt32()), Register.Pri));
			return new LLoadGlobal(trackGlobal(readInt32()), Register.Alt);
		}

		case load_s_both: {
			add(new LLoadLocal(trackStack(readInt32()), Register.Pri));
			return new LLoadLocal(trackStack(readInt32()), Register.Alt);
		}

		case const_: {
			return new LStoreGlobalConstant(trackGlobal(readInt32()), readInt32());
		}

		case const_s: {
			return new LStoreLocalConstant(trackStack(readInt32()), readInt32());
		}

		case heap: {
			return new LHeap(readInt32());
		}

		case movs: {
			return new LMemCopy(readInt32());
		}

		case switch_: {
			long table = readUInt32();
			long savePc = pc_;
			pc_ = table;

			SPOpcode casetbl = SPOpcode.values()[(int) readUInt32()];
			assert (casetbl == SPOpcode.casetbl);

			int ncases = readInt32();
			long defaultCase = readUInt32();
			LinkedList<SwitchCase> cases = new LinkedList<SwitchCase>();
			boolean bMultipleValues;
			for (int i = 0; i < ncases; i++) {
				int value = readInt32();
				long pc = readUInt32();
				LBlock target = prepareJumpTarget(pc);
				// Check if there are multiple values for the same case
				// case 1, 2, 3:
				bMultipleValues = false;
				for (int j = 0; j < cases.size(); j++) {
					if (cases.get(j).target.equals(target)) {
						cases.get(j).addValue(value);
						bMultipleValues = true;
						break;
					}
				}
				if (!bMultipleValues)
					cases.add(new SwitchCase(value, target));
			}
			pc_ = savePc;
			return new LSwitch(prepareJumpTarget(defaultCase), cases);
		}

		case casetbl: {
			int ncases = readInt32();
			pc_ += (long) ncases * 8 + 4;
			return new LDebugBreak();
		}

		case genarray: {
			int dims = readInt32();
			return new LGenArray(dims, false);
		}

		case genarray_z: {
			int dims = readInt32();
			return new LGenArray(dims, true);
		}

		case tracker_pop_setheap: {
			return new LTrackerPopSetHeap();
		}

		case tracker_push_c: {
			int value = readInt32();
			return new LTrackerPushC(value);
		}

		case stradjust_pri: {
			return new LStradjustPri();
		}

		case stackadjust: {
			int value = readInt32();
			assert (value <= 0);
			return new LStackAdjust(value);
		}

		case nop: {
			return new LDebugBreak();
		}

		case halt: {
			readInt32();
			return new LDebugBreak();
		}

		case lctrl: {
			int index = readInt32();
			return new LLoadCtrl(index);
		}

		case sctrl: {
			int index = readInt32();
			return new LStoreCtrl(index);
		}

		default:
			throw new Exception("Unrecognized opcode: " + op);
		}
	}

	private void readAll() throws Exception {
		lir_.entry_pc = pc_;

		if (need_proc_ && readOp() != SPOpcode.proc)
			throw new Exception("invalid method, first op must be PROC");

		while (pc_ < (long) file_.code().bytes().length) {
			current_pc_ = pc_;
			SPOpcode op = readOp();
			if (op == SPOpcode.proc)
				break;
			add(readInstruction(op));
		}

		lir_.exit_pc = pc_;
	}

	private void readStateTable() throws Exception {
		lir_.entry_pc = pc_;

		// Load the state variable.
		current_pc_ = pc_;
		SPOpcode op = readOp();
		assert (op == SPOpcode.load_pri);
		add(readInstruction(op));

		// Get the method implementation list for different states.
		current_pc_ = pc_;
		op = readOp();
		assert (op == SPOpcode.switch_);
		add(readInstruction(op));

		// Skip the casetbl entries too.
		while (pc_ < (long) file_.code().bytes().length) {
			current_pc_ = pc_;
			op = readOp();
			if (op != SPOpcode.casetbl)
				break;
			add(readInstruction(op));
		}

		lir_.exit_pc = current_pc_;

		LLoadGlobal state_var = (LLoadGlobal) lir_.instructions.get(0);
		// Rename global state variable.
		Variable var = file_.lookupGlobal(state_var.address());
		var.setName("g_statevar_" + var.address());
		// Remember this is a state variable, so we can print it correctly.
		var.markAsStateVariable();

		LSwitch function_list = (LSwitch) lir_.instructions.get(1);

		// Parse the default/error state <>
		Function default_func = file_.addFunction(function_list.defaultCase().pc());
		default_func.setName(func_.name());
		default_func.setStateAddr(state_var.address());
		default_func.setTag(func_.returnTag());
		default_func.setTagId(func_.tag_id());

		// Parse all implementations for different states.
		for (int i = 0; i < function_list.numCases(); i++) {
			SwitchCase case_ = function_list.getCase(i);
			assert (case_.numValues() == 1);
			long state_id = case_.value(0);
			long start_addr = case_.target.pc();

			Function state_func = file_.addFunction(start_addr);
			state_func.setName(func_.name());
			state_func.setStateId((short) state_id);
			state_func.setStateAddr(state_var.address());
			state_func.setTag(func_.returnTag());
			state_func.setTagId(func_.tag_id());
		}
	}

	private class BlockBuilder {
		private List<LInstruction> pending_ = null;
		private LBlock block_ = null;
		private LIR lir_;

		private void transitionBlocks(LBlock next) {
			assert (pending_.size() == 0 || block_ != null);
			if (block_ != null) {
				assert (pending_.get(pending_.size() - 1).isControl());
				assert (block_.pc() >= lir_.entry_pc && block_.pc() < lir_.exit_pc);
				block_.setInstructions(pending_.toArray(new LInstruction[0]));
				pending_.clear();
			}
			block_ = next;
		}

		public BlockBuilder(LIR lir) {
			pending_ = new ArrayList<LInstruction>(lir.instructions.size());
			lir_ = lir;
			block_ = lir_.entry;
		}

		public LBlock parse() {
			for (int i = 0; i < lir_.instructions.size(); i++) {
				LInstruction ins = lir_.instructions.get(i);

				if (lir_.isTarget(ins.pc())) {
					// This instruction is the target of a basic block, so
					// finish the old one.
					LBlock next = lir_.blockOfTarget(ins.pc());

					// Multiple instructions could be at the same pc,
					// because of decomposition, so make sure we're not
					// transitioning to the same block.
					if (block_ != next) {
						// Add implicit control flow to make further algorithms easier.
						if (block_ != null) {
							assert (!pending_.get(pending_.size() - 1).isControl());
							pending_.add(new LGoto(next));
							next.addPredecessor(block_);
						}

						// Fallthrough to the next block.
						transitionBlocks(next);
					}
				}

				// If there is no block present, we assume this is dead code.
				if (block_ == null)
					continue;

				pending_.add(ins);

				switch (ins.op()) {
				case Return: {
					// A return terminates the current block.
					transitionBlocks(null);
					break;
				}

				case Jump: {
					LJump jump = (LJump) ins;
					jump.target().addPredecessor(block_);
					transitionBlocks(null);
					break;
				}

				case JumpCondition: {
					LJumpCondition jcc = (LJumpCondition) ins;
					jcc.trueTarget().addPredecessor(block_);
					jcc.falseTarget().addPredecessor(block_);

					// The next iteration will pick the false target up.
					assert (lir_.instructions.get(i + 1).pc() == jcc.falseTarget().pc());
					transitionBlocks(null);
					break;
				}

				case Switch: {
					LSwitch switch_ = (LSwitch) ins;
					for (int j = 0; j < switch_.numSuccessors(); j++) {
						switch_.getSuccessor(j).addPredecessor(block_);
					}
					transitionBlocks(null);
					break;
				}

				default:
					break;
				}
			}
			return lir_.entry;
		}
	}

	private boolean ContainsBlock(LBlock[] blocks, LBlock needle) {
		for (LBlock block : blocks) {
			if (block == needle)
				return true;
		}
		return false;
	}

	private LGraph buildBlocks() throws Exception {
		lir_.entry = new LBlock(lir_.entry_pc);
		BlockBuilder builder = new BlockBuilder(lir_);
		LBlock entry = builder.parse();

		// Get an RPO ordering of the blocks, since we don't have predecessors yet.
		LBlock[] blocks = BlockAnalysis.Order(entry);

		// Remove dead references.
		// Ignore blocks that are unreachable and are always jumped over
		// e.g.
		// if(1 != 1)
		// loop()..
		for (LBlock block : blocks) {
			int numPredecessors = block.numPredecessors();
			for (int i = 0; i < numPredecessors; i++) {
				if (!ContainsBlock(blocks, block.getPredecessor(i))) {
					block.removePredecessor(block.getPredecessor(i));
					numPredecessors--;
				}
			}
		}

		if (!BlockAnalysis.IsReducible(blocks))
			throw new Exception("control flow graph is not reducible");

		// Split critical edges in the graph (is this even needed?)
		BlockAnalysis.SplitCriticalEdges(blocks);

		// Reorder the blocks since we could have introduced new nodes.
		blocks = BlockAnalysis.Order(entry);
		assert (BlockAnalysis.IsReducible(blocks));

		BlockAnalysis.ComputeDominators(blocks);
		BlockAnalysis.ComputeImmediateDominators(blocks);
		BlockAnalysis.ComputeDominatorTree(blocks);
		LBlock newEntry = BlockAnalysis.EnforceStackBalance(file_, blocks);
		if (newEntry != null) {
			// Reparse the method starting from a sane block.
			// This looks like some manually crafted code.
			newEntry = BlockAnalysis.FollowGoto(newEntry);
			MethodParser subParser = new MethodParser(file_, func_, newEntry.pc());
			subParser.readAll();
			LGraph graph = subParser.buildBlocks();
			// Set the entry pc to the old one, so the symbols still match.
			graph.entry.setPC(lir_.entry_pc);
			return graph;
		}
		BlockAnalysis.FindLoops(blocks);

		LGraph graph = new LGraph();
		graph.blocks = blocks;
		graph.entry = blocks[0];
		graph.nargs = getNumArgs();

		return graph;
	}

	private MethodParser(PawnFile file, Function func, long pc) {
		file_ = file;
		func_ = func;
		pc_ = pc;
		need_proc_ = false;
	}

	public MethodParser(PawnFile file, Function func) {
		file_ = file;
		func_ = func;
		pc_ = func.address();
		need_proc_ = true;
	}

	public boolean preprocess() throws Exception {
		SPOpcode op = peekOp();
		if (op == SPOpcode.load_pri) {
			readStateTable();
			func_.setCodeEnd(getExitPC());
			return false;
		}

		readAll();
		return true;
	}
	
	public LGraph parse() throws Exception {
		// assert(BitConverter.IsLittleEndian);

		if (!preprocess())
			return null;
		return buildBlocks();
	}

	public long getExitPC() {
		return lir_.exit_pc;
	}
	
	public int getNumArgs() {
		if (lir_.argDepth > 0)
			return ((lir_.argDepth - 12) / 4) + 1;
		return 0;
	}
}
