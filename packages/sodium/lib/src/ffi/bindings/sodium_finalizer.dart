// coverage:ignore-file

import 'dart:ffi';

import 'package:meta/meta.dart';

import 'libsodium.ffi.dart';

/// @nodoc
@internal
class SodiumFinalizer {
  final NativeFinalizer _nativeFinalizer;

  /// @nodoc
  SodiumFinalizer(LibSodiumFFI sodium)
      : _nativeFinalizer = NativeFinalizer(sodium.sodium_freePtr);

  /// @nodoc
  void attach(Finalizable value, Pointer<Void> token) =>
      _nativeFinalizer.attach(value, token, detach: value);

  /// @nodoc
  void detach(Object detach) => _nativeFinalizer.detach(detach);
}
