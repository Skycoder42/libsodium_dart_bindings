import 'dart:async';
import 'dart:typed_data';

typedef SecureCallbackFn<T> = T Function(Uint8List data);

abstract class SecureKey {
  T runUnlockedSync<T>(SecureCallbackFn<T> callback);

  FutureOr<T> runUnlockedAsync<T>(SecureCallbackFn<FutureOr<T>> callback);

  Uint8List extractBytes();

  void dispose();
}
