package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.LBlock;

public class LGoto extends LControlInstruction {

	public LGoto(LBlock target) {
		super(target);
	}

	public LBlock target() {
		return getSuccessor(0);
	}

	@Override
	public Opcode op() {
		return Opcode.Goto;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException {
		tw.writeBytes("goto block" + target().id());
	}

}
