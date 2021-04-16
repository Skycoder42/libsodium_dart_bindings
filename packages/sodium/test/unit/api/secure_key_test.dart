import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../test_data.dart';

class SecureKeyFake extends Fake with SecureKeyEquality implements SecureKey {
  final Uint8List data;

  SecureKeyFake(List<int> data) : data = Uint8List.fromList(data);

  @override
  T runUnlockedSync<T>(SecureCallbackFn<T> callback, {bool writable = false}) =>
      callback(data);
}

void main() {
  test('operator== returns true if identical', () {
    final sut = SecureKeyFake(const [1, 2, 3, 4]);
    expect(sut, equals(sut));
  });

  test('operator== returns false if different type', () {
    final sut = SecureKeyFake(const [1, 2, 3, 4]);
    expect(sut, isNot(equals(Uint8List.fromList(const [1, 2, 3, 4]))));
  });

  testData<Tuple3<List<int>, List<int>, bool>>(
    'operator== returns correct result for data',
    const [
      Tuple3([], [], true),
      Tuple3([1, 2, 3], [1, 2, 3], true),
      Tuple3([1, 2, 3], [1, 4, 3], false),
      Tuple3([1, 2], [1, 2, 3], false),
      Tuple3([1, 2, 3], [1, 2], false),
    ],
    (fixture) {
      final sut1 = SecureKeyFake(fixture.item1);
      final sut2 = SecureKeyFake(fixture.item2);
      expect(sut1, fixture.item3 ? equals(sut2) : isNot(equals(sut2)));
    },
  );
}
