import 'dart:typed_data';

import 'package:sodium/src/api/string_x.dart';
import 'package:test/test.dart';

void main() {
  group('toCharArray', () {
    test('converts string to utf8 pointer', () {
      const testStr = 'ABC';
      final res = testStr.toCharArray();
      expect(res, const [0x41, 0x42, 0x43]);
    });

    test('keeps free space if width was specified', () {
      const testStr = 'ABC';
      final res = testStr.toCharArray(memoryWidth: 5);
      expect(res, const [0x41, 0x42, 0x43, 0x00, 0x00]);
    });

    test('throws if memory width is too small', () {
      const testStr = 'ABC';
      expect(
        () => testStr.toCharArray(memoryWidth: 1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('continues encoding after 0 terminator', () {
      const testStr = 'AB\x00CD';
      final res = testStr.toCharArray();
      expect(res, const [0x41, 0x42, 0x00, 0x43, 0x44]);
    });

    test('stops after 0 terminator if enabled', () {
      const testStr = 'AB\x00CD';
      final res = testStr.toCharArray(zeroTerminated: true);
      expect(res, const [0x41, 0x42]);
    });

    test('stops after 0 terminator if enabled but still fills width', () {
      const testStr = 'AB\x00CD';
      final res = testStr.toCharArray(zeroTerminated: true, memoryWidth: 5);
      expect(res, const [0x41, 0x42, 0x00, 0x00, 0x00]);
    });
  });

  group('toDartString', () {
    test('converts bytes to string', () {
      final testBytes = Int8List.fromList(const [0x41, 0x42, 0x43]);
      final res = testBytes.toDartString();
      expect(res, 'ABC');
    });

    test('continues decoding after 0 terminator', () {
      final testBytes = Int8List.fromList(const [0x41, 0x42, 0x00, 0x43, 0x44]);
      final res = testBytes.toDartString();
      expect(res, 'AB\x00CD');
    });

    test('stops after 0 terminator if enabled', () {
      final testBytes = Int8List.fromList(const [0x41, 0x42, 0x00, 0x43, 0x44]);
      final res = testBytes.toDartString(zeroTerminated: true);
      expect(res, 'AB');
    });
  });

  group('unsignedView', () {
    test('returns a buffer view', () {
      const testData = [-1, 0, 1];

      final sut = Int8List.fromList(testData);
      final view = sut.unsignedView();

      expect(view, const [255, 0, 1]);

      sut[0] = 10;
      expect(view[0], 10);

      view[1] = 20;
      expect(sut[1], 20);
    });

    test('retains subviews on the original data', () {
      final testData = List.generate(100, (i) => i);

      final sut = Int8List.view(Int8List.fromList(testData).buffer, 25, 20);
      final view = sut.unsignedView();

      expect(view, testData.sublist(25, 45));
    });
  });

  group('signedView', () {
    test('returns a buffer view', () {
      const testData = [127, 128, 129];

      final sut = Uint8List.fromList(testData);
      final view = sut.signedView();

      expect(view, const [127, -128, -127]);

      sut[0] = 10;
      expect(view[0], 10);

      view[1] = 20;
      expect(sut[1], 20);
    });

    test('retains subviews on the original data', () {
      final testData = List.generate(100, (i) => i);

      final sut = Uint8List.view(Uint8List.fromList(testData).buffer, 25, 20);
      final view = sut.signedView();

      expect(view, testData.sublist(25, 45));
    });
  });
}
