import 'dart:js_interop';

@JS('BigInt')
external JSBigInt _jsBigInt(String rawValue);

extension JSBigIntX on JSBigInt {
  BigInt get toDart => BigInt.parse(toString());
}

extension BigIntX on BigInt {
  JSBigInt get toJS => _jsBigInt(toString());
}
