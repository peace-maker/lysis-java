package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LStoreGlobalConstant extends LInstruction {

	private long address_;
    private long value_;

    public LStoreGlobalConstant(long address, long value)
    {
        address_ = address;
        value_ = value;
    }

    public long address()
    {
        return address_;
    }
    public long value()
    {
        return value_;
    }
	
	@Override
	public Opcode op() {
		return Opcode.StoreGlobalConstant;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("const [" + address() + "]" + " = value");
	}

}
