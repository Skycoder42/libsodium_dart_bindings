import 'package:freezed_annotation/freezed_annotation.dart';

// ignore: unused_import
import '../../../../api/key_pair.dart';
// ignore: unused_import
import '../../../../api/secure_key.dart';
import '../../sodium_ffi.dart';
import 'transferable_key_pair.dart';
import 'transferable_secure_key.dart';

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
  const factory IsolateResult.key(TransferableSecureKey key) =
      _SecureKeyIsolateResult<T>;

  /// @nodoc
  @Assert(
    'T == KeyPair',
    'Cannot return subclasses of KeyPair from an isolate. '
        'Use KeyPair as return type instead.',
  )
  const factory IsolateResult.keyPair(TransferableKeyPair keyPair) =
      _KeyPairIsolateResult<T>;

  const IsolateResult._();

  /// @nodoc
  T extract(SodiumFFI sodium) => when(
        (result) => result,
        key: (key) => key.toSecureKey(sodium) as T,
        keyPair: (keyPair) => keyPair.toKeyPair(sodium) as T,
      );
}
