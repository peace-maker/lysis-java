package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;

public class LShiftLeftConstant extends LInstructionReg {

	private long val_;

	public LShiftLeftConstant(long val, Register reg) {
		super(reg);
		val_ = val;
	}

	public long val() {
		return val_;
	}

	@Override
	public Opcode op() {
		return Opcode.ShiftLeftConstant;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException {
		tw.writeBytes("shl.c." + RegisterName(reg()) + " " + val());
	}

}
