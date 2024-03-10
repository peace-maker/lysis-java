package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;

public class LAlign extends LInstructionRegStack {
    
    private long number_;

    public long number() {
        return number_;
    }
    public LAlign(long number, Register reg) {
        super(reg, number);
        number_ = number;
    }

    @Override
    public Opcode op() {
        return Opcode.Align;
    }

    @Override
    public void print(DataOutputStream tw) throws IOException {
        tw.writeBytes("align." + (reg() == Register.Pri ? RegisterName(Register.Pri) : RegisterName(Register.Alt)) + number());
    }
}