import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../api/crypto.dart';
import '../../api/key_pair.dart';
import '../../api/randombytes.dart';
import '../../api/secure_key.dart';
import '../../api/sodium.dart';
import '../../api/sodium_exception.dart';
import '../../api/sodium_version.dart';
import '../../api/transferrable_secure_key.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/sodium_pointer.dart';
import 'crypto_ffi.dart';
import 'helpers/isolates/isolate_result.dart';
import 'helpers/isolates/libsodiumffi_factory.dart';
import 'helpers/isolates/transferrable_key_pair_ffi.dart';
import 'helpers/isolates/transferrable_secure_key_ffi.dart';
import 'randombytes_ffi.dart';
import 'secure_key_ffi.dart';

/// @nodoc
@internal
typedef SodiumFFIIsolateCallback<TResult, TSodium extends SodiumFFI> =
    FutureOr<TResult> Function(
      TSodium sodium,
      List<SecureKey> secureKeys,
      List<KeyPair> keyPairs,
    );

/// @nodoc
@internal
typedef SodiumFFIFactory<TSodiumFFI extends SodiumFFI> =
    Future<TSodiumFFI> Function(LibSodiumFFIFactory factory);

/// @nodoc
@internal
class SodiumFFI implements Sodium {
  @protected
  final LibSodiumFFIFactory sodiumFactory;

  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  SodiumFFI(this.sodium, this.sodiumFactory);

  /// @nodoc
  static Future<SodiumFFI> fromFactory(LibSodiumFFIFactory factory) async =>
      SodiumFFI(await factory(), factory);

  @override
  SodiumVersion get version => SodiumVersion(
    sodium.sodium_library_version_major(),
    sodium.sodium_library_version_minor(),
    sodium.sodium_version_string().cast<Utf8>().toDartString(),
  );

  @override
  Uint8List pad(Uint8List buf, int blocksize) {
    final maxLen = buf.length + blocksize;
    SodiumPointer<UnsignedChar>? extendedBuffer;
    SodiumPointer<Size>? paddedLength;
    try {
      extendedBuffer = SodiumPointer.alloc(sodium, count: maxLen)..fill(buf);
      paddedLength = SodiumPointer.alloc(sodium, zeroMemory: true);
      final result = sodium.sodium_pad(
        paddedLength.ptr,
        extendedBuffer.ptr,
        buf.length,
        blocksize,
        maxLen,
      );
      SodiumException.checkSucceededInt(result);
      return Uint8List.sublistView(
        extendedBuffer.asListView<Uint8List>(owned: true),
        0,
        paddedLength.ptr.value,
      );
    } catch (_) {
      extendedBuffer?.dispose();
      rethrow;
    } finally {
      paddedLength?.dispose();
    }
  }

  @override
  Uint8List unpad(Uint8List buf, int blocksize) {
    SodiumPointer<UnsignedChar>? extendedBuffer;
    SodiumPointer<Size>? unpaddedLength;
    try {
      extendedBuffer = buf.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      unpaddedLength = SodiumPointer.alloc(sodium, zeroMemory: true);
      final result = sodium.sodium_unpad(
        unpaddedLength.ptr,
        extendedBuffer.ptr,
        extendedBuffer.count,
        blocksize,
      );
      SodiumException.checkSucceededInt(result);
      return Uint8List.sublistView(
        extendedBuffer.asListView<Uint8List>(owned: true),
        0,
        unpaddedLength.ptr.value,
      );
    } catch (_) {
      extendedBuffer?.dispose();
      rethrow;
    } finally {
      unpaddedLength?.dispose();
    }
  }

  @override
  SecureKey secureAlloc(int length) => SecureKeyFFI.alloc(sodium, length);

  @override
  SecureKey secureRandom(int length) => SecureKeyFFI.random(sodium, length);

  @override
  SecureKey secureCopy(Uint8List data) => SecureKeyFFI(
    data.toSodiumPointer(sodium, memoryProtection: MemoryProtection.noAccess),
  );

  @override
  late final Randombytes randombytes = RandombytesFFI(sodium);

  @override
  late final Crypto crypto = CryptoFFI(sodium);

  @override
  Future<T> runIsolated<T>(
    SodiumIsolateCallback<T> callback, {
    List<SecureKey> secureKeys = const [],
    List<KeyPair> keyPairs = const [],
  }) async => await runIsolatedWithFactory<T, SodiumFFI>(
    SodiumFFI.fromFactory,
    callback,
    secureKeys,
    keyPairs,
  );

  @override
  SodiumFactory get isolateFactory {
    final factory = sodiumFactory;
    return () async => await fromFactory(factory);
  }

  @override
  TransferrableSecureKey createTransferrableSecureKey(SecureKey secureKey) =>
      TransferrableSecureKeyFFI(secureKey);

  @override
  SecureKey materializeTransferrableSecureKey(
    TransferrableSecureKey transferrableSecureKey,
  ) {
    if (transferrableSecureKey case TransferrableSecureKeyFFI()) {
      return transferrableSecureKey.toSecureKey(this);
    } else {
      throw SodiumException(
        'Cannot materialize instance of type: '
        '${transferrableSecureKey.runtimeType}',
      );
    }
  }

  @override
  TransferrableKeyPair createTransferrableKeyPair(KeyPair keyPair) =>
      TransferrableKeyPairFFI(keyPair);

  @override
  KeyPair materializeTransferrableKeyPair(
    TransferrableKeyPair transferrableKeyPair,
  ) {
    if (transferrableKeyPair case TransferrableKeyPairFFI()) {
      return transferrableKeyPair.toKeyPair(this);
    } else {
      throw SodiumException(
        'Cannot materialize instance of type: '
        '${transferrableKeyPair.runtimeType}',
      );
    }
  }

  @protected
  Future<TResult> runIsolatedWithFactory<TResult, TSodiumFFI extends SodiumFFI>(
    SodiumFFIFactory<TSodiumFFI> fromFactory,
    SodiumFFIIsolateCallback<TResult, TSodiumFFI> callback,
    List<SecureKey> secureKeys,
    List<KeyPair> keyPairs,
  ) async {
    final isolateResult = await _isolateRun<TResult, TSodiumFFI>(
      sodiumFactory,
      fromFactory,
      secureKeys.map(TransferrableSecureKeyFFI.new).toList(),
      keyPairs.map(TransferrableKeyPairFFI.new).toList(),
      callback,
    );
    return isolateResult.extract(this);
  }

  static Future<IsolateResult<TResult>>
  _isolateRun<TResult, TSodiumFFI extends SodiumFFI>(
    LibSodiumFFIFactory sodiumFactory,
    SodiumFFIFactory<TSodiumFFI> fromFactory,
    List<TransferrableSecureKeyFFI> transferableSecureKeys,
    List<TransferrableKeyPairFFI> transferableKeyPairs,
    SodiumFFIIsolateCallback<TResult, TSodiumFFI> callback,
  ) async => await Isolate.run(debugName: 'SodiumFFI.runIsolated', () async {
    final sodium = await fromFactory(sodiumFactory);
    final restoredSecureKeys = transferableSecureKeys
        .map((transferKey) => transferKey.toSecureKey(sodium))
        .toList();
    final restoredKeyPairs = transferableKeyPairs
        .map((transferKeyPair) => transferKeyPair.toKeyPair(sodium))
        .toList();

    try {
      final result = await callback(
        sodium,
        restoredSecureKeys,
        restoredKeyPairs,
      );

      IsolateResult<TResult> isolateResult;
      switch (result) {
        case SecureKey():
          isolateResult = IsolateResult<TResult>.key(
            TransferrableSecureKeyFFI(result),
          );
          result.dispose();
        case KeyPair():
          isolateResult = IsolateResult<TResult>.keyPair(
            TransferrableKeyPairFFI(result),
          );
          result.dispose();
        case Uint8List():
          isolateResult = IsolateResult<TResult>.bytes(
            TransferableTypedData.fromList([result]),
          );
        default:
          isolateResult = IsolateResult<TResult>(result);
      }
      return isolateResult;
    } finally {
      for (final key in restoredSecureKeys) {
        key.dispose();
      }
      for (final keyPair in restoredKeyPairs) {
        keyPair.dispose();
      }
    }
  });
}
