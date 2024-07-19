import 'dart:js_interop';

@JS('BigInt')
external JSBigInt _jsBigInt(String rawValue);

/// Extension on [JSBigInt] for conversion to dart
extension JSBigIntX on JSBigInt {
  /// Converts a [JSBigInt] to dart [BigInt]
  BigInt get toDart => BigInt.parse(toString());
}

/// Extension on [BigInt] for conversion to js
extension BigIntX on BigInt {
  /// Converts a dart [BigInt] to [JSBigInt]
  JSBigInt get toJS => _jsBigInt(toString());
}
