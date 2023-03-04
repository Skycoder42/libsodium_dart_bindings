// ignore_for_file: unnecessary_lambdas

import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/helpers/secret_stream/push/secret_push_stream.dart';
import 'package:sodium/src/api/helpers/secret_stream/push/secret_stream_push_transformer.dart';
import 'package:sodium/src/api/secret_stream.dart';
import 'package:test/test.dart';

class MockSecretStreamPushTransformerSink extends Mock
    implements SecretStreamPushTransformerSink {}

class MockStream extends Mock implements Stream<SecretStreamCipherMessage> {}

class FakeStreamSubscription extends Fake
    implements StreamSubscription<SecretStreamCipherMessage> {}

void main() {
  final mockSink = MockSecretStreamPushTransformerSink();
  final mockStream = MockStream();

  late SecretPushStream sut;

  setUp(() {
    reset(mockSink);
    reset(mockStream);

    sut = SecretPushStream(mockSink, mockStream);
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

    void onEvent(SecretStreamCipherMessage event) {}
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
