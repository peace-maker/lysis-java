package lysis.instructions;

public abstract class LInstructionStack extends LInstruction {

	private long offs_;

	public LInstructionStack(long offset) {
		offs_ = offset;
	}

	public long offset() {
		return offs_;
	}

}
