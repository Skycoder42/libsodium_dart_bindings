import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/xof.dart';
import 'package:test/test.dart';

import '../../test_data.dart';

class MockXof extends Mock with XofValidations implements Xof;

class MockXofConsumer extends Mock
    with XofConsumerValidations
    implements XofConsumer;

@isTestGroup
void testValidateOutLen(void Function(int value) sut) => testData<(int, bool)>(
  'validateOutLen asserts if value is not at least 1',
  const [(1, false), (2, false), (100000, false), (0, true), (-1, true)],
  (fixture) {
    final exceptionMatcher = throwsA(isA<RangeError>());
    expect(
      () => sut(fixture.$1),
      fixture.$2 ? exceptionMatcher : isNot(exceptionMatcher),
    );
  },
);

void main() {
  group('XofValidations', () {
    late MockXof sutMock;

    setUp(() {
      sutMock = MockXof();
    });

    testValidateOutLen((value) => sutMock.validateOutLen(value));

    testData<(int, bool)>(
      'validateDomain asserts if value is not in range',
      const [
        (0x01, false),
        (0x40, false),
        (0x7F, false),
        (0x00, true),
        (-1, true),
        (0x80, true),
      ],
      (fixture) {
        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sutMock.validateDomain(fixture.$1),
          fixture.$2 ? exceptionMatcher : isNot(exceptionMatcher),
        );
      },
    );
  });

  group('XofConsumerValidations', () {
    // ignore: close_sinks for testing
    late MockXofConsumer sutMock;

    setUp(() {
      sutMock = MockXofConsumer();
    });

    testValidateOutLen((value) => sutMock.validateOutLen(value));
  });
}
