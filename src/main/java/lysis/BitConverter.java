package lysis;

import java.nio.ByteBuffer;

public class BitConverter {
	public static short ToInt16(byte[] bytes, int offset) {
		short result = (short) ((int)bytes[offset]&0xff);
        result |= ((int)bytes[offset+1]&0xff) << 8;
        if(Lysis.bDebug)
        	System.out.println(result & 0xffff);
        return (short) (result & 0xffff);
    }
	
	public static int ToUInt16(byte[] bytes, int offset) {
		int result = (int)bytes[offset+1]&0xff;
        result |= ((int)bytes[offset]&0xff) << 8;
        if(Lysis.bDebug)
        	System.out.println(result & 0xffff);
        return result & 0xffff;
    }
	
	public static int ToInt32(byte[] bytes, int offset) {
		int result = (int)bytes[offset]&0xff;
        result |= ((int)bytes[offset+1]&0xff) << 8;
        result |= ((int)bytes[offset+2]&0xff) << 16;
        result |= ((int)bytes[offset+3]&0xff) << 24;
        if(Lysis.bDebug)
        	System.out.println(result);
        return result;
    }
	
	public static long ToUInt32(byte[] bytes, int offset) {
        long result = (int)bytes[offset]&0xff;
        result |= ((int)bytes[offset+1]&0xff) << 8;
        result |= ((int)bytes[offset+2]&0xff) << 16;
        result |= ((int)bytes[offset+3]&0xff) << 24;
        if(Lysis.bDebug)
        	System.out.println(result & 0xFFFFFFFFL);
        return result & 0xFFFFFFFFL;
    }
	
	public static long ToUInt64(byte[] bytes, int offset) {
        long result = 0;
        for (int i = 0; i <= 56; i += 8) {
			result |= ((int)bytes[offset++]&0xff) << i;
		}
        if(Lysis.bDebug)
        	System.out.println(result);
        return result;
    }

	public static byte[] GetBytes(int value) {
		byte[] bytes = new byte[4];
		bytes[0] = (byte) (value >> 24);
		bytes[1] = (byte) (value >> 16);
		bytes[2] = (byte) (value >> 8);
		bytes[3] = (byte) (value);
		//System.out.println(Arrays.toString(bytes));
		return bytes;
	}
	
	public static byte[] GetBytes(long value) {
		byte[] bytes = new byte[4];
		bytes[0] = (byte) (value >> 24);
		bytes[1] = (byte) (value >> 16);
		bytes[2] = (byte) (value >> 8);
		bytes[3] = (byte) (value);
		//System.out.println(Arrays.toString(bytes));
		return bytes;
	}
	
	public static float ToSingle(byte[] b, long offset) {
		ByteBuffer buf = ByteBuffer.wrap(b, (int) offset, 4);
		float outp = buf.getFloat();
		if(Lysis.bDebug)
        	System.out.println(outp);
		return outp;
	}
}
