import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/helpers/secret_stream/push/init_push_result.dart';
import '../../../../api/helpers/secret_stream/push/secret_stream_push_transformer.dart';
import '../../../../api/secret_stream.dart';
import '../../../../api/secure_key.dart';
import '../../../../api/sodium_exception.dart';
import '../../../bindings/libsodium.ffi.dart';
import '../../../bindings/memory_protection.dart';
import '../../../bindings/secure_key_native.dart';
import '../../../bindings/sodium_pointer.dart';
import 'secret_stream_message_tag_ffix.dart';

/// @nodoc
@internal
class SecretStreamPushTransformerSinkFFI
    extends SecretStreamPushTransformerSink<SodiumPointer<UnsignedChar>> {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  SecretStreamPushTransformerSinkFFI(this.sodium);

  @override
  @protected
  InitPushResult<SodiumPointer<UnsignedChar>> initialize(SecureKey key) {
    SodiumPointer<UnsignedChar>? statePtr;
    SodiumPointer<UnsignedChar>? headerPtr;
    try {
      statePtr = SodiumPointer<UnsignedChar>.alloc(
        sodium,
        zeroMemory: true,
        count: sodium.crypto_secretstream_xchacha20poly1305_statebytes(),
      );
      headerPtr = SodiumPointer<UnsignedChar>.alloc(
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
        header: Uint8List.fromList(headerPtr.asListView()),
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
  void rekey(SodiumPointer<UnsignedChar> cryptoState) =>
      sodium.crypto_secretstream_xchacha20poly1305_rekey(
        cryptoState.ptr.cast(),
      );

  @override
  @protected
  SecretStreamCipherMessage encryptMessage(
    SodiumPointer<UnsignedChar> cryptoState,
    SecretStreamPlainMessage event,
  ) {
    SodiumPointer<UnsignedChar>? messagePtr;
    SodiumPointer<UnsignedChar>? adPtr;
    SodiumPointer<UnsignedChar>? cipherPtr;
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
        Uint8List.fromList(cipherPtr.asListView()),
        additionalData: event.additionalData,
      );
    } finally {
      messagePtr?.dispose();
      adPtr?.dispose();
      cipherPtr?.dispose();
    }
  }

  @override
  @protected
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
  const SecretStreamPushTransformerFFI(this.sodium, SecureKey key) : super(key);

  @override
  SecretStreamPushTransformerSink<SodiumPointer<UnsignedChar>> createSink() =>
      SecretStreamPushTransformerSinkFFI(sodium);
}
