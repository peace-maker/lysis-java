package lysis.nodes;

import lysis.lstructure.LBlock;
import lysis.lstructure.LGraph;
import lysis.lstructure.Register;
import lysis.nodes.types.DDeclareLocal;
import lysis.nodes.types.DNode;
import lysis.nodes.types.DPhi;

public class NodeBlock {
	private LBlock lir_;
	private AbstractStack stack_;
	private NodeList nodes_;

	public NodeBlock(LBlock lir) {
		lir_ = lir;
		nodes_ = new NodeList();
	}

	private void joinRegs(Register reg, DNode value) throws Exception {
		if (value == null || stack_.reg(reg) == value)
			return;
		if (stack_.reg(reg) == null) {
			stack_.set(reg, value);
			return;
		}

		DPhi phi;
		DNode node = stack_.reg(reg);
		if (node.type() != NodeType.Phi || node.block() != this) {
			phi = new DPhi(node);
			stack_.set(reg, phi);
			add(phi);
		} else {
			phi = (DPhi) node;
		}
		phi.addInput(value);
	}

	public void inherit(LGraph graph, NodeBlock other) throws Exception {
		if (other == null) {
			stack_ = new AbstractStack(graph.nargs);
			for (int i = 0; i < graph.nargs; i++) {
				DDeclareLocal local = new DDeclareLocal(lir_.pc(), null);
				local.setOffset((i * 4) + 12);
				add(local);
				stack_.init((i * 4) + 12, local);
			}
		} else if (stack_ == null) {
			assert (other.stack_ != null);
			stack_ = new AbstractStack(other.stack_);
		} else {
			// Right now we only create phis for pri/alt.
			joinRegs(Register.Pri, other.stack_.pri());
			joinRegs(Register.Alt, other.stack_.alt());
		}
	}

	public void add(DNode node) {
		node.setBlock(this);
		nodes_.add(node);
	}

	public void prepend(DNode node) {
		node.setBlock(this);
		nodes_.insertBefore(nodes_.last(), node);
	}

	public void replace(NodeList.iterator_base where, DNode with) {
		with.setBlock(this);
		nodes_.replace(where, with);
	}

	public void replace(DNode where, DNode with) {
		with.setBlock(this);
		nodes_.replace(where, with);
	}

	public LBlock lir() {
		return lir_;
	}

	public AbstractStack stack() {
		return stack_;
	}

	public NodeList nodes() {
		return nodes_;
	}
}
