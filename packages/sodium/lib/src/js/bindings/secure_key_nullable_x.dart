import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/secure_key.dart';

/// @nodoc
@internal
typedef SecureNullableCallbackFn<T> = T Function(Uint8List? data);

/// @nodoc
@internal
extension SecureKeyNullableX on SecureKey? {
  T runMaybeUnlockedSync<T>(SecureNullableCallbackFn<T> callback) =>
      this != null
      ? this!.runUnlockedSync((data) => callback(data))
      : callback(null);
}
