import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';

import 'package:sodium/src/api/secure_key.dart';

class SecureKeyFake extends Fake with SecureKeyEquality implements SecureKey {
  final Uint8List data;
  bool disposed = false;

  SecureKeyFake(List<int> data) : data = Uint8List.fromList(data);

  SecureKeyFake.empty(int length) : data = Uint8List(length);

  @override
  int get length => data.length;

  @override
  T runUnlockedSync<T>(SecureCallbackFn<T> callback, {bool writable = false}) =>
      callback(data);

  @override
  SecureKey copy() => SecureKeyFake(data);

  @override
  Uint8List extractBytes() => data;

  @override
  void dispose() => disposed = true;
}
