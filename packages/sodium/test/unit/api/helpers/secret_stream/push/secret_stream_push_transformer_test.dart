// ignore_for_file: unnecessary_lambdas for mocking
import 'dart:async';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/helpers/secret_stream/push/init_push_result.dart';
import 'package:sodium/src/api/helpers/secret_stream/push/secret_stream_push_transformer.dart';
import 'package:sodium/src/api/secret_stream.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:test/test.dart';

import '../../../../../secure_key_fake.dart';

class MockEventSink extends Mock
    implements EventSink<SecretStreamCipherMessage> {}

class MockSecretStreamPushTransformerSink extends Mock
    implements SecretStreamPushTransformerSink<int> {}

class MockSecretStreamPushTransformer extends Mock
    implements SecretStreamPushTransformer<int> {}

class SutSecretStreamPushTransformerSink
    extends SecretStreamPushTransformerSink<int> {
  final MockSecretStreamPushTransformerSink mock;

  SutSecretStreamPushTransformerSink(this.mock);

  @override
  InitPushResult<int> initialize(SecureKey key) => mock.initialize(key);

  @override
  void rekey(int cryptoState) => mock.rekey(cryptoState);

  @override
  SecretStreamCipherMessage encryptMessage(
    int cryptoState,
    SecretStreamPlainMessage event,
  ) => mock.encryptMessage(cryptoState, event);

  @override
  void disposeState(int cryptoState) => mock.disposeState(cryptoState);
}

class SutSecretStreamPushTransformer extends SecretStreamPushTransformer<int> {
  final MockSecretStreamPushTransformer mock;

  const SutSecretStreamPushTransformer(this.mock, SecureKey key) : super(key);

  @override
  SecretStreamPushTransformerSink<int> createSink() => mock.createSink();
}

void main() {
  final key = SecureKeyFake(List.generate(5, (index) => index + 10));

  group('SecretStreamPushTransformerSink', () {
    const state = 13;

    final mockSink = MockEventSink();
    final mockSut = MockSecretStreamPushTransformerSink();

    late SutSecretStreamPushTransformerSink sut;

    setUpAll(() {
      registerFallbackValue(SecureKeyFake.empty(0));
      registerFallbackValue(SecretStreamCipherMessage(Uint8List(0)));
      registerFallbackValue(SecretStreamPlainMessage(Uint8List(0)));
      registerFallbackValue(MockEventSink());
    });

    setUp(() {
      reset(mockSink);
      reset(mockSut);

      when(
        () => mockSut.initialize(any()),
      ).thenReturn(InitPushResult(header: Uint8List(3), state: state));
      when(
        () => mockSut.encryptMessage(any(), any()),
      ).thenReturn(SecretStreamCipherMessage(Uint8List(0)));

      sut = SutSecretStreamPushTransformerSink(mockSut);
    });

    tearDown(() {
      verifyNever(() => mockSink.addError(any(), any()));
    });

    group('uninitialized', () {
      group('init', () {
        test('calls virtual initialize', () {
          sut.init(mockSink, key);

          verify(() => mockSut.initialize(key));
        });

        test(
          'adds created header to stream after first message is processed',
          () {
            final initRes = InitPushResult<int>(
              header: Uint8List.fromList(List.generate(10, (index) => index)),
              state: 0,
            );
            when(() => mockSut.initialize(any())).thenReturn(initRes);

            sut.init(mockSink, key);

            verifyNever(() => mockSink.add(any()));

            sut.add(SecretStreamPlainMessage(Uint8List(0)));

            final message =
                verifyInOrder([
                      () => mockSink.add(captureAny()),
                      () => mockSink.add(
                        any(that: isA<SecretStreamCipherMessage>()),
                      ),
                    ]).captured[0].single
                    as SecretStreamCipherMessage;

            expect(message.message, initRes.header);
            expect(message.additionalData, isNull);

            verifyNoMoreInteractions(mockSink);
          },
        );

        test('moves to initialized state after succeeding', () {
          sut.init(mockSink, key);

          expect(() => sut.init(mockSink, key), throwsA(isA<StateError>()));
        });

        test('logs error on an exception', () {
          when(() => mockSut.initialize(any())).thenThrow(Exception());

          sut.init(mockSink, key);

          verify(() => mockSink.addError(any(that: isA<Exception>()), any()));
          verifyNoMoreInteractions(mockSink);
        });

        test('moves to finalized state after failing', () {
          when(() => mockSut.initialize(any())).thenThrow(Exception());

          sut.init(mockSink, key);

          verify(() => mockSink.addError(any(that: isA<Exception>()), any()));

          expect(() => sut.init(mockSink, key), throwsA(isA<StateError>()));
        });
      });

      test('triggerRekey throws StateError', () {
        expect(() => sut.triggerRekey(), throwsA(isA<StateError>()));
      });

      test('add throws StateError', () {
        expect(() => sut.triggerRekey(), throwsA(isA<StateError>()));
      });

      test('addError does nothing', () {
        sut.addError(Exception(), StackTrace.empty);
        verifyZeroInteractions(mockSink);
      });

      test('close moves to closed state', () {
        sut.close();

        expect(() => sut.init(mockSink, key), throwsA(isA<StateError>()));
      });
    });

    group('initialized', () {
      setUp(() {
        sut.init(mockSink, key);

        verifyNever(() => mockSink.addError(any(), any()));
        clearInteractions(mockSut);
        clearInteractions(mockSink);
      });

      test('triggerRekey triggers a rekey', () {
        sut.triggerRekey();

        verify(() => mockSut.rekey(state));
      });

      group('add', () {
        test('encrypts received data with initialized state', () {
          final message = SecretStreamPlainMessage(
            Uint8List.fromList(List.generate(3, (index) => index)),
            additionalData: Uint8List.fromList(
              List.generate(10, (index) => index + 10),
            ),
            tag: SecretStreamMessageTag.push,
          );

          sut.add(message);

          verify(() => mockSut.encryptMessage(state, message));
        });

        test('adds the encrypted data to the stream', () {
          final cipher = SecretStreamCipherMessage(
            Uint8List.fromList(List.generate(7, (index) => index)),
            additionalData: Uint8List.fromList(
              List.generate(5, (index) => index - 5),
            ),
          );
          when(() => mockSut.encryptMessage(any(), any())).thenReturn(cipher);

          sut.add(SecretStreamPlainMessage(Uint8List(0)));

          verify(() => mockSink.add(cipher));
        });

        test('adds header to stream once', () {
          final cipher = SecretStreamCipherMessage(
            Uint8List.fromList(List.generate(7, (index) => index)),
            additionalData: Uint8List.fromList(
              List.generate(5, (index) => index - 5),
            ),
          );
          when(() => mockSut.encryptMessage(any(), any())).thenReturn(cipher);

          sut
            ..add(SecretStreamPlainMessage(Uint8List(3)))
            ..add(SecretStreamPlainMessage(Uint8List(4)));

          verifyInOrder([
            () => mockSink.add(SecretStreamCipherMessage(Uint8List(3))),
            () => mockSink.add(cipher),
            () => mockSink.add(cipher),
          ]);
          verifyNoMoreInteractions(mockSink);
        });

        test('moves to finalized state for final push messages', () {
          sut.add(
            SecretStreamPlainMessage(
              Uint8List(0),
              tag: SecretStreamMessageTag.finalPush,
            ),
          );

          verify(() => mockSut.disposeState(state));

          expect(
            () => sut.add(SecretStreamPlainMessage(Uint8List(0))),
            throwsA(isA<StateError>()),
          );
        });

        test('adds error in case of an exception', () {
          when(
            () => mockSut.encryptMessage(any(), any()),
          ).thenThrow(Exception());

          sut.add(SecretStreamPlainMessage(Uint8List(0)));

          verifyInOrder([
            () => mockSink.add(SecretStreamCipherMessage(Uint8List(3))),
            () => mockSink.addError(any(that: isA<Exception>()), any()),
          ]);
          verifyNoMoreInteractions(mockSink);
        });
      });

      test('init throws StateError', () {
        expect(() => sut.init(mockSink, key), throwsA(isA<StateError>()));
      });

      test('addError adds error to stream', () {
        sut.addError(Exception(), StackTrace.empty);

        verify(() => mockSink.addError(any(that: isA<Exception>()), any()));
        verifyNoMoreInteractions(mockSink);
      });

      group('close', () {
        group('withoutFinalize', () {
          test('disposes state and closes sink', () {
            sut.close(withFinalize: false);

            verify(() => mockSut.disposeState(state));
            verify(() => mockSink.close());
            verifyNoMoreInteractions(mockSink);
          });

          test('moves to closed state', () {
            sut.close(withFinalize: false);

            expect(
              () => sut.add(SecretStreamPlainMessage(Uint8List(0))),
              throwsA(isA<StateError>()),
            );
          });
        });

        group('withFinalize', () {
          test('sends finalizing cipher message, '
              'then disposes state and closes stream', () {
            sut.add(SecretStreamPlainMessage(Uint8List(0)));
            clearInteractions(mockSink);

            sut.close();

            verifyInOrder([
              () => mockSut.encryptMessage(
                state,
                SecretStreamPlainMessage(
                  Uint8List(0),
                  tag: SecretStreamMessageTag.finalPush,
                ),
              ),
              () => mockSink.add(any()),
              () => mockSut.disposeState(state),
              () => mockSink.close(),
            ]);
            verifyNoMoreInteractions(mockSink);
          });

          test('sends header if no other messages where sent, '
              'then disposes state and closes stream', () {
            sut.close();

            verifyInOrder([
              () => mockSink.add(SecretStreamCipherMessage(Uint8List(3))),
              () => mockSut.encryptMessage(
                state,
                SecretStreamPlainMessage(
                  Uint8List(0),
                  tag: SecretStreamMessageTag.finalPush,
                ),
              ),
              () => mockSink.add(any()),
              () => mockSut.disposeState(state),
              () => mockSink.close(),
            ]);
            verifyNoMoreInteractions(mockSink);
          });

          test('moves to closed state', () {
            sut.close(withFinalize: false);

            expect(
              () => sut.add(SecretStreamPlainMessage(Uint8List(0))),
              throwsA(isA<StateError>()),
            );
          });
        });
      });
    });

    group('finalized', () {
      setUp(() {
        sut
          ..init(mockSink, key)
          ..add(
            SecretStreamPlainMessage(
              Uint8List(0),
              tag: SecretStreamMessageTag.finalPush,
            ),
          );

        verifyNever(() => mockSink.addError(any(), any()));
        clearInteractions(mockSut);
        clearInteractions(mockSink);
      });

      test('close closes sink and enters closed state', () {
        sut.close();

        verify(() => mockSink.close());

        sut.close();
        verifyNoMoreInteractions(mockSink);
        verifyNoMoreInteractions(mockSut);
      });

      test('init throws StateError', () {
        expect(() => sut.init(mockSink, key), throwsA(isA<StateError>()));
      });

      test('triggerRekey throws StateError', () {
        expect(() => sut.triggerRekey(), throwsA(isA<StateError>()));
      });

      test('add throws StateError', () {
        expect(
          () => sut.add(SecretStreamPlainMessage(Uint8List(0))),
          throwsA(isA<StateError>()),
        );
      });

      test('addError adds error to stream', () {
        sut.addError(Exception(), StackTrace.empty);

        verify(() => mockSink.addError(any(that: isA<Exception>()), any()));
      });
    });

    group('closed', () {
      setUp(() {
        sut.close();

        verifyNever(() => mockSink.addError(any(), any()));
        clearInteractions(mockSut);
        clearInteractions(mockSink);
      });

      test('init throws StateError', () {
        expect(() => sut.init(mockSink, key), throwsA(isA<StateError>()));
      });

      test('triggerRekey throws StateError', () {
        expect(() => sut.triggerRekey(), throwsA(isA<StateError>()));
      });

      test('add throws StateError', () {
        expect(
          () => sut.add(SecretStreamPlainMessage(Uint8List(0))),
          throwsA(isA<StateError>()),
        );
      });

      test('addError does nothing', () {
        sut.addError(Exception(), StackTrace.empty);
        verifyZeroInteractions(mockSink);
      });

      test('close does nothing', () {
        sut.addError(Exception(), StackTrace.empty);
        verifyZeroInteractions(mockSink);
        verifyZeroInteractions(mockSut);
      });
    });
  });

  group('SecretStreamPushTransformer', () {
    final mockSut = MockSecretStreamPushTransformer();
    final mockSink = MockSecretStreamPushTransformerSink();

    late SutSecretStreamPushTransformer sut;

    setUp(() {
      reset(mockSut);
      reset(mockSink);

      when(() => mockSut.createSink()).thenReturn(mockSink);

      sut = SutSecretStreamPushTransformer(mockSut, key);
    });

    group('bind', () {
      test('creates a sink', () {
        sut.bind(const Stream.empty());

        verify(() => mockSut.createSink());
      });

      test('creates a secret push stream that rekeys the sink', () {
        sut.bind(const Stream.empty()).rekey();

        verify(() => mockSink.triggerRekey());
      });

      test('creates secret push stream that pipes items through the sink', () {
        late EventSink<SecretStreamCipherMessage> transformerSink;
        when(() => mockSink.init(any(), any())).thenAnswer((i) {
          transformerSink =
              i.positionalArguments.first
                  as EventSink<SecretStreamCipherMessage>;
        });
        when(() => mockSink.add(any())).thenAnswer((i) {
          final event = i.positionalArguments.first as SecretStreamPlainMessage;
          transformerSink.add(SecretStreamCipherMessage(event.message));
        });
        when(() => mockSink.close()).thenAnswer((i) => transformerSink.close());

        final data = List.generate(
          5,
          (index) => SecretStreamPlainMessage(Uint8List(index)),
        );

        final res = sut.bind(Stream.fromIterable(data));

        expect(
          res,
          emitsInOrder(
            data.map<SecretStreamCipherMessage>(
              (e) => SecretStreamCipherMessage(e.message),
            ),
          ),
        );
        verify(() => mockSink.init(any(), key));
      });
    });

    test('cast returns transformed instance', () {
      final castTransformer = sut
          .cast<SecretStreamPlainMessage, SecretStreamCipherMessage>();
      expect(castTransformer, isNotNull);
    });
  });
}
