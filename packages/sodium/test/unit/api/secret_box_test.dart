import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secret_box.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../test_data.dart';

class MockSecretBox extends Mock
    with SecretBoxValidations
    implements SecretBox {}

void main() {
  group('SecretBoxValidations', () {
    late MockSecretBox sutMock;

    setUp(() {
      sutMock = MockSecretBox();
    });

    testData<Tuple2<int, bool>>(
      'validateNonce asserts if value is not in range',
      const [
        Tuple2(5, false),
        Tuple2(4, true),
        Tuple2(6, true),
      ],
      (fixture) {
        when(() => sutMock.nonceBytes).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sutMock.validateNonce(Uint8List(fixture.item1)),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
        );
        verify(() => sutMock.nonceBytes);
      },
    );

    testData<Tuple2<int, bool>>(
      'validateKey asserts if value is not in range',
      const [
        Tuple2(5, false),
        Tuple2(4, true),
        Tuple2(6, true),
      ],
      (fixture) {
        when(() => sutMock.keyBytes).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sutMock.validateKey(Uint8List(fixture.item1)),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
        );
        verify(() => sutMock.keyBytes);
      },
    );

    testData<Tuple2<int, bool>>(
      'validateMac asserts if value is not in range',
      const [
        Tuple2(5, false),
        Tuple2(4, true),
        Tuple2(6, true),
      ],
      (fixture) {
        when(() => sutMock.macBytes).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sutMock.validateMac(Uint8List(fixture.item1)),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
        );
        verify(() => sutMock.macBytes);
      },
    );
  });
}
