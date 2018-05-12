package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Native;

public class LSysReq extends LInstruction {

	private Native native_;

    public LSysReq(Native nativeX)
    {
        native_ = nativeX;
    }
	
	public Native nativeX()
    {
        return native_;
    }
	
	@Override
	public Opcode op() {
		return Opcode.SysReq;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("sysreq " + nativeX().name());
	}

}
