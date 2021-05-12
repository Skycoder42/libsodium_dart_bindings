// coverage:ignore-file
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'detached_cipher_result.freezed.dart';

/// The result of a detached cipher operation. It consists of the actual
/// [cipherText] as well as the [mac].
@freezed
class DetachedCipherResult with _$DetachedCipherResult {
  /// Default constructor.
  const factory DetachedCipherResult({
    /// The encrypted data.
    required Uint8List cipherText,

    /// The message authentication code of the data.
    required Uint8List mac,
  }) = _DetachedCipherResult;
}
