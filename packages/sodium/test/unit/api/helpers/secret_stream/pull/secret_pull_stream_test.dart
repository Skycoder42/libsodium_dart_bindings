// ignore_for_file: unnecessary_lambdas for mocking

import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/helpers/secret_stream/pull/secret_pull_stream.dart';
import 'package:sodium/src/api/helpers/secret_stream/pull/secret_stream_pull_transformer.dart';
import 'package:sodium/src/api/secret_stream.dart';
import 'package:test/test.dart';

class MockSecretStreamPullTransformerSink extends Mock
    implements SecretStreamPullTransformerSink {}

class MockStream extends Mock implements Stream<SecretStreamPlainMessage> {}

class FakeStreamSubscription extends Fake
    implements StreamSubscription<SecretStreamPlainMessage> {}

void main() {
  final mockSink = MockSecretStreamPullTransformerSink();
  final mockStream = MockStream();

  late SecretPullStream sut;

  setUp(() {
    reset(mockSink);
    reset(mockStream);

    sut = SecretPullStream(mockSink, mockStream);
  });

  test('listen forwards listen to stream', () {
    final fakeSub = FakeStreamSubscription();
    when(
      () => mockStream.listen(
        any(),
        onDone: any(named: 'onDone'),
        onError: any(named: 'onError'),
        cancelOnError: any(named: 'cancelOnError'),
      ),
    ).thenReturn(fakeSub);

    void onEvent(SecretStreamPlainMessage event) {}
    void onDone() {}
    void onError(Object e) {}
    final sub = sut.listen(
      onEvent,
      onDone: onDone,
      onError: onError,
      cancelOnError: true,
    );

    expect(sub, fakeSub);
    verify(
      () => mockStream.listen(
        onEvent,
        onDone: onDone,
        onError: onError,
        cancelOnError: true,
      ),
    );
  });

  test('rekey call triggerRekey on sink', () {
    sut.rekey();

    verify(() => mockSink.triggerRekey());
  });
}
