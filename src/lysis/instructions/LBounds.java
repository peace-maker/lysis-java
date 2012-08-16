package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LBounds extends LInstruction {

	private long amount_;

    public LBounds(long amount)
    {
        amount_ = amount;
    }

    public long amount()
    {
        return amount_;
    }
    
	@Override
	public Opcode op() {
		return Opcode.Bounds;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("bounds.pri " + amount_);
	}

}
