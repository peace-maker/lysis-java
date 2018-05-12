package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LMulConstant extends LInstruction {

	private long amount_;

    public LMulConstant(long amount)
    {
        amount_ = amount;
    }

    public long amount()
    {
        return amount_;
    }
	
	@Override
	public Opcode op() {
		return Opcode.MulConstant;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("mul.pri " + amount());
	}

}
