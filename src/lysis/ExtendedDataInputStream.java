package lysis;

import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;

public class ExtendedDataInputStream extends DataInputStream {

	public ExtendedDataInputStream(InputStream paramInputStream) {
		super(paramInputStream);
	}

	public long ReadUInt32() throws IOException {
		byte[] bytes = new byte[4];
		if(this.read(bytes) != 4)
			throw new IOException("Can't read 4 bytes.");
		return BitConverter.ToUInt32(bytes, 0);
	}
	
	public int ReadInt32() throws IOException {
		byte[] bytes = new byte[4];
		if(this.read(bytes) != 4)
			throw new IOException("Can't read 4 bytes.");
		return BitConverter.ToInt32(bytes, 0);
	}
	
	public int ReadUInt16() throws IOException {
		byte[] bytes = new byte[2];
		if(this.read(bytes) != 2)
			throw new IOException("Can't read 2 bytes.");
		return BitConverter.ToUInt16(bytes, 0);
	}
	
	public short ReadInt16() throws IOException {
		byte[] bytes = new byte[2];
		if(this.read(bytes) != 2)
			throw new IOException("Can't read 2 bytes.");
		return BitConverter.ToInt16(bytes, 0);
	}
}
