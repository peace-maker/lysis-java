package lysis.nodes;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.util.LinkedList;

import lysis.PawnFile;
import lysis.StupidWrapper;
import lysis.instructions.LAddConstant;
import lysis.instructions.LBinary;
import lysis.instructions.LBounds;
import lysis.instructions.LCall;
import lysis.instructions.LConstant;
import lysis.instructions.LDecGlobal;
import lysis.instructions.LDecLocal;
import lysis.instructions.LDecReg;
import lysis.instructions.LEqualConstant;
import lysis.instructions.LFill;
import lysis.instructions.LGenArray;
import lysis.instructions.LGoto;
import lysis.instructions.LHeap;
import lysis.instructions.LIncGlobal;
import lysis.instructions.LIncLocal;
import lysis.instructions.LIncReg;
import lysis.instructions.LIndexAddress;
import lysis.instructions.LInstruction;
import lysis.instructions.LJump;
import lysis.instructions.LJumpCondition;
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
import lysis.instructions.LShiftLeftConstant;
import lysis.instructions.LStack;
import lysis.instructions.LStackAddress;
import lysis.instructions.LStackAdjust;
import lysis.instructions.LStoreCtrl;
import lysis.instructions.LStoreGlobal;
import lysis.instructions.LStoreGlobalConstant;
import lysis.instructions.LStoreLocal;
import lysis.instructions.LStoreLocalConstant;
import lysis.instructions.LStoreLocalRef;
import lysis.instructions.LSwap;
import lysis.instructions.LSwitch;
import lysis.instructions.LSysReq;
import lysis.instructions.LUnary;
import lysis.instructions.LZeroGlobal;
import lysis.instructions.LZeroLocal;
import lysis.lstructure.Function;
import lysis.lstructure.LBlock;
import lysis.lstructure.LGraph;
import lysis.lstructure.Register;
import lysis.lstructure.Scope;
import lysis.lstructure.Variable;
import lysis.nodes.types.DArrayRef;
import lysis.nodes.types.DBinary;
import lysis.nodes.types.DBoundsCheck;
import lysis.nodes.types.DCall;
import lysis.nodes.types.DConstant;
import lysis.nodes.types.DDeclareLocal;
import lysis.nodes.types.DDeclareStatic;
import lysis.nodes.types.DGenArray;
import lysis.nodes.types.DGlobal;
import lysis.nodes.types.DHeap;
import lysis.nodes.types.DIncDec;
import lysis.nodes.types.DJump;
import lysis.nodes.types.DJumpCondition;
import lysis.nodes.types.DLabel;
import lysis.nodes.types.DLoad;
import lysis.nodes.types.DLocalRef;
import lysis.nodes.types.DMemCopy;
import lysis.nodes.types.DNode;
import lysis.nodes.types.DReturn;
import lysis.nodes.types.DStore;
import lysis.nodes.types.DString;
import lysis.nodes.types.DSwitch;
import lysis.nodes.types.DSysReq;
import lysis.nodes.types.DUnary;
import lysis.sourcepawn.SPOpcode;

public class NodeBuilder {
	PawnFile file_;
	private LGraph graph_;
	private NodeBlock[] blocks_;

	public NodeBuilder(PawnFile file, LGraph graph) {
		file_ = file;
		graph_ = graph;
		blocks_ = new NodeBlock[graph_.blocks.length];
		for (int i = 0; i < graph_.blocks.length; i++)
			blocks_[i] = new NodeBlock(graph_.blocks[i]);
	}

	public void traverse(NodeBlock block) throws Exception {
		for (int i = 0; i < block.lir().numPredecessors(); i++) {
			NodeBlock pred = blocks_[block.lir().getPredecessor(i).id()];

			// Don't bother with backedges yet.
			if (pred.lir().id() >= block.lir().id())
				continue;

			block.inherit(graph_, pred);
		}

		for (LInstruction uins : block.lir().instructions()) {
			// Attempt to find static declarations. This is really
			// expensive - we could cheapen it by creating per-method
			// lists of statics.
			{
				int i = -1;
				do {
					StupidWrapper iStupid = new StupidWrapper(i);
					Variable var = file_.lookupDeclarations(uins.pc(), iStupid, Scope.Static);
					i = iStupid.i;
					if (var == null)
						break;
					block.add(new DDeclareStatic(var));
				} while (true);
			}

			switch (uins.op()) {
			case DebugBreak:
				break;

			case Stack: {
				LStack ins = (LStack) uins;
				if (ins.amount() < 0) {
					for (int i = 0; i < -ins.amount() / 4; i++) {
						DDeclareLocal local = new DDeclareLocal(ins.pc(), null);
						block.stack().push(local);
						block.add(local);
					}
				} else {
					for (int i = 0; i < ins.amount() / 4; i++)
						block.stack().pop();
				}
				break;
			}

			case Fill: {
				LFill ins = (LFill) uins;
				DNode node = block.stack().alt();
				DDeclareLocal local = (DDeclareLocal) node;
				assert (block.stack().pri().type() == NodeType.Constant);
				for (int i = 0; i < ins.amount(); i += 4)
					block.stack().set(local.offset() + i, block.stack().pri());

				// Remember that this local is initialized -> "new" instead of "decl"!
				DConstant con = (DConstant) block.stack().pri();
				if (local.value() == null && con.value() == 0)
					local.initOperand(0, con);
				
				// The compiler might throw in a |fill| opcode instead of a
				// |movs| to copy a string that fits in one cell.
				if (ins.amount() == 4 && con.value() != 0) {
					// Convert the number to a string.
					ByteBuffer buffer = ByteBuffer.allocate(Integer.BYTES);
					buffer.order(ByteOrder.LITTLE_ENDIAN);
				    buffer.putInt((int)con.value());
				    
				    // Strip the unused bytes.
				    int requiredBytes = (int) (Math.ceil(Math.log(con.value()) / Math.log(2)) / 8) + 1;
				    byte[] bytes = new byte[requiredBytes];
				    for (int i = 0; i < requiredBytes; i++)
				    	bytes[i] = buffer.get(i);
					DStore store = new DStore(local, new DString(new String(bytes, StandardCharsets.UTF_8)));
					block.add(store);
				}
				break;
			}

			case Constant: {
				LConstant ins = (LConstant) uins;
				DConstant v = new DConstant(ins.val(), ins.pc());
				block.stack().set(ins.reg(), v);
				block.add(v);
				break;
			}

			case PushConstant: {
				LPushConstant ins = (LPushConstant) uins;
				DConstant v = new DConstant(ins.val(), ins.pc());
				DDeclareLocal local = new DDeclareLocal(ins.pc(), v);
				block.stack().push(local);
				block.add(v);
				block.add(local);
				break;
			}

			case PushReg: {
				LPushReg ins = (LPushReg) uins;
				DDeclareLocal local = new DDeclareLocal(ins.pc(), block.stack().reg(ins.reg()));
				block.stack().push(local);
				block.add(local);
				break;
			}

			case Pop: {
				LPop ins = (LPop) uins;
				DNode node = block.stack().popAsTemp();
				block.stack().set(ins.reg(), node);
				break;
			}

			case StackAddress: {
				LStackAddress ins = (LStackAddress) uins;
				DDeclareLocal local = (DDeclareLocal) block.stack().getName(ins.offset());
				block.stack().set(ins.reg(), local);
				break;
			}

			case PushStackAddress: {
				LPushStackAddress ins = (LPushStackAddress) uins;
				DLocalRef lref = new DLocalRef((DDeclareLocal) block.stack().getName(ins.offset()));
				DDeclareLocal local = new DDeclareLocal(ins.pc(), lref);
				block.stack().push(local);
				block.add(lref);
				block.add(local);
				break;
			}

			case Goto: {
				LGoto ins = (LGoto) uins;
				DJump node = new DJump(blocks_[ins.target().id()]);
				block.add(node);
				break;
			}

			case Jump: {
				LJump ins = (LJump) uins;
				DJump node = new DJump(blocks_[ins.target().id()]);
				block.add(node);
				break;
			}

			case JumpCondition: {
				LJumpCondition ins = (LJumpCondition) uins;
				NodeBlock lhtarget = blocks_[ins.trueTarget().id()];
				NodeBlock rhtarget = blocks_[ins.falseTarget().id()];
				DNode cmp = block.stack().pri();
				SPOpcode jmp = ins.spop();
				if (jmp != SPOpcode.jzer && jmp != SPOpcode.jnz) {
					SPOpcode newop;
					switch (ins.spop()) {
					case jeq:
						newop = SPOpcode.neq;
						jmp = SPOpcode.jzer;
						break;
					case jneq:
						newop = SPOpcode.eq;
						jmp = SPOpcode.jzer;
						break;
					case jsgeq:
						newop = SPOpcode.sless;
						jmp = SPOpcode.jzer;
						break;
					case jsgrtr:
						newop = SPOpcode.sleq;
						jmp = SPOpcode.jzer;
						break;
					case jsleq:
						newop = SPOpcode.sgrtr;
						jmp = SPOpcode.jzer;
						break;
					case jsless:
						newop = SPOpcode.sgeq;
						jmp = SPOpcode.jzer;
						break;
					default:
						assert (false);
						return;
					}
					cmp = new DBinary(newop, block.stack().pri(), block.stack().alt());
					block.add(cmp);
				}
				DJumpCondition jcc = new DJumpCondition(jmp, cmp, lhtarget, rhtarget);
				block.add(jcc);
				break;
			}

			case LoadLocal: {
				LLoadLocal ins = (LLoadLocal) uins;
				DLoad load = new DLoad(block.stack().getName(ins.offset()));
				block.stack().set(ins.reg(), load);
				block.add(load);
				break;
			}

			case LoadLocalRef: {
				LLoadLocalRef ins = (LLoadLocalRef) uins;
				DLoad load = new DLoad(block.stack().getName(ins.offset()));
				load = new DLoad(load);
				block.stack().set(ins.reg(), load);
				block.add(load);
				break;
			}

			case StoreLocal: {
				LStoreLocal ins = (LStoreLocal) uins;
				DNode regNode = block.stack().reg(ins.reg());

				// Work around compiler bug with chained assignments.
				// https://github.com/alliedmodders/sourcepawn/pull/118
				if (regNode == null) {
					DNode prev = block.nodes().last();
					assert (prev.type() == NodeType.Store);
					if (prev.type() == NodeType.Store) {
						regNode = prev.getOperand(1);
					}
				}

				DStore store = new DStore(block.stack().getName(ins.offset()), regNode);
				block.add(store);
				break;
			}

			case StoreLocalRef: {
				LStoreLocalRef ins = (LStoreLocalRef) uins;
				DLoad load = new DLoad(block.stack().getName(ins.offset()));
				DStore store = new DStore(load, block.stack().reg(ins.reg()));
				block.add(store);
				break;
			}

			case SysReq: {
				LSysReq sysreq = (LSysReq) uins;
				DConstant ins = (DConstant) block.stack().popValue();
				long argslength = ins.value();
				if (file_.PassArgCountAsSize())
					argslength /= 4;

				LinkedList<DNode> arguments = new LinkedList<DNode>();
				for (int i = 0; i < argslength; i++) {
					arguments.add(block.stack().popName());
				}
				DSysReq call = new DSysReq(sysreq.nativeX(), arguments.toArray(new DNode[0]));
				block.stack().set(Register.Pri, call);
				block.add(call);
				break;
			}

			case AddConstant: {
				LAddConstant ins = (LAddConstant) uins;
				DConstant val = new DConstant(ins.amount());
				DBinary node = new DBinary(SPOpcode.add, block.stack().pri(), val);
				block.stack().set(Register.Pri, node);
				block.add(val);
				block.add(node);
				break;
			}

			case MulConstant: {
				LMulConstant ins = (LMulConstant) uins;
				DConstant val = new DConstant(ins.amount());
				DBinary node = new DBinary(SPOpcode.smul, block.stack().pri(), val);
				block.stack().set(Register.Pri, node);
				block.add(val);
				block.add(node);
				break;
			}

			case Bounds: {
				LBounds ins = (LBounds) uins;
				DBoundsCheck node = new DBoundsCheck(block.stack().pri(), ins.amount());
				block.add(node);
				break;
			}

			case IndexAddress: {
				LIndexAddress ins = (LIndexAddress) uins;
				DArrayRef node = new DArrayRef(block.stack().alt(), block.stack().pri(), ins.shift());
				block.stack().set(Register.Pri, node);
				block.add(node);
				break;
			}

			case Move: {
				LMove ins = (LMove) uins;
				if (ins.reg() == Register.Pri)
					block.stack().set(Register.Pri, block.stack().alt());
				else
					block.stack().set(Register.Alt, block.stack().pri());
				break;
			}

			case Store: {
				DStore store = new DStore(block.stack().alt(), block.stack().pri());
				block.add(store);
				break;
			}

			case Load: {
				DLoad load = new DLoad(block.stack().pri());
				block.stack().set(Register.Pri, load);
				block.add(load);
				break;
			}

			case Swap: {
				LSwap ins = (LSwap) uins;
				DNode lhs = block.stack().popAsTemp();
				DNode rhs = block.stack().reg(ins.reg());
				DDeclareLocal local = new DDeclareLocal(ins.pc(), rhs);
				block.stack().set(ins.reg(), lhs);
				block.stack().push(local);
				block.add(local);
				break;
			}

			case IncI: {
				DIncDec inc = new DIncDec(block.stack().pri(), 1);
				block.add(inc);
				break;
			}

			case DecI: {
				DIncDec dec = new DIncDec(block.stack().pri(), -1);
				block.add(dec);
				break;
			}

			case IncLocal: {
				LIncLocal ins = (LIncLocal) uins;
				DDeclareLocal local = (DDeclareLocal) block.stack().getName(ins.offset());
				DIncDec inc = new DIncDec(local, 1);
				block.add(inc);
				break;
			}

			case IncReg: {
				LIncReg ins = (LIncReg) uins;
				DIncDec dec = new DIncDec(block.stack().reg(ins.reg()), 1);
				block.add(dec);
				break;
			}

			case DecLocal: {
				LDecLocal ins = (LDecLocal) uins;
				DDeclareLocal local = (DDeclareLocal) block.stack().getName(ins.offset());
				DIncDec dec = new DIncDec(local, -1);
				block.add(dec);
				break;
			}

			case DecReg: {
				LDecReg ins = (LDecReg) uins;
				DIncDec dec = new DIncDec(block.stack().reg(ins.reg()), -1);
				block.add(dec);
				break;
			}

			case Return: {
				DReturn node = new DReturn(block.stack().pri());
				block.add(node);
				break;
			}

			case PushLocal: {
				LPushLocal ins = (LPushLocal) uins;
				DLoad load = new DLoad(block.stack().getName(ins.offset()));
				DDeclareLocal local = new DDeclareLocal(ins.pc(), load);
				block.stack().push(local);
				block.add(load);
				block.add(local);
				break;
			}

			case Exchange: {
				DNode node = block.stack().alt();
				block.stack().set(Register.Alt, block.stack().pri());
				block.stack().set(Register.Pri, node);
				break;
			}

			case Unary: {
				LUnary ins = (LUnary) uins;
				DUnary unary = new DUnary(ins.spop(), block.stack().reg(ins.reg()));
				block.stack().set(Register.Pri, unary);
				block.add(unary);
				break;
			}

			case Binary: {
				LBinary ins = (LBinary) uins;
				DNode nodeLHS = block.stack().reg(ins.lhs());
				DNode nodeRHS = block.stack().reg(ins.rhs());
				DBinary binary = new DBinary(ins.spop(), nodeLHS, nodeRHS);
				block.stack().set(Register.Pri, binary);
				block.add(binary);

				// sdiv: PRI = ALT / PRI; ALT = ALT mod PRI
				if (ins.spop() == SPOpcode.sdiv_alt || ins.spop() == SPOpcode.sdiv) {
					binary = new DBinary(SPOpcode.sdiv_alt_mod, nodeLHS, nodeRHS);
					block.stack().set(Register.Alt, binary);
					block.add(binary);
				}
				break;
			}
			
			case ShiftLeftConstant: {
				LShiftLeftConstant ins = (LShiftLeftConstant) uins;
				DConstant val = new DConstant(ins.val());
				DBinary node = new DBinary(SPOpcode.shl, block.stack().reg(ins.reg()), val);
				block.stack().set(ins.reg(), node);
				block.add(val);
				block.add(node);
				break;
			}

			case PushGlobal: {
				LPushGlobal ins = (LPushGlobal) uins;
				Variable global = file_.lookupGlobal(ins.address());
				if (global == null)
					global = file_.lookupVariable(ins.pc(), ins.address(), Scope.Static);
				DGlobal dglobal = new DGlobal(global);
				DNode node = new DLoad(dglobal);
				DDeclareLocal local = new DDeclareLocal(ins.pc(), node);
				block.stack().push(local);
				block.add(dglobal);
				block.add(node);
				block.add(local);
				break;
			}

			case LoadGlobal: {
				LLoadGlobal ins = (LLoadGlobal) uins;
				Variable global = file_.lookupGlobal(ins.address());
				if (global == null)
					global = file_.lookupVariable(ins.pc(), ins.address(), Scope.Static);
				DNode dglobal = new DGlobal(global);
				DNode node = new DLoad(dglobal);
				block.stack().set(ins.reg(), node);
				block.add(dglobal);
				block.add(node);
				break;
			}

			case StoreGlobal: {
				LStoreGlobal ins = (LStoreGlobal) uins;
				Variable global = file_.lookupGlobal(ins.address());
				if (global == null)
					global = file_.lookupVariable(ins.pc(), ins.address(), Scope.Static);
				DGlobal node = new DGlobal(global);
				DStore store = new DStore(node, block.stack().reg(ins.reg()));
				block.add(node);
				block.add(store);
				break;
			}

			case Call: {
				LCall ins = (LCall) uins;
				Function f = file_.lookupFunction((long) ins.address());
				DConstant args = (DConstant) block.stack().popValue();
				long argslength = args.value();
				if (file_.PassArgCountAsSize())
					argslength /= 4;

				LinkedList<DNode> arguments = new LinkedList<DNode>();
				for (int i = 0; i < argslength; i++)
					arguments.add(block.stack().popName());
				DCall call = new DCall(f, arguments.toArray(new DNode[0]));
				block.stack().set(Register.Pri, call);
				block.add(call);
				break;
			}

			case EqualConstant: {
				LEqualConstant ins = (LEqualConstant) uins;
				DConstant c = new DConstant(ins.value());
				DBinary node = new DBinary(SPOpcode.eq, block.stack().reg(ins.reg()), c);
				block.stack().set(Register.Pri, node);
				block.add(c);
				block.add(node);
				break;
			}

			case LoadIndex: {
				LLoadIndex ins = (LLoadIndex) uins;
				DArrayRef aref = new DArrayRef(block.stack().alt(), block.stack().pri(), ins.shift());
				DLoad load = new DLoad(aref);
				block.stack().set(Register.Pri, load);
				block.add(aref);
				block.add(load);
				break;
			}

			case ZeroGlobal: {
				LZeroGlobal ins = (LZeroGlobal) uins;
				Variable global = file_.lookupGlobal(ins.address());
				if (global == null)
					global = file_.lookupVariable(ins.pc(), ins.address(), Scope.Static);
				DNode dglobal = new DGlobal(global);
				DConstant rhs = new DConstant(0);
				DStore lhs = new DStore(dglobal, rhs);
				block.add(dglobal);
				block.add(rhs);
				block.add(lhs);
				break;
			}

			case IncGlobal: {
				LIncGlobal ins = (LIncGlobal) uins;
				Variable global = file_.lookupGlobal(ins.address());
				if (global == null)
					global = file_.lookupVariable(ins.pc(), ins.address(), Scope.Static);
				DNode dglobal = new DGlobal(global);

				DLoad load = new DLoad(dglobal);
				DConstant val = new DConstant(1);
				DBinary add = new DBinary(SPOpcode.add, load, val);
				DStore store = new DStore(dglobal, add);
				block.add(load);
				block.add(val);
				block.add(add);
				block.add(store);
				break;
			}

			case DecGlobal: {
				LDecGlobal ins = (LDecGlobal) uins;
				Variable global = file_.lookupGlobal(ins.address());
				if (global == null)
					global = file_.lookupVariable(ins.pc(), ins.address(), Scope.Static);
				DNode dglobal = new DGlobal(global);

				DLoad load = new DLoad(dglobal);
				DConstant val = new DConstant(1);
				DBinary sub = new DBinary(SPOpcode.sub, load, val);
				DStore store = new DStore(dglobal, sub);
				block.add(load);
				block.add(val);
				block.add(sub);
				block.add(store);
				break;
			}

			case StoreGlobalConstant: {
				LStoreGlobalConstant lstore = (LStoreGlobalConstant) uins;
				Variable var = file_.lookupGlobal(lstore.address());
				if (var == null)
					var = file_.lookupVariable(lstore.pc(), lstore.address(), Scope.Static);
				DConstant val = new DConstant(lstore.value());
				DGlobal global = new DGlobal(var);
				DStore store = new DStore(global, val);
				block.add(val);
				block.add(global);
				block.add(store);
				break;
			}

			case StoreLocalConstant: {
				LStoreLocalConstant lstore = (LStoreLocalConstant) uins;
				DDeclareLocal var = (DDeclareLocal) block.stack().getName(lstore.address());
				DConstant val = new DConstant(lstore.value());
				DStore store = new DStore(var, val);
				block.add(val);
				block.add(store);
				break;
			}

			case ZeroLocal: {
				LZeroLocal lstore = (LZeroLocal) uins;
				DDeclareLocal var = (DDeclareLocal) block.stack().getName(lstore.address());
				DConstant val = new DConstant(0);
				DStore store = new DStore(var, val);
				block.add(val);
				block.add(store);
				break;
			}

			case Heap: {
				LHeap ins = (LHeap) uins;
				DHeap heap = new DHeap(ins.amount());
				block.add(heap);
				block.stack().set(Register.Alt, heap);
				break;
			}

			case MemCopy: {
				LMemCopy ins = (LMemCopy) uins;
				DMemCopy copy = new DMemCopy(block.stack().alt(), block.stack().pri(), ins.bytes());
				block.add(copy);
				break;
			}

			case Switch: {
				LSwitch ins = (LSwitch) uins;
				DSwitch switch_ = new DSwitch(block.stack().pri(), ins);
				block.add(switch_);
				break;
			}

			case GenArray: {
				LGenArray ins = (LGenArray) uins;
				DNode[] dims = new DNode[ins.dims()];
				for (int i = 0; i < ins.dims(); i++) {
					dims[i] = block.stack().popValue();
				}
				DGenArray genarray_ = new DGenArray(ins.pc() + 4 * ins.dims() + 4, dims, ins.autozero());
				block.stack().push(genarray_);
				block.add(genarray_);
				break;
			}

			case StackAdjust: {
				LStackAdjust ins = (LStackAdjust) uins;
				assert (ins.value() % 4 == 0);
				// Add the missing amount of stack slots.
				if (ins.value() < block.stack().depth()) {
					int amt = (ins.value() - block.stack().depth()) / -4;
					for (int i = 0; i < amt; i++) {
						DDeclareLocal local = new DDeclareLocal(ins.pc(), null);
						block.stack().push(local);
						block.add(local);
					}
				}
				// Pop the exceeding ones.
				else {
					int amt = (block.stack().depth() - ins.value()) / -4;
					for (int i = 0; i < amt; i++)
						block.stack().pop();
				}

				// Older compilers - even after |goto| disabled - could still
				// emit this opcode with just a unused retag like
				// |NewTag:GetEngineTime();| -> stkadjust 0x0.
				// Don't mark this block as a goto target in that case.
				// Assume the stkadjust opcode being the first of the block.
				if (ins.value() > 0 || block.nodes().first() == block.nodes().last())
					block.add(new DLabel(ins.pc()));
				break;
			}

			case LoadCtrl: {
				// Hack in old |goto| support.
				LLoadCtrl ins = (LLoadCtrl) uins;
				assert (ins.ctrlregindex() == 5); // PRI = FRM
				block.stack().set(Register.Pri, new DConstant(0));
				break;
			}

			case StoreCtrl: {
				// Hack in old |goto| support.
				LStoreCtrl ins = (LStoreCtrl) uins;
				assert (ins.ctrlregindex() == 4); // STK = PRI
				DNode pri = block.stack().pri();
				assert (pri.type() == NodeType.Binary);

				DBinary add = (DBinary) pri;
				assert (add.lhs().type() == NodeType.Constant && add.rhs().type() == NodeType.Constant);
				DConstant frm = (DConstant) add.lhs();
				assert (frm.value() == 0);
				DConstant stkadjust = (DConstant) add.rhs();
				assert (stkadjust.value() <= 0);
				assert (stkadjust.value() % 4 == 0);
				// Add the missing amount of stack slots.
				if (stkadjust.value() < block.stack().depth()) {
					long amt = (stkadjust.value() - block.stack().depth()) / -4;
					for (int i = 0; i < amt; i++) {
						DDeclareLocal local = new DDeclareLocal(ins.pc(), null);
						block.stack().push(local);
						block.add(local);
					}
				}
				// Pop the exceeding ones.
				else {
					long amt = (block.stack().depth() - stkadjust.value()) / -4;
					for (int i = 0; i < amt; i++)
						block.stack().pop();
				}
				block.add(new DLabel(ins.pc()));
				break;
			}

			default:
				throw new Exception("unhandled opcode " + uins.op());
			}
		}

		for (int i = 0; i < block.lir().idominated().length; i++) {
			LBlock lir = block.lir().idominated()[i];
			if (lir == null)
				continue;
			traverse(blocks_[lir.id()]);
		}
	}

	public NodeBlock[] buildNodes() throws Exception {
		blocks_[0].inherit(graph_, null);
		traverse(blocks_[0]);
		return blocks_;
	}
}
