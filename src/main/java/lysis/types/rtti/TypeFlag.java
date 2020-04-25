package lysis.types.rtti;

public class TypeFlag {
    public final static byte Bool = 0x01;
    public final static byte Int32 = 0x06;
    public final static byte Float32 = 0x0c;
    public final static byte Char8 = 0x0e;
    public final static byte Any = 0x10;
    public final static byte TopFunction = 0x11;

    public final static byte FixedArray = 0x30;
    public final static byte Array = 0x31;
    public final static byte Function = 0x32;

    public final static byte Enum = 0x42;
    public final static byte Typedef = 0x43;
    public final static byte Typeset = 0x44;
    public final static byte Classdef = 0x45;
    public final static byte EnumStruct = 0x46;

    public final static byte Void = 0x70;
    public final static byte Variadic = 0x71;
    public final static byte ByRef = 0x72;
    public final static byte Const = 0x73;
}
