import 'dart:ffi';

final is32Bit = sizeOf<IntPtr>() == 4;
