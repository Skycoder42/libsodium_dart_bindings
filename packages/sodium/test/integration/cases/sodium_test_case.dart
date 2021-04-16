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

    testData<Tuple2<int, int>>('pad adds expected padding', const [],
        (fixture) {
      const blockSize = 16;
      final inBuf = Uint8List(fixture.item1);

      final res = sodium.pad(inBuf, blockSize);

      expect(res, hasLength(fixture.item2));
    });
  }
}
