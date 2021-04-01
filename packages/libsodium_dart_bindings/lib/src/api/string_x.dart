import 'dart:convert';
import 'dart:typed_data';

extension StringX on String {
  Int8List toCharArray({int? memoryWidth}) {
    if (memoryWidth != null) {
      final encoded = utf8.encode(this);
      if (encoded.length > memoryWidth) {
        throw ArgumentError.value(
          memoryWidth,
          'memoryWidth',
          'must be at least as long as the encoded string (${encoded.length})',
        );
      }

      final memory = Int8List(memoryWidth);
      return memory
        ..setAll(0, encoded)
        ..fillRange(encoded.length, memory.length, 0);
    } else {
      return Int8List.fromList(utf8.encode(this));
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
}
