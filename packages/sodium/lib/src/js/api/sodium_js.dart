import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/crypto.dart';
import '../../api/randombytes.dart';
import '../../api/secure_key.dart';
import '../../api/sodium.dart';
import '../../api/sodium_version.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';
import '../bindings/to_safe_int.dart';
import 'crypto_js.dart';
import 'randombytes_js.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class SodiumJS implements Sodium {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  SodiumJS(this.sodium);

  @override
  SodiumVersion get version => SodiumVersion(
        sodium.SODIUM_LIBRARY_VERSION_MAJOR.toSafeUInt32(),
        sodium.SODIUM_LIBRARY_VERSION_MINOR.toSafeUInt32(),
        JsError.wrap(() => sodium.sodium_version_string()),
      );

  @override
  Uint8List pad(Uint8List buf, int blocksize) => JsError.wrap(
        () => sodium.pad(buf, blocksize),
      );

  @override
  Uint8List unpad(Uint8List buf, int blocksize) => JsError.wrap(
        () => sodium.unpad(buf, blocksize),
      );

  @override
  SecureKey secureAlloc(int length) => SecureKeyJS.alloc(sodium, length);

  @override
  SecureKey secureRandom(int length) => SecureKeyJS.random(sodium, length);

  @override
  SecureKey secureCopy(Uint8List data) => SecureKeyJS(
        sodium,
        Uint8List.fromList(data), // force copy the data
      );

  @override
  SecureKey secureHandle(covariant SecureKeyJSNativeHandle nativeHandle) =>
      SecureKeyJS(sodium, nativeHandle);

  @override
  late final Randombytes randombytes = RandombytesJS(sodium);

  @override
  late final Crypto crypto = CryptoJS(sodium);
}
