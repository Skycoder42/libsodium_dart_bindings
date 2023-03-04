import 'dart:ffi';
import 'dart:typed_data';

import 'package:sodium/sodium.dart';
import 'package:sodium/sodium_sumo.dart';
import '../sodium_platform.dart';

class _SodiumMacos implements Sodium {
  final Sodium _sodium;

  _SodiumMacos(this._sodium);

  @override
  Crypto get crypto => _sodium.crypto;

  @override
  Uint8List pad(Uint8List buf, int blocksize) => _sodium.pad(buf, blocksize);

  @override
  Randombytes get randombytes => _sodium.randombytes;

  @override
  SecureKey secureAlloc(int length) => _sodium.secureAlloc(length);

  @override
  SecureKey secureCopy(Uint8List data) => _sodium.secureCopy(data);

  @override
  SecureKey secureRandom(int length) => _sodium.secureRandom(length);

  @override
  Uint8List unpad(Uint8List buf, int blocksize) =>
      _sodium.unpad(buf, blocksize);

  @override
  SodiumVersion get version => const SodiumVersion(10, 3, '1.0.18');

  @override
  Future<T> runIsolated<T>(
    SodiumIsolateCallback<T> callback, {
    List<SecureKey> secureKeys = const [],
    List<KeyPair> keyPairs = const [],
  }) =>
      _sodium.runIsolated(
        callback,
        secureKeys: secureKeys,
        keyPairs: keyPairs,
      );
}

class _SodiumSumoMacos extends _SodiumMacos implements SodiumSumo {
  SodiumSumo get _sodiumSumo => super._sodium as SodiumSumo;

  _SodiumSumoMacos(SodiumSumo super.sodium);

  @override
  CryptoSumo get crypto => _sodiumSumo.crypto;
}

/// macOS platform implementation of SodiumPlatform
class SodiumMacos extends SodiumPlatform {
  /// Registers the [SodiumMacos] as [SodiumPlatform.instance]
  static void registerWith() {
    SodiumPlatform.instance = SodiumMacos();
  }

  @override
  Future<Sodium> loadSodium() =>
      SodiumInit.init2(DynamicLibrary.process).then(_SodiumMacos.new);

  @override
  Future<SodiumSumo> loadSodiumSumo() =>
      SodiumSumoInit.init2(DynamicLibrary.process).then(_SodiumSumoMacos.new);
}
