import 'dart:convert';
import 'dart:typed_data';

extension StringX on String {
  Int8List toCharArray({int? memoryWidth, bool zeroTerminated = false}) {
    final List<int> chars;
    if (zeroTerminated) {
      chars = utf8.encode(this).takeWhile((value) => value != 0).toList();
    } else {
      chars = utf8.encode(this);
    }

    if (memoryWidth != null) {
      if (chars.length > memoryWidth) {
        throw ArgumentError.value(
          memoryWidth,
          'memoryWidth',
          'must be at least as long as the encoded string '
              '(${chars.length} bytes)',
        );
      }

      return Int8List(memoryWidth)
        ..setAll(0, chars)
        ..fillRange(chars.length, memoryWidth, 0);
    } else {
      return Int8List.fromList(chars.toList());
    }
  }
}

extension Int8ListX on Int8List {
  String toDartString({bool zeroTerminated = false}) {
    if (zeroTerminated) {
      return utf8.decode(takeWhile((value) => value != 0).toList());
    } else {
      return utf8.decode(this);
    }
  }

  Uint8List unsignedView() => Uint8List.view(buffer);
}

extension Uint8ListX on Uint8List {
  Int8List signedView() => Int8List.view(buffer);
}
