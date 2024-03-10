package lysis.nodes;

public enum NodeType {
	Sentinel, Constant, DeclareLocal, DeclareStatic, LocalRef, Jump, JumpCondition, SysReq, Binary, BoundsCheck, ArrayRef, Store, Load, Return, Global, String, Boolean, Float, Function, Character, Call, TempName, Phi, Unary, IncDec, Heap, MemCopy, InlineArray, Switch, GenArray, Label, Align
}
