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
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/sodium_pointer.dart';
import 'crypto_ffi.dart';
import 'helpers/isolates/isolate_result.dart';
import 'helpers/isolates/libsodiumffi_factory.dart';
import 'helpers/isolates/transferable_key_pair.dart';
import 'helpers/isolates/transferable_secure_key.dart';
import 'randombytes_ffi.dart';
import 'secure_key_ffi.dart';

/// @nodoc
@internal
class SodiumFFI implements Sodium {
  // coverage:ignore-start
  static LibSodiumFFI _unsupportedFactory() => throw UnsupportedError(
        'Sodium instance was not created with isolate support. '
        'Please use SodiumInit.initWithIsolates or '
        'SodiumInit.initFromSodiumFFIWithIsolates to initialize your instance.',
      );
  // coverage:ignore-end

  final LibSodiumFFIFactory _sodiumFactory;

  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  SodiumFFI(this.sodium, [this._sodiumFactory = _unsupportedFactory]);

  /// @nodoc
  static Future<SodiumFFI> fromFactory(LibSodiumFFIFactory factory) async =>
      SodiumFFI(
        await factory(),
        factory,
      );

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
      return Uint8List.fromList(
        extendedBuffer.viewAt(0, paddedLength.ptr.value).asListView(),
      );
    } finally {
      extendedBuffer?.dispose();
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
      return Uint8List.fromList(
        extendedBuffer.viewAt(0, unpaddedLength.ptr.value).asListView(),
      );
    } finally {
      extendedBuffer?.dispose();
      unpaddedLength?.dispose();
    }
  }

  @override
  SecureKey secureAlloc(int length) => SecureKeyFFI.alloc(sodium, length);

  @override
  SecureKey secureRandom(int length) => SecureKeyFFI.random(sodium, length);

  @override
  SecureKey secureCopy(Uint8List data) => SecureKeyFFI(
        data.toSodiumPointer(
          sodium,
          memoryProtection: MemoryProtection.noAccess,
        ),
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
  }) async {
    final isolateResult = await _isolateRun(
      _sodiumFactory,
      secureKeys.map(TransferableSecureKey.new).toList(),
      keyPairs.map(TransferableKeyPair.new).toList(),
      callback,
    );
    return isolateResult.extract(this);
  }

  static Future<IsolateResult<T>> _isolateRun<T>(
    LibSodiumFFIFactory sodiumFactory,
    List<TransferableSecureKey> transferableSecureKeys,
    List<TransferableKeyPair> transferableKeyPairs,
    SodiumIsolateCallback<T> callback,
  ) async {
    final isolateResult = await Isolate.run(
      debugName: 'SodiumFFI.runIsolated',
      () async {
        final sodium = await SodiumFFI.fromFactory(sodiumFactory);
        final restoredSecureKeys = transferableSecureKeys
            .map((transferKey) => transferKey.toSecureKey(sodium))
            .toList();
        final restoredKeyPairs = transferableKeyPairs
            .map((transferKeyPair) => transferKeyPair.toKeyPair(sodium))
            .toList();

        final result = await callback(
          sodium,
          restoredSecureKeys,
          restoredKeyPairs,
        );

        if (result is SecureKey) {
          return IsolateResult<T>.key(TransferableSecureKey(result));
        } else if (result is KeyPair) {
          return IsolateResult<T>.keyPair(TransferableKeyPair(result));
        } else {
          return IsolateResult<T>(result);
        }
      },
    );
    return isolateResult;
  }
}
