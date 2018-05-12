package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LLoadIndex extends LInstruction {

	private long shift_;

    public LLoadIndex(long shift)
    {
        shift_ = shift;
    }

    public long shift()
    {
        return shift_;
    }
	
	@Override
	public Opcode op() {
		return Opcode.LoadIndex;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("lidx." + shift() + " ; [pri=alt+(pri<<" + shift() + ")]");
	}

}
