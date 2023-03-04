import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/crypto.dart';
import '../../api/key_pair.dart';
import '../../api/randombytes.dart';
import '../../api/secure_key.dart';
import '../../api/sodium.dart';
import '../../api/sodium_version.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart' hide KeyPair;
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
        jsErrorWrap(sodium.sodium_version_string),
      );

  @override
  Uint8List pad(Uint8List buf, int blocksize) => jsErrorWrap(
        () => sodium.pad(buf, blocksize),
      );

  @override
  Uint8List unpad(Uint8List buf, int blocksize) => jsErrorWrap(
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

  @override
  Future<T> runIsolated<T>(
    SodiumIsolateCallback<T> callback, {
    List<SecureKey> secureKeys = const [],
    List<KeyPair> keyPairs = const [],
  }) async {
    // ignore: prefer_asserts_with_message
    assert(() {
      // ignore: avoid_print
      print(
        'WARNING: Sodium.runIsolated does not actually run use parallel '
        'execution on the web. Code is run on the same thread.',
      );
      return true;
    }());

    return await callback(this, secureKeys, keyPairs);
  }
}
