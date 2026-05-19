/// @docImport 'dart:io';
/// @docImport 'ipcrypt.dart';
library;

import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'helpers/platform_types/internet_address_fallback.dart'
    if (dart.library.io) 'helpers/platform_types/internet_address_io.dart'
    as ia;
import 'sodium.dart';

/// A platform-independent representation of an IP address used by the
/// [Ipcrypt] API.
///
/// Internally stores the address in the 16-byte binary format required by
/// libsodium (using `sodium_ip2bin` / `sodium_bin2ip` for all conversions).
/// IPv4 addresses are represented in IPv4-mapped IPv6 form internally.
///
/// To create an instance, use [IpAddress.fromString] or [IpAddress.fromBytes],
/// both of which delegate to the platform-specific implementation via [Sodium].
abstract class IpAddress {
  /// Creates an [IpAddress] from the platform native [address].
  ///
  /// Convenience factory constructor that redirects to [Sodium.ipFromAddress]
  /// and calls it with [address] on [sodium].
  factory IpAddress(Sodium sodium, ia.InternetAddress address) =>
      sodium.ipFromAddress(address);

  /// Creates an [IpAddress] from the string representation [address].
  ///
  /// Convenience factory constructor that redirects to [Sodium.ipFromString]
  /// and calls it with [address] on [sodium].
  factory IpAddress.parse(Sodium sodium, String address) =>
      sodium.ipFromString(address);

  /// Creates an [IpAddress] from the 16-byte binary representation [bytes].
  ///
  /// Convenience factory constructor that redirects to [Sodium.ipFromBytes]
  /// and calls it with [bytes] on [sodium].
  factory IpAddress.fromRawBytes(Sodium sodium, Uint8List bytes) =>
      sodium.ipFromBytes(bytes);

  /// The platform native representation of the IP address.
  ///
  /// On platforms where `dart:io` is available, this returns an instance
  /// of [InternetAddress]. On other platforms (e.g. web), where that type is
  /// not available, it returns the string representation of the IP address
  /// instead.
  ia.InternetAddress get address;

  /// The canonical string representation of the IP address.
  ///
  /// Returns a dotted-decimal string for IPv4 (e.g. `"192.0.2.1"`) or a
  /// colon-separated hex string for IPv6 (e.g. `"::1"`). Uses `sodium_bin2ip`
  /// internally.
  String get addressString;

  /// The 16-byte binary representation in network byte order.
  ///
  /// IPv4 addresses are stored in IPv4-mapped IPv6 form.
  Uint8List get bytes;
}

/// @nodoc
@internal
mixin IpAddressEquality implements IpAddress {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IpAddress) return false;
    return const DeepCollectionEquality().equals(bytes, other.bytes);
  }

  // coverage:ignore-start
  @override
  int get hashCode => Object.hashAll(bytes);
  // coverage:ignore-end

  @override
  String toString() => addressString;
}
