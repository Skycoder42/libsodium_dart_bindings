import 'dart:isolate';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

// ignore: unused_import
import '../../../../api/key_pair.dart';
// ignore: unused_import
import '../../../../api/secure_key.dart';
import '../../sodium_ffi.dart';
import 'transferrable_key_pair_ffi.dart';
import 'transferrable_secure_key_ffi.dart';

part 'isolate_result.freezed.dart';

/// @nodoc
@freezed
@internal
sealed class IsolateResult<T> with _$IsolateResult<T> {
  /// @nodoc
  const factory IsolateResult(T result) = _IsolateResult<T>;

  /// @nodoc
  @Assert(
    'T == SecureKey',
    'Cannot return subclasses of SecureKey from an isolate. '
        'Use SecureKey as return type instead.',
  )
  const factory IsolateResult.key(TransferrableSecureKeyFFI key) =
      _SecureKeyIsolateResult<T>;

  /// @nodoc
  @Assert(
    'T == KeyPair',
    'Cannot return subclasses of KeyPair from an isolate. '
        'Use KeyPair as return type instead.',
  )
  const factory IsolateResult.keyPair(TransferrableKeyPairFFI keyPair) =
      _KeyPairIsolateResult<T>;

  @Assert(
    'T == Uint8List',
    'Cannot return subclasses of Uint8List from an isolate. '
        'Use Uint8List as return type instead.',
  )
  const factory IsolateResult.bytes(TransferableTypedData data) =
      _BytesIsolateResult<T>;

  const IsolateResult._();

  /// @nodoc
  T extract(SodiumFFI sodium) => switch (this) {
    _IsolateResult(:final result) => result,
    _SecureKeyIsolateResult(:final key) => key.toSecureKey(sodium) as T,
    _KeyPairIsolateResult(:final keyPair) => keyPair.toKeyPair(sodium) as T,
    _BytesIsolateResult(:final data) => data.materialize().asUint8List() as T,
  };
}
