package lysis.nodes;

import lysis.nodes.types.DArrayRef;
import lysis.nodes.types.DBinary;
import lysis.nodes.types.DBoolean;
import lysis.nodes.types.DBoundsCheck;
import lysis.nodes.types.DCall;
import lysis.nodes.types.DCharacter;
import lysis.nodes.types.DConstant;
import lysis.nodes.types.DDeclareLocal;
import lysis.nodes.types.DDeclareStatic;
import lysis.nodes.types.DFloat;
import lysis.nodes.types.DFunction;
import lysis.nodes.types.DGlobal;
import lysis.nodes.types.DHeap;
import lysis.nodes.types.DIncDec;
import lysis.nodes.types.DInlineArray;
import lysis.nodes.types.DJump;
import lysis.nodes.types.DJumpCondition;
import lysis.nodes.types.DLoad;
import lysis.nodes.types.DLocalRef;
import lysis.nodes.types.DMemCopy;
import lysis.nodes.types.DPhi;
import lysis.nodes.types.DReturn;
import lysis.nodes.types.DStore;
import lysis.nodes.types.DString;
import lysis.nodes.types.DSwitch;
import lysis.nodes.types.DSysReq;
import lysis.nodes.types.DUnary;

public abstract class NodeVisitor {
	public void visit(DConstant node) throws Exception { }
    public void visit(DDeclareLocal local) { }
    public void visit(DDeclareStatic local) { }
    public void visit(DLocalRef lref) { }
    public void visit(DJump jump) { }
    public void visit(DJumpCondition jcc) { }
    public void visit(DSysReq sysreq) throws Exception { }
    public void visit(DBinary binary) { }
    public void visit(DBoundsCheck check) { }
    public void visit(DArrayRef aref) { }
    public void visit(DStore store) { }
    public void visit(DLoad load) throws Exception { }
    public void visit(DReturn ret) { }
    public void visit(DGlobal global) { }
    public void visit(DString node) { }
    public void visit(DCall call) throws Exception { }
    public void visit(DPhi phi) throws Exception { }
    public void visit(DBoolean phi) { }
    public void visit(DCharacter phi) { }
    public void visit(DFloat phi) { }
    public void visit(DFunction phi) { }
    public void visit(DUnary phi) { }
    public void visit(DIncDec phi) { }
    public void visit(DHeap phi) { }
    public void visit(DMemCopy phi) { }
    public void visit(DInlineArray ia) { }
    public void visit(DSwitch switch_) { }
}
