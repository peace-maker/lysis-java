package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LFill extends LInstruction {

	private long amount_;

    public LFill(long amount)
    {
        amount_ = amount;
    }

    public long amount()
    {
        return amount_;
    }
	
	@Override
	public Opcode op() {
		return Opcode.Fill;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("fill alt, " + amount_);
	}

}
