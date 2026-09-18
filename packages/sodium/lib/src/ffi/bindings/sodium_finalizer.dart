// coverage:ignore-file

import 'dart:ffi';

import 'package:meta/meta.dart';

import 'libsodium.ffi.dart' show sodium_free;

@internal
// ignore: public_member_api_docs false positive
class SodiumFinalizer() {
  final _nativeFinalizer = NativeFinalizer(Native.addressOf(sodium_free));

  void attach(Finalizable value, Pointer<Void> token, int size) =>
      _nativeFinalizer.attach(value, token, detach: value, externalSize: size);

  void detach(Object detach) => _nativeFinalizer.detach(detach);
}
