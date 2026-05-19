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

/// @nodoc
@internal
class IpAddressFFI with IpAddressEquality implements IpAddress {
  static const _ipMaxLen = 46;

  /// @nodoc
  final LibSodiumFFI sodium;

  @internal
  final SodiumPointer<UnsignedChar> rawBytes;

  /// @nodoc
  factory IpAddressFFI(LibSodiumFFI sodium, InternetAddress addr) =>
      switch (addr.type) {
        .IPv4 => .parse(sodium, addr.address),
        .IPv6 => .fromRawBytes(sodium, addr.rawAddress),
        _ => throw ArgumentError.value(
          addr.type,
          'addr',
          'Unsupported InternetAddressType. Must be IPv4 or IPv6.',
        ),
      };

  /// @nodoc
  factory IpAddressFFI.parse(LibSodiumFFI sodium, String address) {
    SodiumPointer<UnsignedChar>? binPtr;
    final strPtr = address.toSodiumPointer(sodium);
    try {
      binPtr = SodiumPointer.alloc(sodium, count: 16);
      final result = sodium.sodium_ip2bin(binPtr.ptr, strPtr.ptr, strPtr.count);
      SodiumException.checkSucceededInt(result);
      return .fromPointer(sodium, binPtr);
    } catch (_) {
      binPtr?.dispose();
      rethrow;
    } finally {
      strPtr.dispose();
    }
  }

  /// @nodoc
  factory IpAddressFFI.fromRawBytes(LibSodiumFFI sodium, Uint8List bytes) {
    if (bytes.length != 16) {
      throw RangeError.value(bytes.length, 'bytes', 'must be 16 bytes');
    }
    return .fromPointer(
      sodium,
      bytes.toSodiumPointer(sodium, memoryProtection: .readOnly),
    );
  }

  /// @nodoc
  IpAddressFFI.fromPointer(this.sodium, this.rawBytes) {
    rawBytes.memoryProtection = .readOnly;
  }

  @override
  Uint8List get bytes => Uint8List.fromList(rawBytes.asListView<Uint8List>());

  @override
  String get addressString {
    final strPtr = SodiumPointer<Char>.alloc(
      sodium,
      count: _ipMaxLen,
      zeroMemory: true,
    );
    try {
      final result = sodium.sodium_bin2ip(strPtr.ptr, _ipMaxLen, rawBytes.ptr);
      if (result == nullptr) {
        throw SodiumException('Failed to convert IP address to string');
      }
      return strPtr.toDartString(zeroTerminated: true);
    } finally {
      strPtr.dispose();
    }
  }

  @override
  ia.InternetAddress get address =>
      InternetAddress.fromRawAddress(bytes, type: .IPv6) as ia.InternetAddress;
}
