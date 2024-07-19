import 'package:meta/meta.dart';

@internal
extension IntHelpersX on int {
  @visibleForTesting
  static const uint32Max = 4294967295;

  int safeUnsigned(int limit) => this < 0 ? limit : this;

  int safeUint32() => safeUnsigned(uint32Max);
}
