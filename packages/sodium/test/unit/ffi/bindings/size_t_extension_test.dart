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

  testData<Tuple2<int, int>>(
    'toSizeT correctly converts normal dart integers',
    is32Bit
        ? const [
            // uint32.min
            Tuple2(1, 1),
            Tuple2(0, 0),
            Tuple2(-1, 4294967295),
            Tuple2(-2, 4294967294),
            // uint32.max
            Tuple2(4294967294, 4294967294),
            Tuple2(4294967295, 4294967295),
            Tuple2(4294967296, 0),
            Tuple2(4294967297, 1),
            // int32.min
            Tuple2(-2147483647, 2147483649),
            Tuple2(-2147483648, 2147483648),
            Tuple2(-2147483649, 2147483647),
            // int32.max
            Tuple2(2147483646, 2147483646),
            Tuple2(2147483647, 2147483647),
            Tuple2(2147483648, 2147483648),
          ]
        : const [
            Tuple2(0, 0),
            Tuple2(1, 1),
            Tuple2(-1, -1),
            Tuple2(-2, -2),
            Tuple2(9223372036854775806, 9223372036854775806),
            Tuple2(9223372036854775807, 9223372036854775807),
            Tuple2(-9223372036854775807, -9223372036854775807),
            Tuple2(-9223372036854775808, -9223372036854775808),
          ],
    (fixture) {
      expect(fixture.item1.toSizeT(), fixture.item2);
    },
  );

  final sizeTUintMax = BigInt.two.pow(SizeT.sizeTBits) - BigInt.one;
  final sizeTIntMin = -BigInt.two.pow(SizeT.sizeTBits - 1);
  final sizeTIntMax = BigInt.two.pow(SizeT.sizeTBits - 1) - BigInt.one;

  testData<Tuple2<BigInt, BigInt>>(
    'toSizeT correctly converts big integer values',
    [
      // uint64.min
      Tuple2(BigInt.zero, BigInt.zero),
      Tuple2(BigInt.one, BigInt.one),
      Tuple2(-BigInt.one, sizeTUintMax),
      Tuple2(-BigInt.two, sizeTUintMax - BigInt.one),
      // uint64.max
      Tuple2(sizeTUintMax - BigInt.one, sizeTUintMax - BigInt.one),
      Tuple2(sizeTUintMax, sizeTUintMax),
      Tuple2(sizeTUintMax + BigInt.one, BigInt.zero),
      Tuple2(sizeTUintMax + BigInt.two, BigInt.one),
      // int64.min
      Tuple2(sizeTIntMin + BigInt.one, (-sizeTIntMin) + BigInt.one),
      Tuple2(sizeTIntMin, -sizeTIntMin),
      Tuple2(sizeTIntMin - BigInt.one, (-sizeTIntMin) - BigInt.one),
      // int64.max
      Tuple2(sizeTIntMax - BigInt.one, sizeTIntMax - BigInt.one),
      Tuple2(sizeTIntMax, sizeTIntMax),
      Tuple2(sizeTIntMax + BigInt.one, sizeTIntMax + BigInt.one),
    ],
    (fixture) {
      final asSigned = fixture.item1.toSigned(SizeT.sizeTBits).toInt();
      final asSizeT = asSigned.toSizeT();
      final asUnsigned = BigInt.from(asSizeT).toUnsigned(SizeT.sizeTBits);
      expect(asUnsigned, fixture.item2);
    },
  );
}
