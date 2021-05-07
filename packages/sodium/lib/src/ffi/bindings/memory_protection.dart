/// The different levels of memory protection that libsodium provides.
///
/// These protection levels are used by the [SodiumAllocator] and
/// [SodiumPointer] classes to control the memory protection level of memory
/// managed by libsodium.
enum MemoryProtection {
  /// Causes sodium_mprotect_noaccess to be applied.
  ///
  /// See https://libsodium.gitbook.io/doc/memory_management#guarded-heap-allocations
  noAccess,

  /// Causes sodium_mprotect_readonly to be applied.
  ///
  /// See https://libsodium.gitbook.io/doc/memory_management#guarded-heap-allocations
  readOnly,

  /// Causes sodium_mprotect_readwrite to be applied.
  ///
  /// See https://libsodium.gitbook.io/doc/memory_management#guarded-heap-allocations
  readWrite,
}
