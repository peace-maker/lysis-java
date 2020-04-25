package lysis.nodes;

import lysis.lstructure.Scope;
import lysis.lstructure.Signature;
import lysis.lstructure.Variable;
import lysis.lstructure.VariableType;
import lysis.nodes.types.DArrayRef;
import lysis.nodes.types.DBinary;
import lysis.nodes.types.DCall;
import lysis.nodes.types.DConstant;
import lysis.nodes.types.DDeclareLocal;
import lysis.nodes.types.DGenArray;
import lysis.nodes.types.DGlobal;
import lysis.nodes.types.DHeap;
import lysis.nodes.types.DInlineArray;
import lysis.nodes.types.DLoad;
import lysis.nodes.types.DMemCopy;
import lysis.nodes.types.DNode;
import lysis.nodes.types.DStore;
import lysis.nodes.types.DSysReq;
import lysis.nodes.types.DUse;
import lysis.sourcepawn.SPOpcode;
import lysis.types.TypeSet;
import lysis.types.TypeUnit;

public class NodeAnalysis {
	public static void RemoveGuards(NodeGraph graph) throws Exception {
		for (int i = graph.numBlocks() - 1; i >= 0; i--) {
			NodeBlock block = graph.blocks(i);
			for (NodeList.reverse_iterator iter = block.nodes().rbegin(); iter.more();) {
				if (iter.node().guard()) {
					assert (iter.node().idempotent());
					iter.node().removeFromUseChains();
					block.nodes().remove(iter);
					continue;
				}
				iter.next();
			}
		}
	}

	private static void RemoveDeadCodeInBlock(NodeBlock block) throws Exception {
		for (NodeList.reverse_iterator iter = block.nodes().rbegin(); iter.more();) {
			if (iter.node().type() == NodeType.DeclareLocal) {
				DDeclareLocal decl = (DDeclareLocal) iter.node();
				if (decl.var() == null
						&& (decl.uses().size() == 0 || (decl.uses().size() == 1 && decl.value() != null))) {
					// This was probably just a stack temporary.
					if (decl.uses().size() == 1) {
						DUse use = decl.uses().getFirst();
						// This a onetime variable. Don't remove it, so we can keep the type info.
						if (decl.value() != null && (decl.value().type() == NodeType.Constant
								|| (decl.value().type() == NodeType.LocalRef && decl.value().getOperand(0) != null
										&& decl.value().getOperand(0).getOperand(0) != null
										&& decl.value().getOperand(0).getOperand(0).type() == NodeType.Constant))) {
							// use.node().replaceOperand(use.index(),
							// decl.value().getOperand(0).getOperand(0)); // Needs type info.
							iter.next();
							continue;
						} else
							use.node().replaceOperand(use.index(), decl.value());
					}
					iter.node().removeFromUseChains();
					block.nodes().remove(iter);
					continue;
				}
			}

			if ((iter.node().type() == NodeType.Store && iter.node().getOperand(0).type() == NodeType.Heap
					&& iter.node().getOperand(0).uses().size() == 1)) {
				iter.node().removeFromUseChains();
				block.nodes().remove(iter);
			}

			if (!iter.node().idempotent() || iter.node().guard() || iter.node().uses().size() > 0) {
				iter.next();
				continue;
			}

			iter.node().removeFromUseChains();
			block.nodes().remove(iter);
		}
	}

	// We rely on accurate use counts to rename nodes in a readable way,
	// so we provide a phase for updating use info.
	public static void RemoveDeadCode(NodeGraph graph) throws Exception {
		for (int i = graph.numBlocks() - 1; i >= 0; i--)
			RemoveDeadCodeInBlock(graph.blocks(i));
	}

	private static boolean IsArray(TypeSet ts) {
		if (ts == null)
			return false;
		if (ts.numTypes() != 1)
			return false;
		TypeUnit tu = ts.types(0);
		if (tu.kind() == TypeUnit.Kind.Array)
			return true;
		if (tu.kind() == TypeUnit.Kind.Reference) {
			// tu.inner().dims() <= tu2.inner().dims()!
			if (tu.inner().kind() == TypeUnit.Kind.Array && tu.inner().type() != null)
				return true;
		}

		return false;
	}

	private static DNode GuessArrayBase(DNode op1, DNode op2) {
		if (op1.usedAsArrayIndex())
			return op2;
		if (op2.usedAsArrayIndex())
			return op1;
		if (op1.type() == NodeType.ArrayRef || op1.type() == NodeType.LocalRef || IsArray(op1.typeSet())) {
			return op1;
		}
		if (op2.type() == NodeType.ArrayRef || op2.type() == NodeType.LocalRef || IsArray(op2.typeSet())) {
			return op2;
		}
		if (op1.type() == NodeType.Load) {
			DLoad load = (DLoad) op1;
			if (load.from().type() == NodeType.ArrayRef)
				return op1;
		}
		if (op2.type() == NodeType.Load) {
			DLoad load = (DLoad) op2;
			if (load.from().type() == NodeType.ArrayRef)
				return op2;
		}
		return null;
	}

	private static boolean IsReallyLikelyArrayCompute(DNode node, DNode abase) {
		if (abase.type() == NodeType.ArrayRef)
			return true;
		if (abase.type() == NodeType.Load) {
			DLoad load = (DLoad) abase;
			if (load.from().type() == NodeType.ArrayRef)
				return true;
		}
		if (IsArray(abase.typeSet()))
			return true;
		for (DUse use : node.uses()) {
			if (use.node().type() == NodeType.Store || use.node().type() == NodeType.Load)
				return true;
		}
		return false;
	}

	/*
	 * private static boolean IsArrayOpCandidate(DNode node) { if (node.type() ==
	 * NodeType.Load || node.type() == NodeType.Store) return true; if (node.type()
	 * == NodeType.Binary) { DBinary bin = (DBinary)node; return bin.spop() ==
	 * SPOpcode.add; } return false; }
	 */

	private static boolean ShouldOperantsBeSwitched(DNode abase, DNode index, DBinary binary) throws Exception {
		if (abase.type() != NodeType.Load || index.type() != NodeType.Load)
			return false;

		if (abase.getOperand(0) == index && index.getOperand(0).type() == NodeType.DeclareLocal) {
			// Make sure this binary is on the left side of the store?
			/*
			 * DBinary bin = binary; while(bin.uses().size() == 1 &&
			 * bin.uses().get(0).node().type() == NodeType.Binary) bin = (DBinary)
			 * bin.uses().get(0).node(); if(bin.uses().size() == 1 &&
			 * bin.uses().get(0).node().type() == NodeType.Store &&
			 * bin.uses().get(0).node().getOperand(0) == bin)
			 */
			return true;

		}
		return false;
	}

	private static boolean CollapseArrayReferences(NodeBlock block) throws Exception {
		boolean changed = false;

		for (NodeList.reverse_iterator iter = block.nodes().rbegin(); iter.more(); iter.next()) {
			DNode node = iter.node();

			if (node.type() == NodeType.Store || node.type() == NodeType.Load) {
				if (node.getOperand(0).type() != NodeType.ArrayRef && IsArray(node.getOperand(0).typeSet())) {
					DConstant index0 = new DConstant(0);
					DArrayRef aref0 = new DArrayRef(node.getOperand(0), index0, 0);
					block.nodes().insertBefore(node, index0);
					block.nodes().insertBefore(node, aref0);
					node.replaceOperand(0, aref0);
					changed = true;
					continue;
				}
			}

			if (node.type() != NodeType.Binary)
				continue;

			DBinary binary = (DBinary) node;
			if (binary.spop() != SPOpcode.add)
				continue;

			if (binary.lhs().type() == NodeType.LocalRef) {
				assert (true);
			}

			// Check for an array index.
			DNode abase = GuessArrayBase(binary.lhs(), binary.rhs());
			if (abase == null)
				continue;
			DNode index = (abase == binary.lhs()) ? binary.rhs() : binary.lhs();

			if (ShouldOperantsBeSwitched(abase, index, binary)) {
				abase = binary.rhs();
				index = binary.lhs();
			}

			if (!IsReallyLikelyArrayCompute(binary, abase))
				continue;

			// Don't collapse stuff like
			// array[2] += 5;
			if (abase.type() == NodeType.Load) {
				DLoad load = (DLoad) abase;
				if (load.from().type() == NodeType.ArrayRef && binary.uses().size() == 1
						&& index.type() == NodeType.Constant && binary.uses().get(0).node().type() == NodeType.Store) {
					DStore store = (DStore) binary.uses().get(0).node();
					if (store.rhs() == binary)
						continue;
				}
			}

			// Make sure, we don't collapse more dimensions than the array we're dealing
			// with has.
			int num_dims = 1;
			DNode check = abase;
			while (check.type() == NodeType.Load) {
				DLoad load = (DLoad) check;
				if (load.from().type() != NodeType.ArrayRef)
					break;

				num_dims++;
				DArrayRef ref = (DArrayRef) load.from();
				check = ref.lhs();
			}
			// System.out.printf("Already collapsed dims: %d (%s)%n", num_dims,
			// check.type());
			if (HasEnoughArrayDimensions(check, num_dims))
				continue;

			// Multi-dimensional arrays are indexed like:
			// x[y] => x + x[y]
			//
			// We recognize this and just remove the add, ignoring the
			// underlying representation of the array.
			if (index.type() == NodeType.Load && index.getOperand(0) == abase) {
				node.replaceAllUsesWith(index);
				node.removeFromUseChains();
				block.nodes().remove(iter);
				changed = true;
				continue;
			}

			if (index.type() == NodeType.Constant)
				index.setUsedAsArrayIndex();

			// Otherwise, create a new array reference.
			DArrayRef aref = new DArrayRef(abase, index);
			iter.node().replaceAllUsesWith(aref);
			iter.node().removeFromUseChains();
			block.nodes().remove(iter);
			block.nodes().insertBefore(iter.node(), aref);
			changed = true;
		}

		return changed;
	}

	// Find adds that should really be array references.
	public static void CollapseArrayReferences(NodeGraph graph) throws Exception {
		boolean changed;
		do {
			changed = false;
			for (int i = graph.numBlocks() - 1; i >= 0; i--)
				changed |= CollapseArrayReferences(graph.blocks(i));
		} while (changed);
	}

	public static boolean HasEnoughArrayDimensions(DNode check, int num_dims) throws Exception {
		switch (check.type()) {
		case Load: {
			return HasEnoughArrayDimensions(((DLoad) check).from(), num_dims);
		}
		case DeclareLocal: {
			DDeclareLocal local = (DDeclareLocal) check;
			// System.out.printf("localvar %s has %d dimensions.%n", local.var().name(),
			// local.var().dims().length);
			if (local.var() != null && local.var().dims() != null && local.var().dims().length < num_dims)
				return true;
			break;
		}
		case Global: {
			DGlobal global = (DGlobal) check;
			// System.out.printf("global %s has %d dimensions.%n", global.var().name(),
			// global.var().dims().length);
			if (global.var() != null && global.var().dims() != null && global.var().dims().length < num_dims)
				return true;
			break;
		}
		case GenArray: {
			DGenArray genarray = (DGenArray) check;
			// System.out.printf("genarray %s has %d dimensions.%n", genarray.var().name(),
			// genarray.var().dims().length);
			if (genarray.var() != null && genarray.var().dims() != null && genarray.var().dims().length < num_dims)
				return true;
			break;
		}
		case Constant: {
			// Hopefully this isn't too blue-eyed. Can't get a variable of a constant..
			// Catches cases like
			// new Float:newspeed = GetEntPropFloat(client, PropType:1, "m_flMaxspeed", 0) +
			// g_flClassApplySpeed[client];
			// DConstant constant = (DConstant)check;
			// System.out.printf("constant = %d.%n", constant.value());
			if (check.uses().size() == 1 && check.uses().get(0).node().type() == NodeType.Binary) {
				return HasEnoughArrayDimensions(check.uses().get(0).node().getOperand(0), num_dims);
			}

			break;
		}
		default:
			break;
		}
		return false;
	}

	public static void CoalesceLoadsAndDeclarations(NodeGraph graph) throws Exception {
		for (int i = 0; i < graph.numBlocks(); i++) {
			NodeBlock block = graph.blocks(i);
			for (NodeList.iterator iter = block.nodes().begin(); iter.more();) {
				DNode node = iter.node();

				if (node.type() == NodeType.DeclareLocal) {
					// Peephole next = store(this, expr)
					DDeclareLocal local = (DDeclareLocal) node;
					if (node.next().type() == NodeType.Store) {
						DStore store = (DStore) node.next();
						if (store.getOperand(0) == local && store.getOperand(1).type() != NodeType.Unary) {
							DNode replacement;
							if (store.spop() != SPOpcode.nop)
								replacement = new DBinary(store.spop(), local.getOperand(0), store.getOperand(1));
							else
								replacement = store.getOperand(1);
							local.replaceOperand(0, replacement);
							store.removeFromUseChains();
							iter.next();
							block.nodes().remove(iter);
							continue;
						}
					}
				}

				iter.next();
			}
		}
	}

	private static void CoalesceLoadStores(NodeBlock block) throws Exception {
		for (NodeList.reverse_iterator riter = block.nodes().rbegin(); riter.more(); riter.next()) {
			if (riter.node().type() != NodeType.Store)
				continue;

			DStore store = (DStore) riter.node();

			DNode coalesce = null;
			if (store.rhs().type() == NodeType.Binary) {
				DBinary rhs = (DBinary) store.rhs();
				if (rhs.lhs().type() == NodeType.Load) {
					DLoad load = (DLoad) rhs.lhs();
					if (load.from() == store.lhs()) {
						coalesce = rhs.rhs();
					} else if (load.from().type() == NodeType.ArrayRef && store.lhs().type() == NodeType.Load) {
						DArrayRef aref = (DArrayRef) load.from();
						load = (DLoad) store.lhs();
						if (aref.abase() == load && aref.index().type() == NodeType.Constant
								&& ((DConstant) aref.index()).value() == 0) {
							coalesce = rhs.rhs();
							store.replaceOperand(0, aref);
						}
					}
				}
				if (coalesce != null)
					store.makeStoreOp(rhs.spop());
			} else if (store.rhs().type() == NodeType.Load && store.rhs().getOperand(0) == store.lhs()) {
				// AWFUL PATTERN MATCHING AHEAD.
				// This *looks* like a dead store, but there is probably
				// something in between the load and store that changes
				// the reference. We assume this has to be an incdec.
				if (store.prev().type() == NodeType.IncDec && store.prev().getOperand(0) == store.rhs()) {
					// This detects a weird case in ucp.smx:
					// v0 = ArrayRef
					// v1 = Load(v0)
					// -- Dec(v1)
					// -- Store(v0, v1)
					// This appears to be:
					// *ref = (--*ref)
					// But, this should suffice:
					// --*ref
					store.removeFromUseChains();
					block.nodes().remove(riter);
					assert (riter.node().type() == NodeType.IncDec);
					riter.node().replaceOperand(0, riter.node().getOperand(0).getOperand(0));
				}
			}

			if (coalesce != null)
				store.replaceOperand(1, coalesce);
		}
	}

	public static void CoalesceLoadStores(NodeGraph graph) throws Exception {
		for (int i = 0; i < graph.numBlocks(); i++)
			CoalesceLoadStores(graph.blocks(i));
	}

	private static Signature SignatureOf(DNode node) {
		if (node.type() == NodeType.Call)
			return ((DCall) node).function();
		return ((DSysReq) node).nativeX();
	}

	// Print the initialization of strings
	// new String:bla[] = "HALLO";
	// Print local inline arrays too!
	// new x[] = {1,2,3};
	// Print static copys of arrays
	// arr1 = arr2;
	public static void HandleMemCopys(NodeGraph graph) throws Exception {
		for (int i = 0; i < graph.numBlocks(); i++) {
			NodeBlock block = graph.blocks(i);
			for (NodeList.iterator iter = block.nodes().begin(); iter.more(); iter.next()) {
				DNode node = iter.node();

				if (node.type() == NodeType.MemCopy) {
					DMemCopy mcpy = (DMemCopy) node;
					// This is a multidimensional array copied to an array
					// new arr1[2][10], arr2[10];
					// arr2 = arr1[0];
					if (mcpy.from().type() == NodeType.Load && mcpy.to().type() == NodeType.DeclareLocal) {
						DLoad load = (DLoad) mcpy.from();
						DDeclareLocal local = (DDeclareLocal) mcpy.to();

						if (local.var() != null && local.var().type() == VariableType.Array) {
							DStore store = new DStore(local, load);
							block.nodes().insertAfter(node, store);
						}
					// This is a multidimensional array copied to another multidimensional array.
					// new arr1[2][10], arr2[2][10];
					// arr2[1] = arr1[0];
					} else if (mcpy.from().type() == NodeType.ArrayRef && mcpy.to().type() == NodeType.Load) {
						DArrayRef arrayref = (DArrayRef) mcpy.from();
						DLoad load = (DLoad) mcpy.to();
						DStore store = new DStore(load, arrayref);
						block.nodes().insertAfter(node, store);
					// Copy one local array into another local array.
					// new arr1[64], arr2[64];
					// arr2 = arr1;
					} else if (mcpy.from().type() == NodeType.DeclareLocal && mcpy.to().type() == NodeType.DeclareLocal) {
						DDeclareLocal local_from = (DDeclareLocal) mcpy.from();
						DDeclareLocal local_to = (DDeclareLocal) mcpy.to();
						
						if (local_from.var() != null && local_from.var().type() == VariableType.Array
						 && local_to.var() != null && local_to.var().type() == VariableType.Array) {
							DStore store = new DStore(local_to, local_from);
							block.nodes().insertAfter(node, store);
						}
					// Copy one global or static array into another.
					} else if(mcpy.from().type() == NodeType.Constant && mcpy.to().type() == NodeType.Constant) {
						DConstant con_from = (DConstant) mcpy.from();
						DConstant con_to = (DConstant) mcpy.to();
						
						if (con_from.value() <= 0 || con_to.value() <= 0)
							continue;
						
						// Try to lookup the corresponding variables.
						Variable global_from = graph.file().lookupGlobal(con_from.value());
						if (global_from == null)
							global_from = graph.file().lookupVariable(con_from.pc(), con_from.value(), Scope.Static);
						Variable global_to = graph.file().lookupGlobal(con_to.value());
						if (global_to == null)
							global_to = graph.file().lookupVariable(con_to.pc(), con_to.value(), Scope.Static);
					
						if (global_from == null || global_to == null)
							continue;
						
						// Construct a local reference of the global vars.
						DGlobal dglobal_from = new DGlobal(global_from);
						DNode load_from = new DLoad(dglobal_from);
						DDeclareLocal declare_from = new DDeclareLocal(con_from.pc(), load_from);
						block.nodes().insertAfter(node, dglobal_from);
						block.nodes().insertAfter(dglobal_from, load_from);
						block.nodes().insertAfter(load_from, declare_from);
						
						DGlobal dglobal_to = new DGlobal(global_to);
						DNode load_to = new DLoad(dglobal_to);
						DDeclareLocal declare_to = new DDeclareLocal(con_to.pc(), load_to);
						block.nodes().insertAfter(declare_from, dglobal_to);
						block.nodes().insertAfter(dglobal_to, load_to);
						block.nodes().insertAfter(load_to, declare_to);
						
						// Assign the arrays.
						DStore store = new DStore(declare_to, declare_from);
						block.nodes().insertAfter(declare_to, store);

					// Copy an inline array or global variable into another array.
					} else if (mcpy.from().type() == NodeType.Constant && mcpy.to().type() == NodeType.DeclareLocal
							|| mcpy.from().type() == NodeType.DeclareLocal && mcpy.to().type() == NodeType.Constant) {
						DConstant con = null;
						DDeclareLocal local = null;
						// Copy a constant (global variable or constant array/string) to a local variable.
						if (mcpy.from().type() == NodeType.Constant) {
							con = (DConstant) mcpy.from();
							local = (DDeclareLocal) mcpy.to();
						// Copy a local variable to a constant (most likely a global variable).
						} else {
							con = (DConstant) mcpy.to();
							local = (DDeclareLocal) mcpy.from();
						}

						if (con.value() > 0 && local.var() != null && local.var().type() == VariableType.Array) {
							// See if there is a global variable at that address.
							Variable global = graph.file().lookupGlobal(con.value());
							if (global == null)
								global = graph.file().lookupVariable(con.pc(), con.value(), Scope.Static);
							if (global == null) {
								// This is the initialization of an inline array.
								DInlineArray ia = new DInlineArray(con.value(), mcpy.bytes());
								block.nodes().insertAfter(node, ia);

								// Give the inline array some type information.
								TypeUnit tu = TypeUnit.FromVariable(local.var());
								ia.addType(tu);

								// Initialization of variable array variable.
								if (local.block().lir().id() == con.block().lir().id()) {
									local.replaceOperand(0, ia);
								} else {
									DStore store = new DStore(local, ia);
									block.nodes().insertAfter(ia, store);
								}

							} else {
								// This is a static array copy.
								DGlobal dglobal = new DGlobal(global);
								DNode load = new DLoad(dglobal);
								DDeclareLocal declare = new DDeclareLocal(con.pc(), load);
								block.nodes().insertAfter(node, dglobal);
								block.nodes().insertAfter(dglobal, load);
								block.nodes().insertAfter(load, declare);
								if (mcpy.from().type() == NodeType.Constant) {
									// Copy from global to local variable.
									DStore store = new DStore(local, declare);
									block.nodes().insertAfter(declare, store);
								} else {
									// Copy from local to global variable.
									DStore store = new DStore(declare, local);
									block.nodes().insertAfter(declare, store);
								}
							}
						}
					}
				}
			}
		}
	}

	private static boolean AnalyzeHeapNode(NodeBlock block, DHeap node) throws Exception {
		// Easy case: compiler needed a lvalue.
		if (node.uses().size() == 2) {
			DUse lastUse = node.uses().getLast();
			DUse firstUse = node.uses().getFirst();
			if ((lastUse.node().type() == NodeType.Call || lastUse.node().type() == NodeType.SysReq)
					&& firstUse.node().type() == NodeType.Store && firstUse.index() == 0) {
				lastUse.node().replaceOperand(lastUse.index(), firstUse.node().getOperand(1));
				return true;
			}

			if ((lastUse.node().type() == NodeType.Call || lastUse.node().type() == NodeType.SysReq)
					&& firstUse.node().type() == NodeType.MemCopy && firstUse.index() == 0) {
				// heap -> memcpy always reads from DAT + constant
				DMemCopy memcopy = (DMemCopy) firstUse.node();
				DConstant cv = (DConstant) memcopy.from();
				DInlineArray ia = new DInlineArray(cv.value(), memcopy.bytes());
				block.nodes().insertAfter(node, ia);
				lastUse.node().replaceOperand(lastUse.index(), ia);

				// Give the inline array some type information.
				Signature signature = SignatureOf(lastUse.node());
				if (signature.args() != null) {
					TypeUnit tu = TypeUnit.FromArgument(signature.args()[lastUse.index()]);
					ia.addType(tu);
				}
				return true;
			}

			// Ternary operator with functions returning arrays.
			if (lastUse.node().type() == NodeType.Store && firstUse.node().type() == NodeType.Phi
					&& firstUse.node().numOperands() == 2 && node.next().type() == NodeType.Call) {
				lastUse.node().replaceOperand(lastUse.index(), node.next());
				return true;
			}
		} else if (node.uses().size() == 1) {
			// A function returning a string.
			DUse use = node.uses().getLast();
			if (use.node().type() == NodeType.SysReq || use.node().type() == NodeType.Call) {
				// Find the corresponding call. This is a hugh hack, but i can't think of
				// anything better now.
				DNode next = node;
				while (next != use.node()) {
					if (next.type() == NodeType.Call)
						break;
					next = next.next();
				}

				if (next.type() == NodeType.Call) {
					DCall call = (DCall) next;
					if (call.function().isStringReturn()) {
						use.node().replaceOperand(use.index(), call);
						return true;
					}
				}
			}
		}

		return false;
	}

	private static void AnalyzeHeapUsage(NodeBlock block) throws Exception {
		for (NodeList.reverse_iterator riter = block.nodes().rbegin(); riter.more(); riter.next()) {
			if (riter.node().type() == NodeType.Heap) {
				if (AnalyzeHeapNode(block, (DHeap) riter.node()))
					block.nodes().remove(riter);
			}
		}
	}

	public static void AnalyzeHeapUsage(NodeGraph graph) throws Exception {
		for (int i = 0; i < graph.numBlocks(); i++)
			AnalyzeHeapUsage(graph.blocks(i));
	}

	public static String PrintRecursively(DNode node, DNode start) {
		String ret = node.type().toString() + "#" + node.hashCode() + " (uses: " + node.uses().size() + ")\n";
		switch (node.type()) {
		case Binary: {
			DBinary binary = (DBinary) node;
			DNode abase = GuessArrayBase(binary.lhs(), binary.rhs());
			ret += "\tbase: "
					+ (abase == null ? "null"
							: abase.type().toString() + "#" + abase.hashCode() + " (uses: " + abase.uses().size() + ")")
					+ "\n";
			ret += "\tislikelyarray: " + (abase == null ? "false" : IsReallyLikelyArrayCompute(binary, abase)) + "\n";
			ret += "\tlhs: " + binary.lhs().type().toString() + "#" + binary.lhs().hashCode() + " (uses: "
					+ binary.lhs().uses().size() + ")\n";
			ret += "\top: " + binary.spop().toString() + "\n";
			ret += "\trhs: " + binary.rhs().type().toString() + "#" + binary.rhs().hashCode() + " (uses: "
					+ binary.rhs().uses().size() + ")\n";
			break;
		}
		case Constant: {
			DConstant constant = (DConstant) node;
			ret += "\tval: " + constant.value() + "\n";
			break;
		}
		case Load: {
			DLoad load = (DLoad) node;
			ret += "\tfrom: " + load.from().type().toString() + "#" + load.from().hashCode() + " (uses: "
					+ load.from().uses().size() + ")\n";
			break;
		}
		case Store: {
			DStore store = (DStore) node;
			ret += "\tlhs: " + store.lhs().type().toString() + "#" + store.lhs().hashCode() + " (uses: "
					+ store.lhs().uses().size() + ")\n";
			ret += "\top: " + store.spop().toString() + "\n";
			ret += "\trhs: " + store.rhs().type().toString() + "#" + store.rhs().hashCode() + " (uses: "
					+ store.rhs().uses().size() + ")\n";
			break;
		}
		case ArrayRef: {
			DArrayRef arrayref = (DArrayRef) node;
			ret += "\tlhs: " + arrayref.lhs().type().toString() + "#" + arrayref.lhs().hashCode() + " (uses: "
					+ arrayref.lhs().uses().size() + ")\n";
			ret += "\trhs: " + arrayref.rhs().type().toString() + "#" + arrayref.rhs().hashCode() + " (uses: "
					+ arrayref.rhs().uses().size() + ")\n";
			break;
		}
		case DeclareLocal: {
			DDeclareLocal local = (DDeclareLocal) node;
			ret += "\tvar: " + (local.var() != null ? local.var().name() : "") + "\n";
			ret += "\tvalue: "
					+ (local.value() != null
							? local.value().type().toString() + "#" + local.value().hashCode() + " (uses: "
									+ local.value().uses().size() + ")"
							: "")
					+ "\n";
			break;
		}
		default:
			break;
		}
		ret += "\n";
		if (node.prev() != start)
			return ret + PrintRecursively(node.prev(), start);
		else
			return ret;
	}
}
