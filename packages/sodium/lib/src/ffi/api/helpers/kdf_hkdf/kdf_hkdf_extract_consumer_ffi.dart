import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/kdf_hkdf.dart';
import '../../../../api/secure_key.dart';
import '../../../../api/sodium_exception.dart';
import '../../../bindings/libsodium.ffi.wrapper.dart';
import '../../../bindings/sodium_pointer.dart';
import '../../../bindings/sodium_scope.dart';

@internal
typedef HkdfExtractInitFn<T extends NativeType> =
    int Function(Pointer<T> state, Pointer<UnsignedChar> salt, int saltLen);

@internal
typedef HkdfExtractUpdateFn<T extends NativeType> =
    int Function(Pointer<T> state, Pointer<UnsignedChar> ikm, int ikmLen);

@internal
typedef HkdfExtractFinalFn<T extends NativeType> =
    int Function(Pointer<T> state, Pointer<UnsignedChar> prk);

@internal
class KdfHkdfExtractConsumerFFI<T extends NativeType>
    implements KdfHkdfExtractConsumer {
  final LibSodiumFFI sodium;
  final int keyBytes;
  final HkdfExtractUpdateFn<T> extractUpdate;
  final HkdfExtractFinalFn<T> extractFinal;

  final _masterKeyCompleter = Completer<SecureKey>();

  late final SodiumPointer<UnsignedChar> _state;

  @override
  Future<SecureKey> get masterKey => _masterKeyCompleter.future;

  KdfHkdfExtractConsumerFFI({
    required this.sodium,
    required this.keyBytes,
    required int stateBytes,
    required HkdfExtractInitFn<T> extractInit,
    required this.extractUpdate,
    required this.extractFinal,
    Uint8List? salt,
  }) {
    _state = SodiumPointer.alloc(sodium, count: stateBytes, zeroMemory: true);

    sodiumScope(sodium, (scope) {
      final saltPtr = salt != null ? scope.copyList<UnsignedChar>(salt) : null;

      try {
        final result = extractInit(
          _state.ptr.cast(),
          saltPtr?.ptr ?? nullptr,
          saltPtr?.count ?? 0,
        );
        SodiumException.checkSucceededInt(result);

        _state.memoryProtection = .noAccess;
      } catch (e) {
        _state.dispose();
        rethrow;
      }
    });
  }

  @override
  void add(Uint8List data) {
    _ensureNotCompleted();

    sodiumScope(sodium, (scope) {
      final ikmPtr = scope.copyList<UnsignedChar>(data);

      _state.memoryProtection = .readWrite;
      try {
        final result = extractUpdate(
          _state.ptr.cast(),
          ikmPtr.ptr,
          ikmPtr.count,
        );
        SodiumException.checkSucceededInt(result);
      } finally {
        _state.memoryProtection = .noAccess;
      }
    });
  }

  @override
  Future<void> addStream(Stream<Uint8List> stream) {
    _ensureNotCompleted();
    return stream.map(add).drain<void>();
  }

  @override
  Future<SecureKey> close() {
    _ensureNotCompleted();

    try {
      sodiumScope(sodium, (scope) {
        final prkKey = scope.allocSecureKey(keyBytes);

        _state.memoryProtection = .readWrite;
        final result = prkKey.runUnlockedNative(
          (prkPtr) => extractFinal(_state.ptr.cast(), prkPtr.ptr),
          writable: true,
        );
        SodiumException.checkSucceededInt(result);

        _masterKeyCompleter.complete(scope.takeSecureKey(prkKey));
      });
    } catch (e, s) {
      _masterKeyCompleter.completeError(e, s);
    } finally {
      _state.dispose();
    }

    return _masterKeyCompleter.future;
  }

  void _ensureNotCompleted() {
    if (_masterKeyCompleter.isCompleted) {
      throw StateError('Master key has already been extracted');
    }
  }
}
