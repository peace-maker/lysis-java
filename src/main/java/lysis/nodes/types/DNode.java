package lysis.nodes.types;

import java.util.LinkedList;

import lysis.lstructure.Tag;
import lysis.lstructure.VariableType;
import lysis.nodes.NodeBlock;
import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;
import lysis.sourcepawn.SourcePawnFile;
import lysis.types.TypeSet;
import lysis.types.TypeUnit;

public abstract class DNode {
	private NodeBlock block_;
	private LinkedList<DUse> uses_ = new LinkedList<DUse>();
	private DNode next_;
	private DNode prev_;
	private boolean usedAsArrayIndex_ = false;
	private boolean usedAsReference_ = false;
	private TypeSet typeSet_ = null;

	protected void addUse(DNode other, int i) {
		uses_.add(new DUse(other, i));
	}

	public void initOperand(int i, DNode node) throws Exception {
		if (node != null)
			node.addUse(this, i);
		setOperand(i, node);
	}

	public void replaceOperand(int i, DNode node) throws Exception {
		if (getOperand(i) == node)
			return;

		if (getOperand(i) != null)
			getOperand(i).removeUse(i, this);
		initOperand(i, node);
	}

	public void replaceAllUsesWith(DNode node) throws Exception {
		DUse[] copies = uses().toArray(new DUse[0]);
		for (DUse use : copies)
			use.node().replaceOperand(use.index(), node);
	}

	public void removeUse(int index, DNode node) {
		DUse use = null;
		for (DUse u : uses()) {
			if (u.index() == index && u.node() == node) {
				use = u;
				break;
			}
		}
		assert (use != null);
		uses().remove(use);
	}

	// Remove this node from all use chains.
	public void removeFromUseChains() throws Exception {
		for (int i = 0; i < numOperands(); i++)
			replaceOperand(i, null);
	}

	public void setBlock(NodeBlock block) {
		block_ = block;
	}

	public LinkedList<DUse> uses() {
		return uses_;
	}

	public NodeBlock block() {
		return block_;
	}

	public DNode next() {
		return next_;
	}

	public DNode nextSet(DNode value) {
		if ((next_ != null && next_.type() == NodeType.Store) || (value != null && value.type() == NodeType.Store)) {
			assert (true);
		}
		next_ = value;
		return next_;
	}

	public DNode prev() {
		return prev_;
	}

	public DNode prevSet(DNode value) {
		prev_ = value;
		return prev_;
	}

	public boolean usedAsArrayIndex() {
		return usedAsArrayIndex_;
	}

	public void setUsedAsArrayIndex() {
		usedAsArrayIndex_ = true;
	}

	public boolean usedAsReference() {
		return usedAsReference_;
	}

	public void setUsedAsReference() {
		usedAsReference_ = true;
	}

	private TypeSet ensureTypeSet() {
		if (typeSet_ == null)
			typeSet_ = new TypeSet();
		return typeSet_;
	}

	public void addType(TypeUnit tu) {
		assert (tu != null);
		ensureTypeSet().addType(tu);
	}

	public void addTypes(TypeSet ts) {
		ensureTypeSet().addTypes(ts);
	}

	public TypeSet typeSet() {
		return ensureTypeSet();
	}

	public boolean guard() {
		return false;
	}

	public boolean idempotent() {
		return true;
	}

	public boolean controlFlow() {
		return false;
	}

	public abstract NodeType type();

	public abstract int numOperands();

	public abstract DNode getOperand(int i) throws Exception;

	protected abstract void setOperand(int i, DNode node) throws Exception;

	public abstract void accept(NodeVisitor visitor) throws Exception;

	public DNode applyType(SourcePawnFile file, Tag tag, VariableType type) throws Exception {
		return this;
	}
}
