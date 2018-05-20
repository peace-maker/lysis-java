package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;
import java.util.LinkedList;

import lysis.lstructure.LBlock;

public class LSwitch extends LControlInstruction {

	private LBlock defaultCase_;
	private LinkedList<SwitchCase> cases_;

	public LSwitch(LBlock defaultCase, LinkedList<SwitchCase> cases) {
		defaultCase_ = defaultCase;
		cases_ = cases;
	}

	public LBlock defaultCase() {
		return defaultCase_;
	}

	@Override
	public void replaceSuccessor(int i, LBlock block) {
		if (i == 0)
			defaultCase_ = block;
		else
			cases_.get(i - 1).target = block;
	}

	@Override
	public int numSuccessors() {
		return cases_.size() + 1;
	}

	@Override
	public LBlock getSuccessor(int i) {
		if (i == 0)
			return defaultCase_;
		return cases_.get(i - 1).target;
	}

	public int numCases() {
		return cases_.size();
	}

	public SwitchCase getCase(int i) {
		return cases_.get(i);
	}

	@Override
	public Opcode op() {
		return Opcode.Switch;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		String text = defaultCase().id() + (numCases() > 0 ? "," : "");
		for (int i = 0; i < numCases(); i++) {
			text += getCase(i).target.id();
			if (i != numCases() - 1)
				text += ",";
		}
		tw.writeBytes("switch.pri -> " + text);
	}

}
