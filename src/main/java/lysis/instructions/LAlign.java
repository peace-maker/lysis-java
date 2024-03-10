package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;

public class LAlign extends LInstructionReg {
	
	private long offset_;

	public long offset() {
		return offset_;
	}
    public LAlign(long offset, Register reg) {
		super(reg);
		offset_ = offset;
    }

    @Override
    public Opcode op() {
        return Opcode.Align;
    }

    @Override
    public void print(DataOutputStream tw) throws IOException {
        tw.writeBytes("align." + RegisterName(reg()) + ", "
				+ (reg() == Register.Pri ? RegisterName(Register.Alt) : RegisterName(Register.Pri)) + offset());
    }
}