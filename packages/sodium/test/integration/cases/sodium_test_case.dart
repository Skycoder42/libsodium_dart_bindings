import 'dart:typed_data';

import 'package:sodium/src/api/sodium.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../test_data.dart';
import '../test_case.dart';

class SodiumTestCase extends TestCase {
  @override
  String get name => 'sodium';

  Sodium get sut => sodium;

  @override
  void setupTests() {
    test('reports correct version', () {
      final version = sut.version;

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

        final paddedBuf = sut.pad(baseBuf, blockSize);

        expect(paddedBuf, hasLength(fixture.item2));
        expect(paddedBuf.sublist(0, baseBuf.length), baseBuf);

        final unpaddedBuf = sut.unpad(paddedBuf, blockSize);

        expect(unpaddedBuf, baseBuf);
      },
    );

    group('SecureKey', () {
      test('secureAlloc creates secure key of correct size', () {
        const length = 42;
        final secureKey = sut.secureAlloc(length);
        try {
          expect(secureKey, hasLength(length));
          expect(secureKey.extractBytes(), hasLength(length));
        } finally {
          secureKey.dispose();
        }
      });

      test('secureRandom creates secure key of correct size with random data',
          () {
        const length = 42;
        final secureKey1 = sut.secureRandom(length);
        final secureKey2 = sut.secureRandom(length);
        try {
          expect(secureKey1, hasLength(length));
          expect(secureKey2, hasLength(length));
          expect(secureKey1.extractBytes(), hasLength(length));
          expect(secureKey2.extractBytes(), hasLength(length));
          expect(secureKey1.extractBytes(), isNot(secureKey2.extractBytes()));
        } finally {
          secureKey1.dispose();
          secureKey2.dispose();
        }
      });

      test('runUnlockedSync allows data modification', () {
        final testData = List.generate(10, (index) => index);
        final secureKey = sut.secureAlloc(testData.length);
        try {
          // write data
          final resLen = secureKey.runUnlockedSync((data) {
            expect(data, hasLength(testData.length));
            data.setAll(0, testData);
            return data.length;
          }, writable: true);

          expect(resLen, testData.length);
          expect(secureKey.extractBytes(), testData);

          // read data
          secureKey.runUnlockedSync((data) {
            expect(data, testData);
          });
        } finally {
          secureKey.dispose();
        }
      });

      test('runUnlockedAsync allows data modification', () async {
        final testData = List.generate(10, (index) => index);
        final secureKey = sut.secureAlloc(testData.length);
        try {
          // write data
          final resLen = await secureKey.runUnlockedAsync((data) {
            expect(data, hasLength(testData.length));
            data.setAll(0, testData);
            return data.length;
          }, writable: true);

          expect(resLen, testData.length);
          expect(secureKey.extractBytes(), testData);

          // read data
          final resAsync = await secureKey.runUnlockedAsync((data) async {
            expect(data, testData);
            return Future.delayed(
              const Duration(milliseconds: 1),
              () => 42,
            );
          });
          expect(resAsync, 42);
        } finally {
          secureKey.dispose();
        }
      });
    });
  }
}
