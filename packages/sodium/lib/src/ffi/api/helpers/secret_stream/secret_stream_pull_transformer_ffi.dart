import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/helpers/secret_stream/pull/secret_stream_pull_transformer.dart';
import '../../../../api/secret_stream.dart';
import '../../../../api/secure_key.dart';
import '../../../../api/sodium_exception.dart';
import '../../../bindings/libsodium.ffi.dart';
import '../../../bindings/memory_protection.dart';
import '../../../bindings/secure_key_native.dart';
import '../../../bindings/sodium_pointer.dart';
import 'secret_stream_message_tag_ffix.dart';

@internal
class SecretStreamPullTransformerSinkFFI
    extends SecretStreamPullTransformerSink<SodiumPointer<Uint8>> {
  final LibSodiumFFI sodium;

  SecretStreamPullTransformerSinkFFI(
    this.sodium,
    // ignore: avoid_positional_boolean_parameters
    bool requireFinalized,
  ) : super(requireFinalized);

  @override
  int get headerBytes =>
      sodium.crypto_secretstream_xchacha20poly1305_headerbytes();

  @override
  SodiumPointer<Uint8> initialize(SecureKey key, Uint8List header) {
    SodiumPointer<Uint8>? statePtr;
    SodiumPointer<Uint8>? headerPtr;
    try {
      statePtr = SodiumPointer.alloc(
        sodium,
        count: sodium.crypto_secretstream_xchacha20poly1305_statebytes(),
        zeroMemory: true,
      );
      headerPtr = header.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = key.runUnlockedNative(
        sodium,
        (keyPointer) => sodium.crypto_secretstream_xchacha20poly1305_init_pull(
          statePtr!.ptr.cast(),
          headerPtr!.ptr,
          keyPointer.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return statePtr;
    } catch (e) {
      statePtr?.dispose();
      rethrow;
    } finally {
      headerPtr?.dispose();
    }
  }

  @override
  void rekey(SodiumPointer<Uint8> cryptoState) =>
      sodium.crypto_secretstream_xchacha20poly1305_rekey(
        cryptoState.ptr.cast(),
      );

  @override
  SecretStreamPlainMessage decryptMessage(
    SodiumPointer<Uint8> cryptoState,
    SecretStreamCipherMessage event,
  ) {
    SodiumPointer<Uint8>? cipherPtr;
    SodiumPointer<Uint8>? adPtr;
    SodiumPointer<Uint8>? messagePtr;
    SodiumPointer<Uint64>? messageLenPtr;
    SodiumPointer<Uint8>? tagPtr;
    try {
      cipherPtr = event.message.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      adPtr = event.additionalData?.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      messagePtr = SodiumPointer.alloc(
        sodium,
        count: cipherPtr.count,
      );
      messageLenPtr = SodiumPointer.alloc(
        sodium,
        zeroMemory: true,
      );
      tagPtr = SodiumPointer.alloc(
        sodium,
        zeroMemory: true,
      );

      final result = sodium.crypto_secretstream_xchacha20poly1305_pull(
        cryptoState.ptr.cast(),
        messagePtr.ptr,
        messageLenPtr.ptr,
        tagPtr.ptr,
        cipherPtr.ptr,
        cipherPtr.count,
        adPtr?.ptr ?? nullptr.cast(),
        adPtr?.count ?? 0,
      );
      SodiumException.checkSucceededInt(result);

      return SecretStreamPlainMessage(
        messagePtr.copyAsList(messageLenPtr.ptr.value),
        additionalData: event.additionalData,
        tag: SecretStreamMessageTagFFIX.fromValue(sodium, tagPtr.ptr.value),
      );
    } finally {
      cipherPtr?.dispose();
      adPtr?.dispose();
      messagePtr?.dispose();
      messageLenPtr?.dispose();
      tagPtr?.dispose();
    }
  }

  @override
  void disposeState(SodiumPointer<Uint8> cryptoState) => cryptoState.dispose();
}

@internal
class SecretStreamPullTransformerFFI
    extends SecretStreamPullTransformer<SodiumPointer<Uint8>> {
  final LibSodiumFFI sodium;

  const SecretStreamPullTransformerFFI(
    this.sodium,
    SecureKey key,
    // ignore: avoid_positional_boolean_parameters
    bool requireFinalized,
  ) : super(key, requireFinalized);

  @override
  SecretStreamPullTransformerSink<SodiumPointer<Uint8>> createSink(
    bool requireFinalized,
  ) =>
      SecretStreamPullTransformerSinkFFI(sodium, requireFinalized);
}
