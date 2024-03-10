package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;

public class LAlign extends LInstructionReg {

    public LAlign(Register reg) {
        super(reg);
    }

    @Override
    public Opcode op() {
        return Opcode.Align;
    }

    @Override
    public void print(DataOutputStream tw) throws IOException {
        tw.writeBytes("align." + RegisterName(reg()) + ", "
				+ (reg() == Register.Pri ? RegisterName(Register.Alt) : RegisterName(Register.Pri)));
    }
}