// ignore_for_file: unnecessary_lambdas to catch member access errors

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/crypto.dart';
import '../../api/key_pair.dart';
import '../../api/randombytes.dart';
import '../../api/secure_key.dart';
import '../../api/sodium.dart';
import '../../api/sodium_exception.dart';
import '../../api/sodium_version.dart';
import '../../api/transferrable_secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart' hide KeyPair;
import 'crypto_js.dart';
import 'randombytes_js.dart';
import 'secure_key_js.dart';
import 'transferrable_secure_key_js.dart';

/// @nodoc
@internal
class SodiumJS implements Sodium {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  SodiumJS(this.sodium);

  @override
  SodiumVersion get version => SodiumVersion(
    sodium.SODIUM_LIBRARY_VERSION_MAJOR,
    sodium.SODIUM_LIBRARY_VERSION_MINOR,
    jsErrorWrap(() => sodium.sodium_version_string()),
  );

  @override
  Uint8List pad(Uint8List buf, int blocksize) =>
      jsErrorWrap(() => sodium.pad(buf.toJS, blocksize).toDart);

  @override
  Uint8List unpad(Uint8List buf, int blocksize) =>
      jsErrorWrap(() => sodium.unpad(buf.toJS, blocksize).toDart);

  @override
  SecureKey secureAlloc(int length) => SecureKeyJS.alloc(sodium, length);

  @override
  SecureKey secureRandom(int length) => SecureKeyJS.random(sodium, length);

  @override
  SecureKey secureCopy(Uint8List data) => SecureKeyJS(
    sodium,
    Uint8List.fromList(data).toJS, // force copy the data
  );

  @override
  late final Randombytes randombytes = RandombytesJS(sodium);

  @override
  late final Crypto crypto = CryptoJS(sodium);

  @override
  Future<T> runIsolated<T>(
    SodiumIsolateCallback<T> callback, {
    List<SecureKey> secureKeys = const [],
    List<KeyPair> keyPairs = const [],
  }) async => await runIsolatedWithInstance<T, SodiumJS>(
    this,
    callback,
    secureKeys,
    keyPairs,
  );

  @protected
  Future<TResult> runIsolatedWithInstance<TResult, TSodiumJS extends SodiumJS>(
    TSodiumJS sodium,
    SodiumIsolateCallback<TResult> callback,
    List<SecureKey> secureKeys,
    List<KeyPair> keyPairs,
  ) async {
    // ignore: prefer_asserts_with_message for debug mode validation
    assert(() {
      // ignore: avoid_print for debug mode validation
      print(
        'WARNING: Sodium.runIsolated does not actually use parallel '
        'execution on the web. Use service workers if needed!',
      );
      return true;
    }());

    return await callback(secureKeys, keyPairs);
  }

  @override
  TransferrableSecureKey createTransferrableSecureKey(SecureKey secureKey) =>
      TransferrableSecureKeyJS(secureKey);

  @override
  SecureKey materializeTransferrableSecureKey(
    TransferrableSecureKey transferrableSecureKey,
  ) {
    if (transferrableSecureKey case TransferrableSecureKeyJS()) {
      return transferrableSecureKey.secureKey;
    } else {
      throw SodiumException(
        'Cannot materialize instance of type: '
        '${transferrableSecureKey.runtimeType}',
      );
    }
  }

  @override
  TransferrableKeyPair createTransferrableKeyPair(KeyPair keyPair) =>
      TransferrableKeyPairJS(keyPair);

  @override
  KeyPair materializeTransferrableKeyPair(
    TransferrableKeyPair transferrableKeyPair,
  ) {
    if (transferrableKeyPair case TransferrableKeyPairJS()) {
      return transferrableKeyPair.keyPair;
    } else {
      throw SodiumException(
        'Cannot materialize instance of type: '
        '${transferrableKeyPair.runtimeType}',
      );
    }
  }
}
