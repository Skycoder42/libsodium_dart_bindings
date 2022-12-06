// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'secret_stream.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$SecretStreamPlainMessage {
  /// The message that should be encrypted.
  Uint8List get message => throw _privateConstructorUsedError;

  /// Additional data, that should be used to generate authentication data.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#encryption
  Uint8List? get additionalData => throw _privateConstructorUsedError;

  /// The message tag that should be attached to the encrypted message.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#encryption
  /// and https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#constants
  SecretStreamMessageTag get tag => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SecretStreamPlainMessageCopyWith<SecretStreamPlainMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecretStreamPlainMessageCopyWith<$Res> {
  factory $SecretStreamPlainMessageCopyWith(SecretStreamPlainMessage value,
          $Res Function(SecretStreamPlainMessage) then) =
      _$SecretStreamPlainMessageCopyWithImpl<$Res, SecretStreamPlainMessage>;
  @useResult
  $Res call(
      {Uint8List message,
      Uint8List? additionalData,
      SecretStreamMessageTag tag});
}

/// @nodoc
class _$SecretStreamPlainMessageCopyWithImpl<$Res,
        $Val extends SecretStreamPlainMessage>
    implements $SecretStreamPlainMessageCopyWith<$Res> {
  _$SecretStreamPlainMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? additionalData = freezed,
    Object? tag = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      additionalData: freezed == additionalData
          ? _value.additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Uint8List?,
      tag: null == tag
          ? _value.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as SecretStreamMessageTag,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SecretStreamPlainMessageCopyWith<$Res>
    implements $SecretStreamPlainMessageCopyWith<$Res> {
  factory _$$_SecretStreamPlainMessageCopyWith(
          _$_SecretStreamPlainMessage value,
          $Res Function(_$_SecretStreamPlainMessage) then) =
      __$$_SecretStreamPlainMessageCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Uint8List message,
      Uint8List? additionalData,
      SecretStreamMessageTag tag});
}

/// @nodoc
class __$$_SecretStreamPlainMessageCopyWithImpl<$Res>
    extends _$SecretStreamPlainMessageCopyWithImpl<$Res,
        _$_SecretStreamPlainMessage>
    implements _$$_SecretStreamPlainMessageCopyWith<$Res> {
  __$$_SecretStreamPlainMessageCopyWithImpl(_$_SecretStreamPlainMessage _value,
      $Res Function(_$_SecretStreamPlainMessage) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? additionalData = freezed,
    Object? tag = null,
  }) {
    return _then(_$_SecretStreamPlainMessage(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      additionalData: freezed == additionalData
          ? _value.additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Uint8List?,
      tag: null == tag
          ? _value.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as SecretStreamMessageTag,
    ));
  }
}

/// @nodoc

class _$_SecretStreamPlainMessage implements _SecretStreamPlainMessage {
  const _$_SecretStreamPlainMessage(this.message,
      {this.additionalData, this.tag = SecretStreamMessageTag.message});

  /// The message that should be encrypted.
  @override
  final Uint8List message;

  /// Additional data, that should be used to generate authentication data.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#encryption
  @override
  final Uint8List? additionalData;

  /// The message tag that should be attached to the encrypted message.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#encryption
  /// and https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#constants
  @override
  @JsonKey()
  final SecretStreamMessageTag tag;

  @override
  String toString() {
    return 'SecretStreamPlainMessage(message: $message, additionalData: $additionalData, tag: $tag)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SecretStreamPlainMessage &&
            const DeepCollectionEquality().equals(other.message, message) &&
            const DeepCollectionEquality()
                .equals(other.additionalData, additionalData) &&
            (identical(other.tag, tag) || other.tag == tag));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(message),
      const DeepCollectionEquality().hash(additionalData),
      tag);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SecretStreamPlainMessageCopyWith<_$_SecretStreamPlainMessage>
      get copyWith => __$$_SecretStreamPlainMessageCopyWithImpl<
          _$_SecretStreamPlainMessage>(this, _$identity);
}

abstract class _SecretStreamPlainMessage implements SecretStreamPlainMessage {
  const factory _SecretStreamPlainMessage(final Uint8List message,
      {final Uint8List? additionalData,
      final SecretStreamMessageTag tag}) = _$_SecretStreamPlainMessage;

  @override

  /// The message that should be encrypted.
  Uint8List get message;
  @override

  /// Additional data, that should be used to generate authentication data.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#encryption
  Uint8List? get additionalData;
  @override

  /// The message tag that should be attached to the encrypted message.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#encryption
  /// and https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#constants
  SecretStreamMessageTag get tag;
  @override
  @JsonKey(ignore: true)
  _$$_SecretStreamPlainMessageCopyWith<_$_SecretStreamPlainMessage>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SecretStreamCipherMessage {
  /// The message that should be decrypted.
  Uint8List get message => throw _privateConstructorUsedError;

  /// Additional data, that should be used to generate authentication data.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#decryption
  Uint8List? get additionalData => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SecretStreamCipherMessageCopyWith<SecretStreamCipherMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecretStreamCipherMessageCopyWith<$Res> {
  factory $SecretStreamCipherMessageCopyWith(SecretStreamCipherMessage value,
          $Res Function(SecretStreamCipherMessage) then) =
      _$SecretStreamCipherMessageCopyWithImpl<$Res, SecretStreamCipherMessage>;
  @useResult
  $Res call({Uint8List message, Uint8List? additionalData});
}

/// @nodoc
class _$SecretStreamCipherMessageCopyWithImpl<$Res,
        $Val extends SecretStreamCipherMessage>
    implements $SecretStreamCipherMessageCopyWith<$Res> {
  _$SecretStreamCipherMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? additionalData = freezed,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      additionalData: freezed == additionalData
          ? _value.additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Uint8List?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SecretStreamCipherMessageCopyWith<$Res>
    implements $SecretStreamCipherMessageCopyWith<$Res> {
  factory _$$_SecretStreamCipherMessageCopyWith(
          _$_SecretStreamCipherMessage value,
          $Res Function(_$_SecretStreamCipherMessage) then) =
      __$$_SecretStreamCipherMessageCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Uint8List message, Uint8List? additionalData});
}

/// @nodoc
class __$$_SecretStreamCipherMessageCopyWithImpl<$Res>
    extends _$SecretStreamCipherMessageCopyWithImpl<$Res,
        _$_SecretStreamCipherMessage>
    implements _$$_SecretStreamCipherMessageCopyWith<$Res> {
  __$$_SecretStreamCipherMessageCopyWithImpl(
      _$_SecretStreamCipherMessage _value,
      $Res Function(_$_SecretStreamCipherMessage) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? additionalData = freezed,
  }) {
    return _then(_$_SecretStreamCipherMessage(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      additionalData: freezed == additionalData
          ? _value.additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Uint8List?,
    ));
  }
}

/// @nodoc

class _$_SecretStreamCipherMessage implements _SecretStreamCipherMessage {
  const _$_SecretStreamCipherMessage(this.message, {this.additionalData});

  /// The message that should be decrypted.
  @override
  final Uint8List message;

  /// Additional data, that should be used to generate authentication data.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#decryption
  @override
  final Uint8List? additionalData;

  @override
  String toString() {
    return 'SecretStreamCipherMessage(message: $message, additionalData: $additionalData)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SecretStreamCipherMessage &&
            const DeepCollectionEquality().equals(other.message, message) &&
            const DeepCollectionEquality()
                .equals(other.additionalData, additionalData));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(message),
      const DeepCollectionEquality().hash(additionalData));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SecretStreamCipherMessageCopyWith<_$_SecretStreamCipherMessage>
      get copyWith => __$$_SecretStreamCipherMessageCopyWithImpl<
          _$_SecretStreamCipherMessage>(this, _$identity);
}

abstract class _SecretStreamCipherMessage implements SecretStreamCipherMessage {
  const factory _SecretStreamCipherMessage(final Uint8List message,
      {final Uint8List? additionalData}) = _$_SecretStreamCipherMessage;

  @override

  /// The message that should be decrypted.
  Uint8List get message;
  @override

  /// Additional data, that should be used to generate authentication data.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#decryption
  Uint8List? get additionalData;
  @override
  @JsonKey(ignore: true)
  _$$_SecretStreamCipherMessageCopyWith<_$_SecretStreamCipherMessage>
      get copyWith => throw _privateConstructorUsedError;
}
