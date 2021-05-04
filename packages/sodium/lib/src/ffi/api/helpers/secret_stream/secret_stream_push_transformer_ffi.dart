import 'dart:ffi';

import 'package:meta/meta.dart';

import '../../../../api/helpers/secret_stream/push/init_push_result.dart';
import '../../../../api/helpers/secret_stream/push/secret_stream_push_transformer.dart';
import '../../../../api/secret_stream.dart';
import '../../../../api/secure_key.dart';
import '../../../../api/sodium_exception.dart';
import '../../../bindings/libsodium.ffi.dart';
import '../../../bindings/secure_key_native.dart';
import '../../../bindings/sodium_pointer.dart';
import 'secret_stream_message_tag_ffix.dart';

@internal
class SecretStreamPushTransformerSinkFFI
    extends SecretStreamPushTransformerSink<SodiumPointer<Uint8>> {
  final LibSodiumFFI sodium;

  SecretStreamPushTransformerSinkFFI(this.sodium);

  @override
  @protected
  InitPushResult<SodiumPointer<Uint8>> initialize(SecureKey key) {
    SodiumPointer<Uint8>? statePtr;
    SodiumPointer<Uint8>? headerPtr;
    try {
      statePtr = SodiumPointer<Uint8>.alloc(
        sodium,
        zeroMemory: true,
        count: sodium.crypto_secretstream_xchacha20poly1305_statebytes(),
      );
      headerPtr = SodiumPointer<Uint8>.alloc(
        sodium,
        count: sodium.crypto_secretstream_xchacha20poly1305_headerbytes(),
      );
      final result = key.runUnlockedNative(
        sodium,
        (keyPointer) => sodium.crypto_secretstream_xchacha20poly1305_init_push(
          statePtr!.ptr.cast(),
          headerPtr!.ptr,
          keyPointer.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return InitPushResult(
        header: headerPtr.copyAsList(),
        state: statePtr,
      );
    } catch (e) {
      statePtr?.dispose();
      rethrow;
    } finally {
      headerPtr?.dispose();
    }
  }

  @override
  @protected
  void rekey(SodiumPointer<Uint8> cryptoState) =>
      sodium.crypto_secretstream_xchacha20poly1305_rekey(
        cryptoState.ptr.cast(),
      );

  @override
  @protected
  SecretStreamCipherMessage encryptMessage(
    SodiumPointer<Uint8> cryptoState,
    SecretStreamPlainMessage event,
  ) {
    SodiumPointer<Uint8>? messagePtr;
    SodiumPointer<Uint8>? adPtr;
    SodiumPointer<Uint8>? cipherPtr;
    SodiumPointer<Uint64>? cipherLenPtr;
    try {
      messagePtr = event.message.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      adPtr = event.additionalData?.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      cipherPtr = SodiumPointer.alloc(
        sodium,
        count: messagePtr.count +
            sodium.crypto_secretstream_xchacha20poly1305_abytes(),
      );
      cipherLenPtr = SodiumPointer.alloc(
        sodium,
        zeroMemory: true,
      );

      final result = sodium.crypto_secretstream_xchacha20poly1305_push(
        cryptoState.ptr.cast(),
        cipherPtr.ptr,
        cipherLenPtr.ptr,
        messagePtr.ptr,
        messagePtr.count,
        adPtr?.ptr ?? nullptr.cast(),
        adPtr?.count ?? 0,
        event.tag.getValue(sodium),
      );
      SodiumException.checkSucceededInt(result);

      return SecretStreamCipherMessage(
        cipherPtr.copyAsList(cipherLenPtr.ptr.value),
        additionalData: event.additionalData,
      );
    } finally {
      messagePtr?.dispose();
      adPtr?.dispose();
      cipherPtr?.dispose();
      cipherLenPtr?.dispose();
    }
  }

  @override
  @protected
  void disposeState(SodiumPointer<Uint8> cryptoState) => cryptoState.dispose();
}

@internal
class SecretStreamPushTransformerFFI
    extends SecretStreamPushTransformer<SodiumPointer<Uint8>> {
  final LibSodiumFFI sodium;

  const SecretStreamPushTransformerFFI(this.sodium, SecureKey key) : super(key);

  @override
  SecretStreamPushTransformerSink<SodiumPointer<Uint8>> createSink() =>
      SecretStreamPushTransformerSinkFFI(sodium);
}
