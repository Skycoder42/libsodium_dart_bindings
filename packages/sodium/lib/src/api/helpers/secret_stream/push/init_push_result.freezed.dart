// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'init_push_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$InitPushResult<TState extends Object> {
  Uint8List get header => throw _privateConstructorUsedError;
  TState get state => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $InitPushResultCopyWith<TState, InitPushResult<TState>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InitPushResultCopyWith<TState extends Object, $Res> {
  factory $InitPushResultCopyWith(InitPushResult<TState> value,
          $Res Function(InitPushResult<TState>) then) =
      _$InitPushResultCopyWithImpl<TState, $Res, InitPushResult<TState>>;
  @useResult
  $Res call({Uint8List header, TState state});
}

/// @nodoc
class _$InitPushResultCopyWithImpl<TState extends Object, $Res,
        $Val extends InitPushResult<TState>>
    implements $InitPushResultCopyWith<TState, $Res> {
  _$InitPushResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? header = null,
    Object? state = null,
  }) {
    return _then(_value.copyWith(
      header: null == header
          ? _value.header
          : header // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as TState,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_InitPushResultCopyWith<TState extends Object, $Res>
    implements $InitPushResultCopyWith<TState, $Res> {
  factory _$$_InitPushResultCopyWith(_$_InitPushResult<TState> value,
          $Res Function(_$_InitPushResult<TState>) then) =
      __$$_InitPushResultCopyWithImpl<TState, $Res>;
  @override
  @useResult
  $Res call({Uint8List header, TState state});
}

/// @nodoc
class __$$_InitPushResultCopyWithImpl<TState extends Object, $Res>
    extends _$InitPushResultCopyWithImpl<TState, $Res,
        _$_InitPushResult<TState>>
    implements _$$_InitPushResultCopyWith<TState, $Res> {
  __$$_InitPushResultCopyWithImpl(_$_InitPushResult<TState> _value,
      $Res Function(_$_InitPushResult<TState>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? header = null,
    Object? state = null,
  }) {
    return _then(_$_InitPushResult<TState>(
      header: null == header
          ? _value.header
          : header // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as TState,
    ));
  }
}

/// @nodoc

class _$_InitPushResult<TState extends Object>
    implements _InitPushResult<TState> {
  const _$_InitPushResult({required this.header, required this.state});

  @override
  final Uint8List header;
  @override
  final TState state;

  @override
  String toString() {
    return 'InitPushResult<$TState>(header: $header, state: $state)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_InitPushResult<TState> &&
            const DeepCollectionEquality().equals(other.header, header) &&
            const DeepCollectionEquality().equals(other.state, state));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(header),
      const DeepCollectionEquality().hash(state));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_InitPushResultCopyWith<TState, _$_InitPushResult<TState>> get copyWith =>
      __$$_InitPushResultCopyWithImpl<TState, _$_InitPushResult<TState>>(
          this, _$identity);
}

abstract class _InitPushResult<TState extends Object>
    implements InitPushResult<TState> {
  const factory _InitPushResult(
      {required final Uint8List header,
      required final TState state}) = _$_InitPushResult<TState>;

  @override
  Uint8List get header;
  @override
  TState get state;
  @override
  @JsonKey(ignore: true)
  _$$_InitPushResultCopyWith<TState, _$_InitPushResult<TState>> get copyWith =>
      throw _privateConstructorUsedError;
}
