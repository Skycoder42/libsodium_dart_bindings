import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/helpers/secret_stream/pull/secret_stream_pull_transformer.dart';
import '../../../../api/secret_stream.dart';
import '../../../../api/secure_key.dart';
import '../../../../api/sodium_exception.dart';
import '../../../bindings/libsodium.ffi.wrapper.dart';
import '../../../bindings/secure_key_native.dart';
import '../../../bindings/sodium_pointer.dart';
import '../../../bindings/sodium_scope.dart';
import 'secret_stream_message_tag_ffix.dart';

/// @nodoc
@internal
class SecretStreamPullTransformerSinkFFI
    extends SecretStreamPullTransformerSink<SodiumPointer<UnsignedChar>> {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  new(
    this.sodium,
    // ignore: avoid_positional_boolean_parameters for single param
    bool requireFinalized,
  ) : super(requireFinalized);

  @override
  int get headerBytes =>
      sodium.crypto_secretstream_xchacha20poly1305_headerbytes();

  @override
  SodiumPointer<UnsignedChar> initialize(SecureKey key, Uint8List header) =>
      sodiumScope(sodium, (scope) {
        final statePtr = scope.alloc<UnsignedChar>(
          sodium.crypto_secretstream_xchacha20poly1305_statebytes(),
          zeroMemory: true,
        );
        final headerPtr = scope.copyList<UnsignedChar>(header);

        final result = key.runUnlockedNative(
          sodium,
          (keyPointer) =>
              sodium.crypto_secretstream_xchacha20poly1305_init_pull(
                statePtr.ptr.cast(),
                headerPtr.ptr,
                keyPointer.ptr,
              ),
        );
        SodiumException.checkSucceededInt(result);

        statePtr.memoryProtection = .noAccess;

        return scope.takePointer(statePtr);
      });

  @override
  void rekey(SodiumPointer<UnsignedChar> cryptoState) {
    cryptoState.memoryProtection = .readWrite;
    try {
      sodium.crypto_secretstream_xchacha20poly1305_rekey(
        cryptoState.ptr.cast(),
      );
    } finally {
      cryptoState.memoryProtection = .noAccess;
    }
  }

  @override
  SecretStreamPlainMessage decryptMessage(
    SodiumPointer<UnsignedChar> cryptoState,
    SecretStreamCipherMessage event,
  ) {
    final additionalData = event.additionalData;
    return sodiumScope(sodium, (scope) {
      final cipherPtr = scope.copyList<UnsignedChar>(event.message);
      final adPtr = additionalData != null
          ? scope.copyList<UnsignedChar>(additionalData)
          : null;
      final messagePtr = scope.alloc<UnsignedChar>(
        cipherPtr.count - sodium.crypto_secretstream_xchacha20poly1305_abytes(),
      );
      final tagPtr = scope.alloc<UnsignedChar>(1, zeroMemory: true);

      cryptoState.memoryProtection = .readWrite;
      try {
        final result = sodium.crypto_secretstream_xchacha20poly1305_pull(
          cryptoState.ptr.cast(),
          messagePtr.ptr,
          nullptr,
          tagPtr.ptr,
          cipherPtr.ptr,
          cipherPtr.count,
          adPtr?.ptr ?? nullptr.cast(),
          adPtr?.count ?? 0,
        );
        SodiumException.checkSucceededInt(result);

        return SecretStreamPlainMessage(
          scope.takeBytes(messagePtr),
          additionalData: additionalData,
          tag: SecretStreamMessageTagFFIX.fromValue(sodium, tagPtr.ptr.value),
        );
      } finally {
        cryptoState.memoryProtection = .noAccess;
      }
    });
  }

  @override
  void disposeState(SodiumPointer<UnsignedChar> cryptoState) =>
      cryptoState.dispose();
}

/// @nodoc
@internal
class SecretStreamPullTransformerFFI
    extends SecretStreamPullTransformer<SodiumPointer<UnsignedChar>> {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  const new(
    this.sodium,
    SecureKey key,
    // ignore: avoid_positional_boolean_parameters for single param
    bool requireFinalized,
  ) : super(key, requireFinalized);

  @override
  SecretStreamPullTransformerSink<SodiumPointer<UnsignedChar>> createSink(
    bool requireFinalized,
  ) => SecretStreamPullTransformerSinkFFI(sodium, requireFinalized);
}
