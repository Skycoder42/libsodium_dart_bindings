import 'dart:typed_data';

import '../test_case.dart';

class RandombytesTestCase extends TestCase {
  RandombytesTestCase(super._runner);

  @override
  String get name => 'randombytes';

  @override
  void setupTests() {
    test('constants return correct value', (sodium) {
      final sut = sodium.randombytes;

      expect(sut.seedBytes, 32, reason: 'seedBytes');
    });

    test('random returns random numbers', (sodium) {
      final sut = sodium.randombytes;

      final r1 = sut.random();
      final r2 = sut.random();

      expect(r1, isNot(r2));
    });

    test('uniform returns upper bound number', (sodium) {
      final sut = sodium.randombytes;

      const upperBound = 5;
      final rb = sut.uniform(upperBound);
      expect(rb, lessThan(upperBound));
    });

    test('buf creates buffer with random data', (sodium) {
      final sut = sodium.randombytes;

      const length = 32;
      final buf1 = sut.buf(length);
      final buf2 = sut.buf(length);
      printOnFailure('buf1: $buf1');
      printOnFailure('buf2: $buf2');

      expect(buf1, hasLength(length));
      expect(buf2, hasLength(length));
      expect(buf1, isNot(buf2));
    });

    group('bufDeterministic', () {
      test('different seeds create different data', (sodium) {
        final sut = sodium.randombytes;

        final seed1 = Uint8List.fromList(
          List.generate(sut.seedBytes, (index) => index),
        );
        final seed2 = Uint8List.fromList(
          List.generate(sut.seedBytes, (index) => index + 1),
        );
        const length = 32;
        final buf1 = sut.bufDeterministic(length, seed1);
        final buf2 = sut.bufDeterministic(length, seed2);
        printOnFailure('buf1: $buf1');
        printOnFailure('buf2: $buf2');

        expect(buf1, hasLength(length));
        expect(buf2, hasLength(length));
        expect(buf1, isNot(buf2));
      });

      test('same seeds create same data', (sodium) {
        final sut = sodium.randombytes;

        final seed = Uint8List.fromList(
          List.generate(sut.seedBytes, (index) => index),
        );
        const length = 32;
        final buf1 = sut.bufDeterministic(length, seed);
        final buf2 = sut.bufDeterministic(length, seed);
        printOnFailure('buf1: $buf1');
        printOnFailure('buf2: $buf2');

        expect(buf1, hasLength(length));
        expect(buf2, hasLength(length));
        expect(buf1, buf2);
      });
    });

    test('close and stir close and reinit random', (sodium) {
      final sut =
          sodium.randombytes
            ..close()
            ..stir();
      expect(sut.random(), anything);
    });
  }
}
