package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;
import lysis.sourcepawn.SPOpcode;

public class LBinary extends LInstruction {

	private SPOpcode spop_;
	private Register lhs_;
	private Register rhs_;

	public LBinary(SPOpcode op, Register lhs, Register rhs) {
		spop_ = op;
		lhs_ = lhs;
		rhs_ = rhs;
	}

	public SPOpcode spop() {
		return spop_;
	}

	public Register lhs() {
		return lhs_;
	}

	public Register rhs() {
		return rhs_;
	}

	@Override
	public Opcode op() {
		return Opcode.Binary;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		switch (spop()) {
		case add:
			tw.writeBytes("add");
			break;
		case sub:
			tw.writeBytes("sub");
			break;
		case eq:
			tw.writeBytes("eq");
			break;
		case neq:
			tw.writeBytes("neq");
			break;
		case sleq:
			tw.writeBytes("sleq");
			break;
		case sgeq:
			tw.writeBytes("sgeq");
			break;
		case sgrtr:
			tw.writeBytes("sgrtr");
			break;
		case and:
			tw.writeBytes("and");
			break;
		case or:
			tw.writeBytes("or");
			break;
		case smul:
			tw.writeBytes("smul");
			break;
		case sdiv:
			tw.writeBytes("sdiv");
			break;
		case sdiv_alt:
			tw.writeBytes("sdiv.alt");
			break;
		case shr:
			tw.writeBytes("shr");
			break;
		case shl:
			tw.writeBytes("shl");
			break;
		case sub_alt:
			tw.writeBytes("sub.alt");
			break;
		case sless:
			tw.writeBytes("sless");
			break;
		case xor:
			tw.writeBytes("xor");
			break;
		case sshr:
			tw.writeBytes("sshr");
			break;

		default:
			throw new Exception("unexpected op");
		}
	}

}
