import 'package:js/js.dart';

/// A wrapper around the JS
/// [BigInt](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/BigInt)
/// type.
@JS('BigInt')
external Function get _jsBigInt;

/// A wrapper around the JS
/// [BigInt](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/BigInt)
/// type.
extension type JsBigInt(dynamic raw) {
  /// Creates a JS BigInt from [value]
  factory JsBigInt.fromDart(BigInt value) =>
      // ignore: avoid_dynamic_calls
      JsBigInt(_jsBigInt(value.toString()));

  /// Converts this to a [BigInt]
  BigInt toDart() => BigInt.parse(raw.toString());
}
