// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'kx.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$SessionKeys {
  /// Session key to be used to decrypt received data
  SecureKey get rx => throw _privateConstructorUsedError;

  /// Session key to be used to encrypt data before transmitting it
  SecureKey get tx => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SessionKeysCopyWith<SessionKeys> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionKeysCopyWith<$Res> {
  factory $SessionKeysCopyWith(
          SessionKeys value, $Res Function(SessionKeys) then) =
      _$SessionKeysCopyWithImpl<$Res, SessionKeys>;
  @useResult
  $Res call({SecureKey rx, SecureKey tx});
}

/// @nodoc
class _$SessionKeysCopyWithImpl<$Res, $Val extends SessionKeys>
    implements $SessionKeysCopyWith<$Res> {
  _$SessionKeysCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rx = null,
    Object? tx = null,
  }) {
    return _then(_value.copyWith(
      rx: null == rx
          ? _value.rx
          : rx // ignore: cast_nullable_to_non_nullable
              as SecureKey,
      tx: null == tx
          ? _value.tx
          : tx // ignore: cast_nullable_to_non_nullable
              as SecureKey,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SessionKeysCopyWith<$Res>
    implements $SessionKeysCopyWith<$Res> {
  factory _$$_SessionKeysCopyWith(
          _$_SessionKeys value, $Res Function(_$_SessionKeys) then) =
      __$$_SessionKeysCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SecureKey rx, SecureKey tx});
}

/// @nodoc
class __$$_SessionKeysCopyWithImpl<$Res>
    extends _$SessionKeysCopyWithImpl<$Res, _$_SessionKeys>
    implements _$$_SessionKeysCopyWith<$Res> {
  __$$_SessionKeysCopyWithImpl(
      _$_SessionKeys _value, $Res Function(_$_SessionKeys) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rx = null,
    Object? tx = null,
  }) {
    return _then(_$_SessionKeys(
      rx: null == rx
          ? _value.rx
          : rx // ignore: cast_nullable_to_non_nullable
              as SecureKey,
      tx: null == tx
          ? _value.tx
          : tx // ignore: cast_nullable_to_non_nullable
              as SecureKey,
    ));
  }
}

/// @nodoc

class _$_SessionKeys extends _SessionKeys {
  const _$_SessionKeys({required this.rx, required this.tx}) : super._();

  /// Session key to be used to decrypt received data
  @override
  final SecureKey rx;

  /// Session key to be used to encrypt data before transmitting it
  @override
  final SecureKey tx;

  @override
  String toString() {
    return 'SessionKeys(rx: $rx, tx: $tx)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SessionKeys &&
            (identical(other.rx, rx) || other.rx == rx) &&
            (identical(other.tx, tx) || other.tx == tx));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rx, tx);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SessionKeysCopyWith<_$_SessionKeys> get copyWith =>
      __$$_SessionKeysCopyWithImpl<_$_SessionKeys>(this, _$identity);
}

abstract class _SessionKeys extends SessionKeys {
  const factory _SessionKeys(
      {required final SecureKey rx,
      required final SecureKey tx}) = _$_SessionKeys;
  const _SessionKeys._() : super._();

  @override

  /// Session key to be used to decrypt received data
  SecureKey get rx;
  @override

  /// Session key to be used to encrypt data before transmitting it
  SecureKey get tx;
  @override
  @JsonKey(ignore: true)
  _$$_SessionKeysCopyWith<_$_SessionKeys> get copyWith =>
      throw _privateConstructorUsedError;
}
