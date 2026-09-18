import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/helpers/platform_types/internet_address_fallback.dart';
import '../../api/ip_address.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';

@internal
// ignore: public_member_api_docs false positive
class IpAddressJS.fromJsBytes(
  final LibSodiumJS sodium,
  final JSUint8Array rawBytes,
) with IpAddressEquality implements IpAddress {
  factory fromString(LibSodiumJS sodium, String address) =>
      IpAddressJS.fromJsBytes(
        sodium,
        jsErrorWrap(() => sodium.sodium_ip2bin(address)),
      );

  factory fromBytes(LibSodiumJS sodium, Uint8List bytes) {
    if (bytes.length != 16) {
      throw RangeError.value(bytes.length, 'bytes', 'must be 16 bytes');
    }
    return IpAddressJS.fromJsBytes(sodium, bytes.toJS);
  }

  @override
  Uint8List get bytes => rawBytes.toDart.asUnmodifiableView();

  @override
  String get addressString => jsErrorWrap(() => sodium.sodium_bin2ip(rawBytes));

  @override
  InternetAddress get address => addressString;
}
