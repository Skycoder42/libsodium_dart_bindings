import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/helpers/platform_types/internet_address_fallback.dart'
    if (dart.library.io) '../../api/helpers/platform_types/internet_address_io.dart'
    as ia;
import '../../api/ip_address.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.wrapper.dart';
import '../bindings/sodium_pointer.dart';
import '../bindings/sodium_scope.dart';

/// @nodoc
@internal
class IpAddressFFI with IpAddressEquality implements IpAddress {
  static const _ipMaxLen = 46;

  /// @nodoc
  final LibSodiumFFI sodium;

  @internal
  final SodiumPointer<UnsignedChar> rawBytes;

  /// @nodoc
  factory(LibSodiumFFI sodium, InternetAddress addr) => switch (addr.type) {
    .IPv4 => .parse(sodium, addr.address),
    .IPv6 => .fromRawBytes(sodium, addr.rawAddress),
    _ => throw ArgumentError.value(
      addr.type,
      'addr',
      'Unsupported InternetAddressType. Must be IPv4 or IPv6.',
    ),
  };

  /// @nodoc
  factory parse(LibSodiumFFI sodium, String address) => sodiumScope(sodium, (
    scope,
  ) {
    final strPtr = scope.copyString(address);
    final binPtr = scope.alloc<UnsignedChar>(16);
    final result = sodium.sodium_ip2bin(binPtr.ptr, strPtr.ptr, strPtr.count);
    SodiumException.checkSucceededInt(result);
    return .fromPointer(sodium, scope.takePointer(binPtr));
  });

  /// @nodoc
  factory fromRawBytes(LibSodiumFFI sodium, Uint8List bytes) {
    if (bytes.length != 16) {
      throw RangeError.value(bytes.length, 'bytes', 'must be 16 bytes');
    }
    return .fromPointer(
      sodium,
      bytes.toSodiumPointer(sodium, memoryProtection: .readOnly),
    );
  }

  /// @nodoc
  new fromPointer(this.sodium, this.rawBytes) {
    rawBytes.memoryProtection = .readOnly;
  }

  @override
  Uint8List get bytes =>
      Uint8List.fromList(rawBytes.asListView<Uint8List>()).asUnmodifiableView();

  @override
  String get addressString => sodiumScope(sodium, (scope) {
    final strPtr = scope.alloc<Char>(_ipMaxLen, zeroMemory: true);

    final result = sodium.sodium_bin2ip(strPtr.ptr, _ipMaxLen, rawBytes.ptr);
    if (result == nullptr) {
      throw SodiumException('Failed to convert IP address to string');
    }

    return scope.takeString(strPtr);
  });

  @override
  ia.InternetAddress get address =>
      InternetAddress.fromRawAddress(bytes, type: .IPv6) as ia.InternetAddress;
}
