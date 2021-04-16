import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../test_data.dart';
import '../test_case.dart';

class SodiumTestCase extends TestCase {
  @override
  String get name => 'sodium';

  @override
  void setupTests() {
    test('reports correct version', () {
      final version = sodium.version;

      expect(version.major, 10);
      expect(version.minor, greaterThanOrEqualTo(3));
    });

    testData<Tuple2<int, int>>(
      'pad adds expected padding and unpad removes it',
      const [
        Tuple2(14, 16),
        Tuple2(15, 16),
        Tuple2(16, 32),
        Tuple2(17, 32),
        Tuple2(18, 32),
      ],
      (fixture) {
        const blockSize = 16;
        final baseBuf = Uint8List(fixture.item1);

        final paddedBuf = sodium.pad(baseBuf, blockSize);

        expect(paddedBuf, hasLength(fixture.item2));
        expect(paddedBuf.sublist(0, baseBuf.length), baseBuf);

        final unpaddedBuf = sodium.unpad(paddedBuf, blockSize);

        expect(unpaddedBuf, baseBuf);
      },
    );
  }
}
