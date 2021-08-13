import 'package:sodium/sodium.dart';

extension SecureKeySplit on SecureKey {
  /// Creates multiple secure keys of different [lengths] from a single key.
  /// It is especially useful for using pwHash to generate enough bytes for
  /// multiple keys.
  ///
  /// The returned keys are independent copies of portions of the original key,
  /// with the same kind of memory protection. The copying is done on secure,
  /// native memory controlled by [sodium], without exposing the data to dart
  /// when using the dart VM.
  List<SecureKey> split(Sodium sodium, List<int> lengths) => runUnlockedSync(
        (originalKeyData) {
          final lenthsSum = lengths.reduce((value, element) => value + element);
          RangeError.checkValidRange(
            0,
            lenthsSum,
            originalKeyData.length,
          );

          final keys = <SecureKey>[];

          try {
            var start = 0;
            for (final length in lengths) {
              final splitKey = SecureKey(sodium, length)
                ..runUnlockedSync(
                  (splitKeyData) => splitKeyData.setRange(
                    0,
                    length,
                    originalKeyData,
                    start,
                  ),
                  writable: true,
                );
              keys.add(splitKey);
              start += length;
            }
          } catch (e) {
            for (final key in keys) {
              key.dispose();
            }
            rethrow;
          }

          return keys;
        },
      );
}
