// ignore_for_file: invalid_use_of_protected_member, unnecessary_lambdas
import 'dart:async';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/helpers/secret_stream/pull/secret_stream_pull_transformer.dart';
import 'package:sodium/src/api/secret_stream.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:test/test.dart';

import '../../../../../secure_key_fake.dart';

class MockEventSink extends Mock
    implements EventSink<SecretStreamPlainMessage> {}

class MockSecureKey extends Mock implements SecureKey {}

class MockSecretStreamPullTransformerSink extends Mock
    implements SecretStreamPullTransformerSink<int> {}

class MockSecretStreamPullTransformer extends Mock
    implements SecretStreamPullTransformer<int> {}

class SutSecretStreamPullTransformerSink
    extends SecretStreamPullTransformerSink<int> {
  final MockSecretStreamPullTransformerSink mock;

  // ignore: avoid_positional_boolean_parameters
  SutSecretStreamPullTransformerSink(this.mock, bool requireFinalized)
    : super(requireFinalized);

  @override
  int get headerBytes => mock.headerBytes;

  @override
  int initialize(SecureKey key, Uint8List header) =>
      mock.initialize(key, header);

  @override
  void rekey(int cryptoState) => mock.rekey(cryptoState);

  @override
  SecretStreamPlainMessage decryptMessage(
    int cryptoState,
    SecretStreamCipherMessage event,
  ) => mock.decryptMessage(cryptoState, event);

  @override
  void disposeState(int cryptoState) => mock.disposeState(cryptoState);
}

class SutSecretStreamPullTransformer extends SecretStreamPullTransformer<int> {
  final MockSecretStreamPullTransformer mock;

  SutSecretStreamPullTransformer(
    this.mock,
    SecureKey key,
    // ignore: avoid_positional_boolean_parameters
    bool requireFinalized,
  ) : super(key, requireFinalized);

  @override
  SecretStreamPullTransformerSink<int> createSink(bool requireFinalized) =>
      mock.createSink(requireFinalized);
}

void main() {
  final key = SecureKeyFake(List.generate(5, (index) => index + 10));

  group('SecretStreamPullTransformerSink', () {
    const headerBytes = 10;
    const state = 32;

    final mockSink = MockEventSink();
    final mockSut = MockSecretStreamPullTransformerSink();

    late SutSecretStreamPullTransformerSink sut;

    setUpAll(() {
      registerFallbackValue(Uint8List(0));
      registerFallbackValue(SecureKeyFake.empty(0));
      registerFallbackValue(SecretStreamCipherMessage(Uint8List(0)));
      registerFallbackValue(SecretStreamPlainMessage(Uint8List(0)));
      registerFallbackValue(MockEventSink());
    });

    setUp(() {
      reset(mockSink);
      reset(mockSut);

      when(() => mockSut.headerBytes).thenReturn(headerBytes);
      when(() => mockSut.initialize(any(), any())).thenReturn(state);
      when(
        () => mockSut.decryptMessage(any(), any()),
      ).thenReturn(SecretStreamPlainMessage(Uint8List(0)));

      sut = SutSecretStreamPullTransformerSink(mockSut, true);
    });

    tearDown(() {
      verifyNever(() => mockSink.addError(any(), any()));
    });

    group('uninitialized', () {
      test('init moves to preInit state and copies key', () {
        final mockKey = MockSecureKey();
        when(() => mockKey.copy()).thenReturn(key);

        sut.init(mockSink, mockKey);

        expect(() => sut.init(mockSink, key), throwsA(isA<StateError>()));
        verify(() => mockKey.copy());
      });

      test('triggerRekey throws StateError', () {
        expect(() => sut.triggerRekey(), throwsA(isA<StateError>()));
      });

      test('add throws StateError', () {
        expect(
          () => sut.add(SecretStreamCipherMessage(Uint8List(0))),
          throwsA(isA<StateError>()),
        );
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

    group('preInit', () {
      final mockKey = MockSecureKey();

      setUp(() {
        reset(mockKey);
        when(() => mockKey.copy()).thenReturn(mockKey);

        sut.init(mockSink, mockKey);

        verifyNever(() => mockSink.addError(any(), any()));
        clearInteractions(mockSut);
        clearInteractions(mockSink);
        clearInteractions(mockKey);
      });

      group('add', () {
        test(
          'adds error if message has wrong length and moves to finalized',
          () {
            sut.add(SecretStreamCipherMessage(Uint8List(headerBytes + 5)));

            verify(
              () => mockSink.addError(
                any(that: isA<InvalidHeaderException>()),
                any(),
              ),
            );

            expect(
              () => sut.add(SecretStreamCipherMessage(Uint8List(0))),
              throwsA(isA<StateError>()),
            );
            verify(() => mockKey.dispose());
          },
        );

        test('calls initialize with key and received header', () {
          final header = SecretStreamCipherMessage(
            Uint8List.fromList(List.generate(headerBytes, (index) => index)),
          );

          sut.add(header);

          verify(() => mockSut.initialize(mockKey, header.message));
          verify(() => mockKey.dispose());
        });

        test('moves to postInit state', () {
          sut
            ..add(SecretStreamCipherMessage(Uint8List(headerBytes)))
            ..add(SecretStreamCipherMessage(Uint8List(0)));

          verify(() => mockSut.initialize(any(), any())).called(1);
          verify(() => mockKey.dispose());
        });
      });

      test('init throws StateError', () {
        expect(() => sut.init(mockSink, key), throwsA(isA<StateError>()));
      });

      test('triggerRekey throws StateError', () {
        expect(() => sut.triggerRekey(), throwsA(isA<StateError>()));
      });

      test('addError adds error to stream', () {
        sut.addError(Exception(), StackTrace.empty);

        verify(() => mockSink.addError(any(that: isA<Exception>()), any()));
      });

      test('close moves to closed state and closes key and sink', () {
        sut.close();

        verify(() => mockKey.dispose());
        verify(() => mockSink.close());

        expect(
          () => sut.add(SecretStreamCipherMessage(Uint8List(0))),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('postInit', () {
      setUp(() {
        sut
          ..init(mockSink, key)
          ..add(SecretStreamCipherMessage(Uint8List(headerBytes)));

        verifyNever(() => mockSink.addError(any(), any()));
        clearInteractions(mockSut);
        clearInteractions(mockSink);
      });

      group('add', () {
        test('decrypts received message', () {
          final cipher = SecretStreamCipherMessage(
            Uint8List.fromList(List.generate(20, (index) => index ~/ 2)),
          );

          sut.add(cipher);

          verify(() => mockSut.decryptMessage(state, cipher));
        });

        test('adds decrypted message to sink', () {
          final plain = SecretStreamPlainMessage(
            Uint8List.fromList(List.generate(3, (index) => index * 10)),
          );
          when(() => mockSut.decryptMessage(any(), any())).thenReturn(plain);

          sut.add(SecretStreamCipherMessage(Uint8List(0)));

          verify(() => mockSink.add(plain));
        });

        test(
          'moves to finalized and disposes state if message is final message',
          () {
            final plain = SecretStreamPlainMessage(
              Uint8List(5),
              tag: SecretStreamMessageTag.finalPush,
            );
            when(() => mockSut.decryptMessage(any(), any())).thenReturn(plain);

            sut.add(SecretStreamCipherMessage(Uint8List(0)));

            verify(() => mockSut.disposeState(state));

            expect(
              () => sut.add(SecretStreamCipherMessage(Uint8List(0))),
              throwsA(isA<StateError>()),
            );
          },
        );

        test('adds error to stream on an error', () {
          when(
            () => mockSut.decryptMessage(any(), any()),
          ).thenThrow(Exception());

          sut.add(SecretStreamCipherMessage(Uint8List(0)));

          verify(() => mockSink.addError(any(that: isA<Exception>()), any()));
        });
      });

      test('triggerRekey triggers a rekey', () {
        sut.triggerRekey();

        verify(() => mockSut.rekey(state));
      });

      test('init throws StateError', () {
        expect(() => sut.init(mockSink, key), throwsA(isA<StateError>()));
      });

      test('addError adds error to stream', () {
        sut.addError(Exception(), StackTrace.empty);

        verify(() => mockSink.addError(any(that: isA<Exception>()), any()));
      });

      group('close', () {
        test(
          'not req finalized moves to closed state and closes state and sink',
          () {
            sut =
                SutSecretStreamPullTransformerSink(mockSut, false)
                  ..init(mockSink, key)
                  ..add(SecretStreamCipherMessage(Uint8List(headerBytes)));
            verifyNever(() => mockSink.addError(any(), any()));
            clearInteractions(mockSut);
            clearInteractions(mockSink);

            sut.close();

            verify(() => mockSut.disposeState(state));
            verify(() => mockSink.close());

            expect(
              () => sut.add(SecretStreamCipherMessage(Uint8List(0))),
              throwsA(isA<StateError>()),
            );
          },
        );

        test('req finalize adds error and then closes the rest', () {
          sut.close();

          verifyInOrder([
            () =>
                mockSink.addError(any(that: isA<StreamClosedEarlyException>())),
            () => mockSut.disposeState(state),
            () => mockSink.close(),
          ]);

          expect(
            () => sut.add(SecretStreamCipherMessage(Uint8List(0))),
            throwsA(isA<StateError>()),
          );
        });
      });
    });

    group('finalized', () {
      setUp(() {
        when(() => mockSut.decryptMessage(any(), any())).thenReturn(
          SecretStreamPlainMessage(
            Uint8List(0),
            tag: SecretStreamMessageTag.finalPush,
          ),
        );

        sut
          ..init(mockSink, key)
          ..add(SecretStreamCipherMessage(Uint8List(headerBytes)))
          ..add(SecretStreamCipherMessage(Uint8List(0)));

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
          () => sut.add(SecretStreamCipherMessage(Uint8List(0))),
          throwsA(isA<StateError>()),
        );
      });

      test('addError adds error to stream', () {
        sut.addError(Exception(), StackTrace.empty);

        verify(() => mockSink.addError(any(that: isA<Exception>()), any()));
      });

      test('close closes sink and enters closed state', () {
        sut.close();

        verify(() => mockSink.close());

        sut.close();
        verifyNoMoreInteractions(mockSink);
        verifyNoMoreInteractions(mockSut);
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
          () => sut.add(SecretStreamCipherMessage(Uint8List(0))),
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

  group('SecretStreamPullTransformer', () {
    final mockSut = MockSecretStreamPullTransformer();
    final mockSink = MockSecretStreamPullTransformerSink();

    late SutSecretStreamPullTransformer sut;

    setUp(() {
      reset(mockSut);
      reset(mockSink);

      when(() => mockSut.createSink(any())).thenReturn(mockSink);

      sut = SutSecretStreamPullTransformer(mockSut, key, true);
    });

    group('bind', () {
      test('creates a sink', () {
        sut.bind(const Stream.empty());

        verify(() => mockSut.createSink(true));
      });

      test('creates a secret push stream that rekeys the sink', () {
        sut.bind(const Stream.empty()).rekey();

        verify(() => mockSink.triggerRekey());
      });

      test('creates secret pull stream that pipes items through the sink', () {
        late EventSink<SecretStreamPlainMessage> transformerSink;
        when(() => mockSink.init(any(), any())).thenAnswer((i) {
          transformerSink =
              i.positionalArguments.first
                  as EventSink<SecretStreamPlainMessage>;
        });
        when(() => mockSink.add(any())).thenAnswer((i) {
          final event =
              i.positionalArguments.first as SecretStreamCipherMessage;
          transformerSink.add(SecretStreamPlainMessage(event.message));
        });
        when(() => mockSink.close()).thenAnswer((i) => transformerSink.close());

        final data = List.generate(
          5,
          (index) => SecretStreamCipherMessage(Uint8List(index)),
        );

        final res = sut.bind(Stream.fromIterable(data));

        expect(
          res,
          emitsInOrder(
            data.map<SecretStreamPlainMessage>(
              (e) => SecretStreamPlainMessage(e.message),
            ),
          ),
        );
        verify(() => mockSink.init(any(), key));
      });
    });

    test('cast returns transformed instance', () {
      final castTransformer =
          sut.cast<SecretStreamPlainMessage, SecretStreamCipherMessage>();
      expect(castTransformer, isNotNull);
    });
  });
}
