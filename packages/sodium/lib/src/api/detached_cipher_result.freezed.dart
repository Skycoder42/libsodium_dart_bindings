// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'detached_cipher_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$DetachedCipherResult {
  /// The encrypted data.
  Uint8List get cipherText => throw _privateConstructorUsedError;

  /// The message authentication code of the data.
  Uint8List get mac => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DetachedCipherResultCopyWith<DetachedCipherResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetachedCipherResultCopyWith<$Res> {
  factory $DetachedCipherResultCopyWith(DetachedCipherResult value,
          $Res Function(DetachedCipherResult) then) =
      _$DetachedCipherResultCopyWithImpl<$Res, DetachedCipherResult>;
  @useResult
  $Res call({Uint8List cipherText, Uint8List mac});
}

/// @nodoc
class _$DetachedCipherResultCopyWithImpl<$Res,
        $Val extends DetachedCipherResult>
    implements $DetachedCipherResultCopyWith<$Res> {
  _$DetachedCipherResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cipherText = null,
    Object? mac = null,
  }) {
    return _then(_value.copyWith(
      cipherText: null == cipherText
          ? _value.cipherText
          : cipherText // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      mac: null == mac
          ? _value.mac
          : mac // ignore: cast_nullable_to_non_nullable
              as Uint8List,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DetachedCipherResultCopyWith<$Res>
    implements $DetachedCipherResultCopyWith<$Res> {
  factory _$$_DetachedCipherResultCopyWith(_$_DetachedCipherResult value,
          $Res Function(_$_DetachedCipherResult) then) =
      __$$_DetachedCipherResultCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Uint8List cipherText, Uint8List mac});
}

/// @nodoc
class __$$_DetachedCipherResultCopyWithImpl<$Res>
    extends _$DetachedCipherResultCopyWithImpl<$Res, _$_DetachedCipherResult>
    implements _$$_DetachedCipherResultCopyWith<$Res> {
  __$$_DetachedCipherResultCopyWithImpl(_$_DetachedCipherResult _value,
      $Res Function(_$_DetachedCipherResult) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cipherText = null,
    Object? mac = null,
  }) {
    return _then(_$_DetachedCipherResult(
      cipherText: null == cipherText
          ? _value.cipherText
          : cipherText // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      mac: null == mac
          ? _value.mac
          : mac // ignore: cast_nullable_to_non_nullable
              as Uint8List,
    ));
  }
}

/// @nodoc

class _$_DetachedCipherResult implements _DetachedCipherResult {
  const _$_DetachedCipherResult({required this.cipherText, required this.mac});

  /// The encrypted data.
  @override
  final Uint8List cipherText;

  /// The message authentication code of the data.
  @override
  final Uint8List mac;

  @override
  String toString() {
    return 'DetachedCipherResult(cipherText: $cipherText, mac: $mac)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DetachedCipherResult &&
            const DeepCollectionEquality()
                .equals(other.cipherText, cipherText) &&
            const DeepCollectionEquality().equals(other.mac, mac));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(cipherText),
      const DeepCollectionEquality().hash(mac));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DetachedCipherResultCopyWith<_$_DetachedCipherResult> get copyWith =>
      __$$_DetachedCipherResultCopyWithImpl<_$_DetachedCipherResult>(
          this, _$identity);
}

abstract class _DetachedCipherResult implements DetachedCipherResult {
  const factory _DetachedCipherResult(
      {required final Uint8List cipherText,
      required final Uint8List mac}) = _$_DetachedCipherResult;

  @override

  /// The encrypted data.
  Uint8List get cipherText;
  @override

  /// The message authentication code of the data.
  Uint8List get mac;
  @override
  @JsonKey(ignore: true)
  _$$_DetachedCipherResultCopyWith<_$_DetachedCipherResult> get copyWith =>
      throw _privateConstructorUsedError;
}
