import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/kdf_hkdf.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.wrapper.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';
import 'helpers/kdf_hkdf/kdf_hkdf_extract_consumer_ffi.dart';
import 'helpers/keygen_mixin.dart';
import 'secure_key_ffi.dart';

@internal
abstract class KdfHkdfBaseFFI<T extends NativeType>
    with KdfHkdfValidations, KeygenMixin
    implements KdfHkdf {
  final LibSodiumFFI sodium;

  KdfHkdfBaseFFI(this.sodium);

  @protected
  int get stateBytes;

  @protected
  void Function(Pointer<UnsignedChar> prk) get internalKeygen;

  @protected
  int Function(
    Pointer<UnsignedChar> prk,
    Pointer<UnsignedChar> salt,
    int saltLen,
    Pointer<UnsignedChar> ikm,
    int ikmLen,
  )
  get internalExtract;

  @protected
  int Function(
    Pointer<UnsignedChar> out,
    int outLen,
    Pointer<Char> ctx,
    int ctxLen,
    Pointer<UnsignedChar> prk,
  )
  get internalExpand;

  @protected
  HkdfExtractInitFn<T> get internalExtractInit;

  @protected
  HkdfExtractUpdateFn<T> get internalExtractUpdate;

  @protected
  HkdfExtractFinalFn<T> get internalExtractFinal;

  @override
  SecureKey keygen() => keygenImpl(
    sodium: sodium,
    keyBytes: keyBytes,
    implementation: internalKeygen,
  );

  @override
  SecureKey extract({Uint8List? salt, required Uint8List ikm}) {
    SecureKeyFFI? prkKey;
    SodiumPointer<UnsignedChar>? saltPtr;
    SodiumPointer<UnsignedChar>? ikmPtr;
    try {
      prkKey = SecureKeyFFI.alloc(sodium, keyBytes);
      saltPtr = salt?.toSodiumPointer(sodium, memoryProtection: .readOnly);
      ikmPtr = ikm.toSodiumPointer(sodium, memoryProtection: .readOnly);

      final result = prkKey.runUnlockedNative(
        (prkPtr) => internalExtract(
          prkPtr.ptr,
          saltPtr?.ptr ?? nullptr,
          saltPtr?.count ?? 0,
          ikmPtr!.ptr,
          ikmPtr.count,
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return prkKey;
    } catch (e) {
      prkKey?.dispose();
      rethrow;
    } finally {
      saltPtr?.dispose();
      ikmPtr?.dispose();
    }
  }

  @override
  KdfHkdfExtractConsumer createExtractConsumer({Uint8List? salt}) =>
      KdfHkdfExtractConsumerFFI<T>(
        sodium: sodium,
        keyBytes: keyBytes,
        stateBytes: stateBytes,
        extractInit: internalExtractInit,
        extractUpdate: internalExtractUpdate,
        extractFinal: internalExtractFinal,
        salt: salt,
      );

  @override
  SecureKey expand({
    required SecureKey masterKey,
    required String context,
    required int outLen,
  }) {
    validateMasterKey(masterKey);
    validateOutLen(outLen);

    SecureKeyFFI? subKey;
    SodiumPointer<Char>? contextPtr;
    try {
      subKey = SecureKeyFFI.alloc(sodium, outLen);
      contextPtr = context.toSodiumPointer(sodium, memoryProtection: .readOnly);

      final result = subKey.runUnlockedNative(
        (subKeyPtr) => masterKey.runUnlockedNative(
          sodium,
          (masterKeyPtr) => internalExpand(
            subKeyPtr.ptr,
            subKeyPtr.count,
            contextPtr!.ptr,
            contextPtr.count,
            masterKeyPtr.ptr,
          ),
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return subKey;
    } catch (e) {
      subKey?.dispose();
      rethrow;
    } finally {
      contextPtr?.dispose();
    }
  }
}
