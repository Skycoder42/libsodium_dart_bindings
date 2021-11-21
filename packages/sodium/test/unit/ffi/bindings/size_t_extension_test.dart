import 'dart:ffi';

import 'package:sodium/src/ffi/bindings/size_t_extension.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../test_data.dart';

void main() {
  final is32Bit = sizeOf<IntPtr>() == 4;

  test('constants return expected values', () {
    expect(SizeT.bitsPerByte, 8);
    expect(SizeT.sizeTBits, is32Bit ? 32 : 64);
  });

  final sizeTUintMax = BigInt.two.pow(SizeT.sizeTBits) - BigInt.one;
  final sizeTIntMin = -BigInt.two.pow(SizeT.sizeTBits - 1);
  final sizeTIntMax = BigInt.two.pow(SizeT.sizeTBits - 1) - BigInt.one;

  testData<Tuple2<BigInt, BigInt>>(
    'toSizeT/toIntPtr correctly convert integer values',
    [
      // zero
      Tuple2(BigInt.one, BigInt.one),
      Tuple2(BigInt.zero, BigInt.zero),
      Tuple2(-BigInt.one, sizeTUintMax),
      Tuple2(-BigInt.two, sizeTUintMax - BigInt.one),
      // int64.min
      Tuple2(sizeTIntMin + BigInt.one, (-sizeTIntMin) + BigInt.one),
      Tuple2(sizeTIntMin, -sizeTIntMin),
      // int64.max
      Tuple2(sizeTIntMax - BigInt.one, sizeTIntMax - BigInt.one),
      Tuple2(sizeTIntMax, sizeTIntMax),
    ],
    (fixture) {
      final asSigned = fixture.item1.toSigned(SizeT.sizeTBits).toInt();
      final asSizeT = asSigned.toSizeT();
      final asUnsigned = BigInt.from(asSizeT).toUnsigned(SizeT.sizeTBits);
      expect(asUnsigned, fixture.item2);
      final asIntPtr = asSizeT.toIntPtr();
      final asBigIntPtr = BigInt.from(asIntPtr).toSigned(SizeT.sizeTBits);
      expect(asBigIntPtr, fixture.item1);
    },
  );
}
