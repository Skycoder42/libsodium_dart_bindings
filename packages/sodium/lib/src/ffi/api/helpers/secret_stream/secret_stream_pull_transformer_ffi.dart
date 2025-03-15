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

/// @nodoc
@internal
class SecretStreamPullTransformerSinkFFI
    extends SecretStreamPullTransformerSink<SodiumPointer<UnsignedChar>> {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  SecretStreamPullTransformerSinkFFI(
    this.sodium,
    // ignore: avoid_positional_boolean_parameters
    bool requireFinalized,
  ) : super(requireFinalized);

  @override
  int get headerBytes =>
      sodium.crypto_secretstream_xchacha20poly1305_headerbytes();

  @override
  SodiumPointer<UnsignedChar> initialize(SecureKey key, Uint8List header) {
    SodiumPointer<UnsignedChar>? statePtr;
    SodiumPointer<UnsignedChar>? headerPtr;
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
  void rekey(SodiumPointer<UnsignedChar> cryptoState) => sodium
      .crypto_secretstream_xchacha20poly1305_rekey(cryptoState.ptr.cast());

  @override
  SecretStreamPlainMessage decryptMessage(
    SodiumPointer<UnsignedChar> cryptoState,
    SecretStreamCipherMessage event,
  ) {
    SodiumPointer<UnsignedChar>? cipherPtr;
    SodiumPointer<UnsignedChar>? adPtr;
    SodiumPointer<UnsignedChar>? messagePtr;
    SodiumPointer<UnsignedChar>? tagPtr;
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
        count:
            cipherPtr.count -
            sodium.crypto_secretstream_xchacha20poly1305_abytes(),
      );
      tagPtr = SodiumPointer.alloc(sodium, zeroMemory: true);

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
        messagePtr.asListView(owned: true),
        additionalData: event.additionalData,
        tag: SecretStreamMessageTagFFIX.fromValue(sodium, tagPtr.ptr.value),
      );
    } catch (_) {
      messagePtr?.dispose();
      rethrow;
    } finally {
      cipherPtr?.dispose();
      adPtr?.dispose();
      tagPtr?.dispose();
    }
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
  const SecretStreamPullTransformerFFI(
    this.sodium,
    SecureKey key,
    // ignore: avoid_positional_boolean_parameters
    bool requireFinalized,
  ) : super(key, requireFinalized);

  @override
  SecretStreamPullTransformerSink<SodiumPointer<UnsignedChar>> createSink(
    bool requireFinalized,
  ) => SecretStreamPullTransformerSinkFFI(sodium, requireFinalized);
}
