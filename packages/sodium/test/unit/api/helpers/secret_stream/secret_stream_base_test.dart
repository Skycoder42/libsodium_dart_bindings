import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/helpers/secret_stream/pull/secret_pull_stream.dart';
import 'package:sodium/src/api/helpers/secret_stream/pull/secret_stream_pull_transformer.dart';
import 'package:sodium/src/api/helpers/secret_stream/push/secret_push_stream.dart';
import 'package:sodium/src/api/helpers/secret_stream/push/secret_stream_push_transformer.dart';
import 'package:sodium/src/api/helpers/secret_stream/secret_stream_base.dart';
import 'package:sodium/src/api/secret_stream.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:test/test.dart';

import '../../../../secure_key_fake.dart';

class SecretStreamMock extends Mock
    with SecretStreamBase
    implements SecretStream {}

class MockSecretExStreamTransformer<TIn, TOut> extends Mock
    implements SecretExStreamTransformer<TIn, TOut> {}

class SecretStreamPushTransformerSinkFake extends Fake
    implements SecretStreamPushTransformerSink {}

class SecretStreamPullTransformerSinkFake extends Fake
    implements SecretStreamPullTransformerSink {}

void main() {
  final mockPushTransformer = MockSecretExStreamTransformer<
      SecretStreamPlainMessage, SecretStreamCipherMessage>();
  final mockPullTransformer = MockSecretExStreamTransformer<
      SecretStreamCipherMessage, SecretStreamPlainMessage>();

  late SecretStreamMock sutMock;

  setUpAll(() {
    registerFallbackValue<Stream<SecretStreamPlainMessage>>(
      const Stream.empty(),
    );
    registerFallbackValue<Stream<SecretStreamCipherMessage>>(
      const Stream.empty(),
    );
    registerFallbackValue<SecureKey>(SecureKeyFake.empty(0));
  });

  void mockPush(Iterable<SecretStreamCipherMessage> data) =>
      when(() => mockPushTransformer.bind(any())).thenAnswer(
        (i) => SecretPushStream(
          SecretStreamPushTransformerSinkFake(),
          Stream.fromIterable(data),
        ),
      );

  void mockPull(Iterable<SecretStreamPlainMessage> data) =>
      when(() => mockPullTransformer.bind(any())).thenAnswer(
        (i) => SecretPullStream(
          SecretStreamPullTransformerSinkFake(),
          Stream.fromIterable(data),
        ),
      );

  setUp(() {
    reset(mockPushTransformer);
    reset(mockPullTransformer);

    mockPush(const []);
    mockPull(const []);

    sutMock = SecretStreamMock();

    when(() => sutMock.createPushEx(any())).thenReturn(mockPushTransformer);
    when(
      () => sutMock.createPullEx(
        any(),
        requireFinalized: any(named: 'requireFinalized'),
      ),
    ).thenReturn(mockPullTransformer);
  });

  test('pushEx binds to transformer created by createPushEx', () {
    final key = SecureKeyFake.empty(10);
    final messageStream = Stream.fromIterable([
      SecretStreamPlainMessage(Uint8List(5)),
      SecretStreamPlainMessage(
        Uint8List(10),
        additionalData: Uint8List(3),
      ),
      SecretStreamPlainMessage(
        Uint8List(5),
        tag: SecretStreamMessageTag.finalPush,
      ),
    ]);
    final resultData = [
      SecretStreamCipherMessage(Uint8List(3)),
      SecretStreamCipherMessage(
        Uint8List(5),
        additionalData: Uint8List(7),
      ),
    ];

    mockPush(resultData);

    final res = sutMock.pushEx(
      messageStream: messageStream,
      key: key,
    );

    expect(res, emitsInOrder(resultData));

    verify(() => sutMock.createPushEx(key));
    verify(() => mockPushTransformer.bind(messageStream));
  });

  test('pullEx binds to transformer created by createPullEx', () {
    final key = SecureKeyFake.empty(10);
    final cipherStream = Stream.fromIterable([
      SecretStreamCipherMessage(Uint8List(3)),
      SecretStreamCipherMessage(
        Uint8List(5),
        additionalData: Uint8List(7),
      ),
    ]);
    final resultData = [
      SecretStreamPlainMessage(Uint8List(5)),
      SecretStreamPlainMessage(
        Uint8List(10),
        additionalData: Uint8List(3),
      ),
      SecretStreamPlainMessage(
        Uint8List(5),
        tag: SecretStreamMessageTag.finalPush,
      ),
    ];

    mockPull(resultData);

    final res = sutMock.pullEx(
      cipherStream: cipherStream,
      key: key,
    );

    expect(res, emitsInOrder(resultData));

    verify(() => sutMock.createPullEx(key));
    verify(() => mockPullTransformer.bind(cipherStream));
  });

  test('push creates transformer that wraps createPushEx', () {
    final key = SecureKeyFake.empty(10);
    final messageData = [
      Uint8List(5),
      Uint8List(0),
      Uint8List(10),
      Uint8List(5),
    ];
    final messageDataEx = [
      SecretStreamPlainMessage(Uint8List(5)),
      SecretStreamPlainMessage(Uint8List(10)),
      SecretStreamPlainMessage(Uint8List(5)),
    ];
    final resultData = [
      Uint8List(3),
      Uint8List(0),
      Uint8List(5),
    ];
    final resultDataEx = [
      SecretStreamCipherMessage(Uint8List(3)),
      SecretStreamCipherMessage(Uint8List(0)),
      SecretStreamCipherMessage(Uint8List(5)),
    ];

    mockPush(resultDataEx);

    final res = sutMock.push(
      messageStream: Stream.fromIterable(messageData),
      key: key,
    );

    expect(res, emitsInOrder(resultData));

    verify(() => sutMock.createPushEx(key));
    verify(
      () => mockPushTransformer.bind(
        any(that: emitsInOrder(messageDataEx)),
      ),
    );
  });

  test('pull creates transformer that wraps createPullEx', () {
    final key = SecureKeyFake.empty(10);
    final cipherData = [
      Uint8List(5),
      Uint8List(0),
      Uint8List(10),
      Uint8List(5),
    ];
    final cipherDataEx = [
      SecretStreamCipherMessage(Uint8List(5)),
      SecretStreamCipherMessage(Uint8List(0)),
      SecretStreamCipherMessage(Uint8List(10)),
      SecretStreamCipherMessage(Uint8List(5)),
    ];
    final resultData = [
      Uint8List(3),
      Uint8List(5),
    ];
    final resultDataEx = [
      SecretStreamPlainMessage(Uint8List(3)),
      SecretStreamPlainMessage(Uint8List(0)),
      SecretStreamPlainMessage(Uint8List(5)),
    ];

    mockPull(resultDataEx);

    final res = sutMock.pull(
      cipherStream: Stream.fromIterable(cipherData),
      key: key,
    );

    expect(res, emitsInOrder(resultData));

    verify(() => sutMock.createPullEx(key));
    verify(
      () => mockPullTransformer.bind(
        any(that: emitsInOrder(cipherDataEx)),
      ),
    );
  });
}
