import 'dart:convert';
import 'dart:typed_data';

/// Extensions on [String]
extension StringX on String {
  /// Converts this string to an encoded byte array (a [Int8List]).
  ///
  /// Uses [encoding] for the encoding, which defaults to [utf8]. If
  /// [memoryWidth] is specified, the resulting
  /// byte array will have exactly [memoryWidth] bytes. If this string fits
  /// exactly into this array, that will be the result. If it is shorter, the
  /// remaining bytes will be filled with 0. If it is bigger, an [ArgumentError]
  /// gets thrown.
  ///
  /// By default, this whole string gets converted, even if it contains zeros in
  /// the middle of it. If [zeroTerminated] is set to true, this method stops
  /// encoding this string as soon as the first 0 is reached and the rest of the
  /// string gets dropped.
  ///
  /// You can optionally pass an [allocator], if you want to construct the
  /// [Int8List] in a special way (for example, backed by a raw pointer).
  Int8List toCharArray({
    int? memoryWidth,
    bool zeroTerminated = false,
    Int8List Function(int length)? allocator,
    Encoding encoding = utf8,
  }) {
    final List<int> chars;
    if (zeroTerminated) {
      chars = encoding.encode(this).takeWhile((value) => value != 0).toList();
    } else {
      chars = encoding.encode(this);
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

      return allocator?.call(memoryWidth) ?? Int8List(memoryWidth)
        ..setRange(0, chars.length, chars)
        ..fillRange(chars.length, memoryWidth, 0);
    } else if (allocator != null) {
      return allocator(chars.length)..setRange(0, chars.length, chars);
    } else {
      return Int8List.fromList(chars);
    }
  }
}

/// Extensions on [Int8List]
extension Int8ListX on Int8List {
  /// Converts this encoded byte array to a dart [String].
  ///
  /// Uses [encoding] for the decoding, which defaults to [utf8]. By default,
  /// the whole byte array is decoded
  /// and returned as string. If [zeroTerminated] is set to true, the decoder
  /// stops at the first 0 byte and only that part of the byte array is returned
  /// as a string.
  String toDartString({bool zeroTerminated = false, Encoding encoding = utf8}) {
    // decoding must happen on the unsigned view, as decoders reject the
    // negative byte values of an Int8List
    final bytes = unsignedView();
    if (zeroTerminated) {
      return encoding.decode(bytes.takeWhile((value) => value != 0).toList());
    } else {
      return encoding.decode(bytes);
    }
  }

  /// Casts this signed byte array to an unsigned [Uint8List].
  ///
  /// The returned list referres the the same underlying data.
  // ignore: use_to_and_as_if_applicable
  Uint8List unsignedView() => Uint8List.sublistView(this);
}

/// Extensions on [Uint8List]
extension Uint8ListX on Uint8List {
  /// Casts this unsigned byte array to a signed [Int8List].
  ///
  /// The returned list referres the the same underlying data.
  // ignore: use_to_and_as_if_applicable
  Int8List signedView() => Int8List.sublistView(this);
}
