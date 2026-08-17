import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:meta/meta.dart';

import '../api/secure_key_ffi.dart';
import 'libsodium.ffi.wrapper.dart';
import 'memory_protection.dart';
import 'sodium_pointer.dart';

class _ScopeEntry {
  final Object resource;
  final void Function() dispose;

  new(this.resource, this.dispose);
}

/// A lexical scope that owns libsodium allocations and disposes every one it
/// still owns, in reverse (LIFO) order, when the body returns **or** throws.
///
/// This is **not** a `package:ffi` [Arena]: every allocation goes through
/// [SodiumPointer]/[SecureKeyFFI] and therefore uses libsodium's guarded, secure
/// memory (`sodium_malloc`, `mlock`, `mprotect`, zero-on-free) — never
/// `malloc`/`calloc`.
///
/// Ownership: the `copy*`/`alloc*` methods register the allocation for disposal
/// at scope exit. The `take*` methods transfer ownership **out** of the scope
/// (to a returned [SodiumPointer]-backed list, [String], [SecureKeyFFI] or
/// [SodiumPointer]) and stop tracking it. On the error path the body never
/// reaches its `take*` calls, so the scope frees those buffers too.
///
/// Every `take*` method must be given the very instance that `copy*`/`alloc*`
/// returned. Passing a [SodiumPointer.viewAt] view of it, or a resource from
/// outside the scope, is a programming error and asserted against.
///
/// Scope exit disposes every remaining entry, even if one of the disposals
/// fails. Such a failure is reported as an unhandled error to the current
/// [Zone] instead of being thrown, so that it can neither mask the error that
/// broke the body nor turn a successful call into a failing one.
///
/// Instances are created by and only valid for the duration of a [sodiumScope]
/// call.
class SodiumScope {
  final LibSodiumFFI _sodium;
  final _entries = <_ScopeEntry>[];

  new _(this._sodium);

  // ---- copy: Dart input -> registered native pointer ----

  /// Copies a typed [data] list into a fresh, tracked [SodiumPointer].
  ///
  /// Covers transient inputs such as messages, nonces, MACs, public keys, salts
  /// and ciphertext. Defaults to [MemoryProtection.readOnly], matching the
  /// transient-input convention. Wraps [TypedNumberListX.toSodiumPointer].
  SodiumPointer<T> copyList<T extends NativeType>(
    List<num> data, {
    MemoryProtection memoryProtection = .readOnly,
  }) => _track(
    data.toSodiumPointer<T>(_sodium, memoryProtection: memoryProtection),
  );

  /// Copies [str] into a fresh, tracked [SodiumPointer] of [Char].
  ///
  /// Covers kdf/aead contexts, passwords and encoded hashes. [memoryWidth] pads
  /// the buffer to a fixed size (e.g. a kdf context) and throws an
  /// [ArgumentError] if [str] does not fit; [zeroTerminated] stops the encoding
  /// at the first NUL and drops the rest of [str]; [encoding] selects the
  /// encoding and defaults to [utf8]. Defaults to
  /// [MemoryProtection.readOnly]. Wraps [SodiumString.toSodiumPointer].
  SodiumPointer<Char> copyString(
    String str, {
    int? memoryWidth,
    bool zeroTerminated = false,
    MemoryProtection memoryProtection = .readOnly,
    Encoding encoding = utf8,
  }) => _track(
    str.toSodiumPointer(
      _sodium,
      memoryWidth: memoryWidth,
      zeroTerminated: zeroTerminated,
      memoryProtection: memoryProtection,
      encoding: encoding,
    ),
  );

  // ---- alloc: empty output buffer -> registered ----

  /// Allocates a fresh, tracked output buffer of [count] elements.
  ///
  /// The [SodiumPointer] is returned so callers can keep using `..fill(...)`,
  /// `.viewAt(...)`, `.ptr` and `.asListView()` directly. If [zeroMemory] is
  /// set, the buffer is zeroed instead of filled with the `0xdb` guard byte.
  /// Defaults to [MemoryProtection.readWrite]. Wraps [SodiumPointer.alloc].
  SodiumPointer<T> alloc<T extends NativeType>(
    int count, {
    bool zeroMemory = false,
    MemoryProtection memoryProtection = .readWrite,
  }) => _track(
    SodiumPointer<T>.alloc(
      _sodium,
      count: count,
      zeroMemory: zeroMemory,
      memoryProtection: memoryProtection,
    ),
  );

  /// Allocates a fresh, tracked [SecureKeyFFI] of [length] bytes.
  ///
  /// The key is locked and set to [MemoryProtection.noAccess]. Covers subkeys,
  /// kx session keys and derived pwhash keys. Wraps [SecureKeyFFI.alloc]. Use
  /// [takeSecureKey] to hand the key back to the caller live.
  @internal
  SecureKeyFFI allocSecureKey(int length) {
    final key = SecureKeyFFI.alloc(_sodium, length);
    _entries.add(_ScopeEntry(key, key.dispose));
    return key;
  }

  // ---- take: native -> Dart, ownership leaves the scope ----

  /// Hands [pointer]'s memory to the returned list and stops tracking it.
  ///
  /// Mirrors `asListView<TList>(owned: true)`: the pointer is detached and the
  /// returned list's finalizer becomes responsible for freeing it. `TList` is
  /// inferred from the call context (defaults to `List<num>`; call
  /// `takeBytes<Uint8List>(p)` for a byte list). If the view cannot be created,
  /// [pointer] stays tracked so the scope still frees it.
  ///
  /// [pointer] must be a pointer this scope owns. A [SodiumPointer.viewAt] view
  /// cannot be detached from its parent and thus always throws an
  /// [UnsupportedError].
  TList takeBytes<TList extends List<num>>(SodiumPointer<NativeType> pointer) {
    // asListView first: if it throws, the pointer stays tracked
    final view = pointer.asListView<TList>(owned: true);
    _untrack(pointer);
    return view;
  }

  /// Copies [pointer] out as a Dart [String], then frees the native buffer
  /// immediately and stops tracking it.
  ///
  /// Freeing at once (rather than deferring to scope exit) ensures secret hash
  /// strings are zeroed as soon as possible. [zeroTerminated] stops decoding at
  /// the first NUL byte; [encoding] selects the encoding and defaults to
  /// [utf8]. Wraps [CharSodiumPtr.toDartString]. [pointer] must be
  /// a pointer this scope owns.
  ///
  /// If the decoding fails, [pointer] stays tracked so the scope still frees
  /// it.
  String takeString(
    SodiumPointer<Char> pointer, {
    bool zeroTerminated = true,
    Encoding encoding = utf8,
  }) {
    final result = pointer.toDartString(
      zeroTerminated: zeroTerminated,
      encoding: encoding,
    );
    _untrack(pointer);
    pointer.dispose();
    return result;
  }

  /// Returns [key] to the caller live and stops tracking it, so scope exit does
  /// **not** free it.
  ///
  /// Covers derived keys and kx session keys handed back to the user. The
  /// caller becomes responsible for disposing the returned [SecureKeyFFI].
  /// [key] must be a key this scope owns.
  @internal
  SecureKeyFFI takeSecureKey(SecureKeyFFI key) {
    _untrack(key);
    return key;
  }

  /// Returns [pointer] to the caller live and stops tracking it, so scope exit
  /// does **not** free it.
  ///
  /// Covers pointers that become long-lived state, such as a secret stream
  /// crypto state or the raw bytes of an ip address. The caller becomes
  /// responsible for disposing the returned [SodiumPointer]. [pointer] must be
  /// a pointer this scope owns.
  ///
  /// Unlike [takeBytes], the pointer is handed back as-is: it keeps its
  /// finalizer and its memory protection, and no list view is created.
  SodiumPointer<T> takePointer<T extends NativeType>(SodiumPointer<T> pointer) {
    _untrack(pointer);
    return pointer;
  }

  SodiumPointer<T> _track<T extends NativeType>(SodiumPointer<T> pointer) {
    _entries.add(_ScopeEntry(pointer, pointer.dispose));
    return pointer;
  }

  void _untrack(Object resource) {
    final trackedCount = _entries.length;
    _entries.removeWhere((entry) => identical(entry.resource, resource));
    assert(
      _entries.length < trackedCount,
      'The resource is not owned by this scope. take* must be called with the '
      'instance returned by copy*/alloc* - not with a viewAt() of it.',
    );
  }

  void _releaseAll() {
    // Dispose in reverse (LIFO) order, mirroring package:ffi's Arena.
    for (var i = _entries.length - 1; i >= 0; i--) {
      try {
        _entries[i].dispose();
      } catch (error, stackTrace) {
        // Cleanup must continue for the remaining entries, and must neither
        // mask the error that broke the body nor turn a successful call into a
        // failing one - so the failure is reported instead of thrown.
        Zone.current.handleUncaughtError(error, stackTrace);
      }
    }
    _entries.clear();
  }
}

/// Runs [body] in a fresh [SodiumScope], disposing everything the scope still
/// owns, in reverse (LIFO) order, when [body] returns or throws.
///
/// This is synchronous by design: the operations that use it never allocate
/// across an `await`, so there is no [Future] branch. The value produced by
/// [body] is returned unchanged.
R sodiumScope<R>(LibSodiumFFI sodium, R Function(SodiumScope scope) body) {
  final scope = SodiumScope._(sodium);
  try {
    return body(scope);
  } finally {
    scope._releaseAll();
  }
}
