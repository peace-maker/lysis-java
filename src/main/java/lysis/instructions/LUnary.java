package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;
import lysis.sourcepawn.SPOpcode;

public class LUnary extends LInstruction {

	private SPOpcode spop_;
	private Register reg_;

	public LUnary(SPOpcode op, Register reg) {
		spop_ = op;
		reg_ = reg;
	}

	public SPOpcode spop() {
		return spop_;
	}

	public Register reg() {
		return reg_;
	}

	@Override
	public Opcode op() {
		return Opcode.Unary;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		switch (spop()) {
		case not:
			tw.writeBytes("not");
			break;
		case invert:
			tw.writeBytes("invert");
			break;
		case neg:
			tw.writeBytes("neg");
			break;

		default:
			throw new Exception("unexpected op");
		}
	}

}
