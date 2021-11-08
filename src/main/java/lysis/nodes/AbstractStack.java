package lysis.nodes;

import java.util.LinkedList;

import lysis.lstructure.Register;
import lysis.nodes.types.DDeclareLocal;
import lysis.nodes.types.DGenArray;
import lysis.nodes.types.DNode;

public class AbstractStack {
	public class UnbalancedStackException extends Exception {
		private static final long serialVersionUID = 1L;
	}

	private class StackEntry {
		public DNode declaration;
		public DNode assignment;

		public StackEntry(DNode decl, DNode assn) {
			declaration = decl;
			assignment = assn;
		}
	}

	private LinkedList<StackEntry> stack_;
	private StackEntry[] args_;
	private DNode pri_;
	private DNode alt_;

	public AbstractStack(int nargs) {
		stack_ = new LinkedList<StackEntry>();
		args_ = new StackEntry[nargs];
		for (int i = 0; i < args_.length; i++)
			args_[i] = new StackEntry(null, null);
	}

	public AbstractStack(AbstractStack other) {
		stack_ = new LinkedList<StackEntry>();
		for (int i = 0; i < other.stack_.size(); i++)
			stack_.add(new StackEntry(other.stack_.get(i).declaration, other.stack_.get(i).assignment));
		args_ = new StackEntry[other.args_.length];
		for (int i = 0; i < args_.length; i++)
			args_[i] = new StackEntry(other.args_[i].declaration, other.args_[i].assignment);
		pri_ = other.pri_;
		alt_ = other.alt_;
	}

	public void push(DDeclareLocal local) {
		stack_.add(new StackEntry(local, local.value()));
		local.setOffset(depth());
	}

	public void push(DGenArray array) {
		stack_.add(new StackEntry(array, null));
		array.setOffset(depth());
	}

	private StackEntry popEntry() throws UnbalancedStackException {
		if (stack_.size() == 0)
			throw new UnbalancedStackException();

		StackEntry e = stack_.get(stack_.size() - 1);
		stack_.remove(stack_.size() - 1);
		return e;
	}

	public void pop() throws UnbalancedStackException {
		popEntry();
	}

	public DNode popAsTemp() throws UnbalancedStackException {
		StackEntry entry = popEntry();
		if (entry.declaration.uses().size() == 0)
			return entry.assignment;
		assert (false); // , "not yet handled"
		return null;
	}

	public DNode popName() throws UnbalancedStackException {
		DNode value = stack_.get(stack_.size() - 1).declaration;
		pop();
		return value;
	}

	public DNode popValue() throws UnbalancedStackException {
		DNode value = stack_.get(stack_.size() - 1).assignment;
		pop();
		return value;
	}

	public DNode peekName() {
		DNode value = stack_.get(stack_.size() - 1).declaration;
		return value;
	}

	private StackEntry entry(long offset) {
		if (offset < 0)
			return stack_.get((int) ((-offset / 4) - 1));

		int argidx = (int) ((offset - 12) / 4);
		if (argidx < 0 || argidx >= args_.length)
			return new StackEntry(null, null);

		return args_[argidx];
	}

	public DNode getName(long offset) {
		return entry(offset).declaration;
	}

	public int nargs() {
		return args_.length;
	}

	public int depth() {
		return -(stack_.size() * 4);
	}

	public DNode pri() {
		return pri_;
	}

	public DNode alt() {
		return alt_;
	}

	public DNode reg(Register reg) {
		return (reg == Register.Pri) ? pri_ : alt_;
	}

	public void set(Register reg, DNode node) {
		if (reg == Register.Pri)
			pri_ = node;
		else
			alt_ = node;
	}

	public void set(long offset, DNode value) {
		entry(offset).assignment = value;
	}

	public void init(long offset, DDeclareLocal local) {
		entry(offset).declaration = local;
		entry(offset).assignment = null;
	}
}
