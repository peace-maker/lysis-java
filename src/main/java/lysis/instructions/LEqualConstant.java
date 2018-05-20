package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;

public class LEqualConstant extends LInstructionReg {

	private long value_;

	public LEqualConstant(Register reg, long value) {
		super(reg);
		value_ = value;
	}

	public long value() {
		return value_;
	}

	@Override
	public Opcode op() {
		return Opcode.EqualConstant;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("eq.c." + RegisterName(reg()) + " " + value());
	}

}
