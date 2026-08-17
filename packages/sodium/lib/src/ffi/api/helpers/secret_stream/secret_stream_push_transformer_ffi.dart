import 'dart:ffi';

import 'package:meta/meta.dart';

import '../../../../api/helpers/secret_stream/push/init_push_result.dart';
import '../../../../api/helpers/secret_stream/push/secret_stream_push_transformer.dart';
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
class SecretStreamPushTransformerSinkFFI
    extends SecretStreamPushTransformerSink<SodiumPointer<UnsignedChar>> {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  new(this.sodium);

  @override
  @protected
  @visibleForTesting
  InitPushResult<SodiumPointer<UnsignedChar>> initialize(SecureKey key) =>
      sodiumScope(sodium, (scope) {
        final statePtr = scope.alloc<UnsignedChar>(
          sodium.crypto_secretstream_xchacha20poly1305_statebytes(),
          zeroMemory: true,
        );
        final headerPtr = scope.alloc<UnsignedChar>(
          sodium.crypto_secretstream_xchacha20poly1305_headerbytes(),
        );

        final result = key.runUnlockedNative(
          sodium,
          (keyPointer) =>
              sodium.crypto_secretstream_xchacha20poly1305_init_push(
                statePtr.ptr.cast(),
                headerPtr.ptr,
                keyPointer.ptr,
              ),
        );
        SodiumException.checkSucceededInt(result);

        statePtr.memoryProtection = .noAccess;

        return InitPushResult(
          header: scope.takeBytes(headerPtr),
          state: scope.takePointer(statePtr),
        );
      });

  @override
  @protected
  @visibleForTesting
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
  @protected
  @visibleForTesting
  SecretStreamCipherMessage encryptMessage(
    SodiumPointer<UnsignedChar> cryptoState,
    SecretStreamPlainMessage event,
  ) {
    final additionalData = event.additionalData;
    return sodiumScope(sodium, (scope) {
      final messagePtr = scope.copyList<UnsignedChar>(event.message);
      final adPtr = additionalData != null
          ? scope.copyList<UnsignedChar>(additionalData)
          : null;
      final cipherPtr = scope.alloc<UnsignedChar>(
        messagePtr.count +
            sodium.crypto_secretstream_xchacha20poly1305_abytes(),
      );

      cryptoState.memoryProtection = .readWrite;
      try {
        final result = sodium.crypto_secretstream_xchacha20poly1305_push(
          cryptoState.ptr.cast(),
          cipherPtr.ptr,
          nullptr,
          messagePtr.ptr,
          messagePtr.count,
          adPtr?.ptr ?? nullptr.cast(),
          adPtr?.count ?? 0,
          event.tag.getValue(sodium),
        );
        SodiumException.checkSucceededInt(result);

        return SecretStreamCipherMessage(
          scope.takeBytes(cipherPtr),
          additionalData: additionalData,
        );
      } finally {
        cryptoState.memoryProtection = .noAccess;
      }
    });
  }

  @override
  @protected
  @visibleForTesting
  void disposeState(SodiumPointer<UnsignedChar> cryptoState) =>
      cryptoState.dispose();
}

/// @nodoc
@internal
class SecretStreamPushTransformerFFI
    extends SecretStreamPushTransformer<SodiumPointer<UnsignedChar>> {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  const new(this.sodium, SecureKey key) : super(key);

  @override
  SecretStreamPushTransformerSink<SodiumPointer<UnsignedChar>> createSink() =>
      SecretStreamPushTransformerSinkFFI(sodium);
}
