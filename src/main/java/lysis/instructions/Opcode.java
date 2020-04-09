package lysis.instructions;

public enum Opcode {
	LoadLocal, StoreLocal, LoadLocalRef, StoreLocalRef, Load, Constant, StackAddress, Store, IndexAddress, Move, PushReg, PushConstant, Pop, Stack, Return, Jump, JumpCondition, AddConstant, MulConstant, ZeroGlobal, IncGlobal, DecGlobal, IncLocal, DecLocal, IncI, IncReg, DecI, DecReg, Fill, Bounds, SysReq, Swap, PushStackAddress, DebugBreak, Goto, PushLocal, Exchange, Binary, ShiftLeftConstant, PushGlobal, StoreGlobal, LoadGlobal, Call, EqualConstant, LoadIndex, Unary, StoreGlobalConstant, StoreLocalConstant, ZeroLocal, Heap, MemCopy, Switch, GenArray, StackAdjust, LoadCtrl, StoreCtrl
}
