import 'dart:ffi';

import 'package:meta/meta.dart';

import '../bindings/libsodium.ffi.dart' show crypto_kdf_hkdf_sha512_state;
import 'helpers/kdf_hkdf/kdf_hkdf_extract_consumer_ffi.dart';
import 'kdf_hkdf_base_ffi.dart';

@internal
class KdfHkdfSha512FFI extends KdfHkdfBaseFFI<crypto_kdf_hkdf_sha512_state> {
  KdfHkdfSha512FFI(super.sodium);

  @override
  int get keyBytes => sodium.crypto_kdf_hkdf_sha512_keybytes();

  @override
  int get bytesMin => sodium.crypto_kdf_hkdf_sha512_bytes_min();

  @override
  int get bytesMax => sodium.crypto_kdf_hkdf_sha512_bytes_max();

  @override
  int get stateBytes => sodium.crypto_kdf_hkdf_sha512_statebytes();

  @override
  void Function(Pointer<UnsignedChar> prk) get internalKeygen =>
      sodium.crypto_kdf_hkdf_sha512_keygen;

  @override
  int Function(
    Pointer<UnsignedChar> prk,
    Pointer<UnsignedChar> salt,
    int saltLen,
    Pointer<UnsignedChar> ikm,
    int ikmLen,
  )
  get internalExtract => sodium.crypto_kdf_hkdf_sha512_extract;

  @override
  int Function(
    Pointer<UnsignedChar> out,
    int outLen,
    Pointer<Char> ctx,
    int ctxLen,
    Pointer<UnsignedChar> prk,
  )
  get internalExpand => sodium.crypto_kdf_hkdf_sha512_expand;

  @override
  HkdfExtractInitFn<crypto_kdf_hkdf_sha512_state> get internalExtractInit =>
      sodium.crypto_kdf_hkdf_sha512_extract_init;

  @override
  HkdfExtractUpdateFn<crypto_kdf_hkdf_sha512_state> get internalExtractUpdate =>
      sodium.crypto_kdf_hkdf_sha512_extract_update;

  @override
  HkdfExtractFinalFn<crypto_kdf_hkdf_sha512_state> get internalExtractFinal =>
      sodium.crypto_kdf_hkdf_sha512_extract_final;
}
