import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'sodium.dart';

/// A callback function to operate on an unlocked key.
typedef SecureCallbackFn<T> = T Function(Uint8List data);

/// A platform independent secure key, that uses native memory.
///
/// This class is designed to make it as secure as possible to store your secret
/// keys in memory. The key tries to protect the memory from unallowed access
/// and only allows reading and writing in scoped callbacks. See
/// [runUnlockedSync] and [runUnlockedAsync].
///
/// In the dart VM, it uses native C memory and applies security features of
/// libsodium to protect it. The applied mechanisms are:
/// - sodium_malloc (to allocate the memory)
/// - sodium_mlock
/// - sodium_mprotect_noaccess
/// - sodium_memzero (when the key is disposed)
///
/// In JavaScript however, there is no way to secure memory. So, instead a
/// simple `Uint8Array` is used that gets cleared with sodium_memzero when the
/// key is disposed. There are no other security measures that can be applied in
/// a JavaScript context.
///
/// **Note:** To create a new secure key, you can either use the factory
/// constructors, which require an instance of [Sodium], or you directly use the
/// methods [Sodium.secureAlloc], [Sodium.secureRandom] or [Sodium.secureCopy],
/// which do the same thing as the factory constructors. In fact, they are the
/// actual implementation. The factory constructors simply exist for
/// convenience.
///
/// See https://libsodium.gitbook.io/doc/memory_management
abstract class SecureKey {
  /// Allocates a new [SecureKey] of [length] bytes.
  ///
  /// Convenience factory constructor that redirects to [Sodium.secureAlloc] and
  /// calls it with [length] on [sodium].
  factory SecureKey(Sodium sodium, int length) => sodium.secureAlloc(length);

  /// Allocates new memory for a [SecureKey] and copies the data from [data].
  ///
  /// Convenience factory constructor that redirects to [Sodium.secureCopy] and
  /// calls it with [data] on [sodium].
  factory SecureKey.fromList(Sodium sodium, Uint8List data) =>
      sodium.secureCopy(data);

  /// Allocates new memory for a [SecureKey] and fills it with [length] bytes of
  /// random data.
  ///
  /// Convenience factory constructor that redirects to [Sodium.secureRandom]
  /// and calls it with [length] on [sodium].
  factory SecureKey.random(Sodium sodium, int length) =>
      sodium.secureRandom(length);

  /// Returns the length of the key in bytes, without unlocking it.
  int get length;

  /// Runs the given callback with the unlocked key data.
  ///
  /// This method first unlocks the memory, allowing read-only (or read-write,
  /// if [writable] is set to true) access to the memory. It then calls the
  /// given [callback] with a [Uint8List] view of the data. This means, if you
  /// modify the byte array, the data of the underlying key gets modified as
  /// well. The callback must complete synchronously, as right after it has
  /// finished, the key will be locked again, preventing further access to it.
  ///
  /// The return value of the method is the same as the one returned from the
  /// callback.
  T runUnlockedSync<T>(
    SecureCallbackFn<T> callback, {
    bool writable = false,
  });

  /// Runs the given callback with the unlocked key data.
  ///
  /// This method first unlocks the memory, allowing read-only (or read-write,
  /// if [writable] is set to true) access to the memory. It then calls the
  /// given [callback] with a [Uint8List] view of the data. This means, if you
  /// modify the byte array, the data of the underlying key gets modified as
  /// well. The callback can run asynchronously, as the method waits for the
  /// returned future to complete. After it did, the key will be locked again,
  /// preventing further access to it.
  ///
  /// The return value of the method is the same as the one returned from the
  /// callback.
  FutureOr<T> runUnlockedAsync<T>(
    SecureCallbackFn<FutureOr<T>> callback, {
    bool writable = false,
  });

  /// Creates a copy of the raw key bytes in dart memory.
  ///
  /// This copies the bytes from native to dart memory. The resulting data is
  /// independent of the key, but also not protected as well anymore.
  Uint8List extractBytes();

  /// Creates a secure copy of the key.
  ///
  /// The resulting key is an independent copy of the original key, but with the
  /// same memory protection as before. The copying is done on native memory,
  /// without exposing the data to dart when using the dart VM.
  SecureKey copy();

  /// Disposes the key.
  ///
  /// This will zero the memory of the key and then free any resources. This is
  /// verify important not to forget, as otherwise it can lead to memory leaks
  /// in the dart VM.
  void dispose();
}

/// @nodoc
@internal
mixin SecureKeyEquality implements SecureKey {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else if (other is! SecureKey) {
      return false;
    } else if (length != other.length) {
      return false;
    } else {
      return runUnlockedSync(
        (thisData) => other.runUnlockedSync(
          (otherData) {
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
