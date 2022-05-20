import 'dart:ffi';

// TODO remove
extension SizeT on int {
  static const bitsPerByte = 8;
  static final sizeTBits = sizeOf<IntPtr>() * bitsPerByte;

  int toSizeT() => toUnsigned(sizeTBits);

  int toIntPtr() => toSigned(sizeTBits);
}
