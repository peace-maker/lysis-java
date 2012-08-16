package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LIncGlobal extends LInstruction {

	private long address_;

    public LIncGlobal(long address)
    {
        address_ = address;
    }

    public long address()
    {
        return address_;
    }

	@Override
	public Opcode op() {
		return Opcode.IncGlobal;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("inc " + address());
	}

}
