package lysis.instructions;

import lysis.lstructure.Register;

public abstract class LInstructionReg extends LInstruction {

	private Register reg_;

	public LInstructionReg(Register reg) {
		reg_ = reg;
	}

	public Register reg() {
		return reg_;
	}

}
