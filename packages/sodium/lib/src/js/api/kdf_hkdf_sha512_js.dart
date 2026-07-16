// ignore_for_file: unnecessary_lambdas dart2js forbids interop tear-offs

import 'dart:js_interop';

import 'package:meta/meta.dart';

import '../bindings/sodium.js.dart';
import 'helpers/kdf_hkdf/kdf_hkdf_extract_consumer_js.dart';
import 'kdf_hkdf_base_js.dart';

/// @nodoc
@internal
class KdfHkdfSha512JS extends KdfHkdfBaseJS<KdfHkdfSha512State> {
  KdfHkdfSha512JS(super.sodium);

  @override
  int get keyBytes => sodium.crypto_kdf_hkdf_sha512_KEYBYTES;

  @override
  int get bytesMin => sodium.crypto_kdf_hkdf_sha512_BYTES_MIN;

  @override
  int get bytesMax => sodium.crypto_kdf_hkdf_sha512_BYTES_MAX;

  @override
  JSUint8Array internalKeygen() => sodium.crypto_kdf_hkdf_sha512_keygen();

  @override
  JSUint8Array internalExtract(JSUint8Array? salt, JSUint8Array ikm) =>
      sodium.crypto_kdf_hkdf_sha512_extract(salt, ikm);

  @override
  JSUint8Array internalExpand(int outLen, String context, JSUint8Array prk) =>
      sodium.crypto_kdf_hkdf_sha512_expand(outLen, context, prk);

  @override
  HkdfExtractInitJsFn<KdfHkdfSha512State> get internalExtractInit =>
      (salt) => sodium.crypto_kdf_hkdf_sha512_extract_init(salt);

  @override
  HkdfExtractUpdateJsFn<KdfHkdfSha512State> get internalExtractUpdate =>
      (state, ikm) => sodium.crypto_kdf_hkdf_sha512_extract_update(state, ikm);

  @override
  HkdfExtractFinalJsFn<KdfHkdfSha512State> get internalExtractFinal =>
      (state) => sodium.crypto_kdf_hkdf_sha512_extract_final(state);
}
