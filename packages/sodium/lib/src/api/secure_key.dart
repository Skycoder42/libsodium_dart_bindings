import 'dart:async';
import 'dart:typed_data';

typedef SecureCallbackFn<T> = T Function(Uint8List data);

abstract class SecureKey {
  const SecureKey._(); // coverage:ignore-line

  int get length;

  T runUnlockedSync<T>(
    SecureCallbackFn<T> callback, {
    bool writable = false,
  });

  FutureOr<T> runUnlockedAsync<T>(
    SecureCallbackFn<FutureOr<T>> callback, {
    bool writable = false,
  });

  Uint8List extractBytes();

  SecureKey copy();

  void dispose();
}

mixin SecureKeyEquality implements SecureKey {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else if (other is! SecureKey) {
      return false;
    } else {
      return runUnlockedSync(
        (thisData) => other.runUnlockedSync(
          (otherData) {
            if (thisData.length != otherData.length) {
              return false;
            }
            for (var i = 0; i < thisData.length; ++i) {
              if (thisData[i] != otherData[i]) {
                return false;
              }
            }
            return true;
          },
        ),
      );
    }
  }

  // coverage:ignore-start
  @override
  int get hashCode => runUnlockedSync((data) => data.hashCode);
  // coverage:ignore-end
}
