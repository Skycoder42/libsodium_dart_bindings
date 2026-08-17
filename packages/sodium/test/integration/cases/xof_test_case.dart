import 'dart:typed_data';

import '../test_case.dart';

class XofTestCase extends TestCase {
  new(super._runner);

  @override
  String get name => 'xof';

  @override
  void setupTests() {
    group('shake128', () {
      test('constants return correct values', (sodium) {
        final sut = sodium.crypto.xofShake128;

        expect(sut.blockBytes, 168, reason: 'blockBytes');
        expect(sut.stateBytes, 256, reason: 'stateBytes');
        expect(sut.domainStandard, 0x1F, reason: 'domainStandard');
      });

      group('call', () {
        test('generates outputs with identical prefix for identical input', (
          sodium,
        ) {
          final sut = sodium.crypto.xofShake128;

          final message = Uint8List.fromList(
            List.generate(64, (index) => index + 32),
          );
          printOnFailure('message: $message');

          final hash1 = sut(message: message, outLen: 32);
          final hash2 = sut(message: message, outLen: 64);

          printOnFailure('hash1: $hash1');
          printOnFailure('hash2: $hash2');

          expect(hash1, hasLength(32));
          expect(hash2, hasLength(64));

          expect(hash1, hash2.sublist(0, 32));
        });

        test('generates different output for different data', (sodium) {
          final sut = sodium.crypto.xofShake128;

          final message1 = Uint8List.fromList(
            List.generate(64, (index) => index + 32),
          );
          final message2 = Uint8List.fromList(
            List.generate(64, (index) => index - 32),
          );

          printOnFailure('message1: $message1');
          printOnFailure('message2: $message2');

          final hash1 = sut(message: message1, outLen: 32);
          final hash2 = sut(message: message2, outLen: 32);

          printOnFailure('hash1: $hash1');
          printOnFailure('hash2: $hash2');

          expect(hash1, hasLength(32));
          expect(hash2, hasLength(32));

          expect(hash1, isNot(hash2));
        });
      });

      group('createConsumer', () {
        test(
          'generates data with identical prefix for identical input and domain',
          (sodium) async {
            final sut = sodium.crypto.xofShake128;

            final messages = List.generate(
              10,
              (i) => Uint8List.fromList(List.generate(32, (j) => i + j)),
            );

            printOnFailure('message: $messages');

            // ignore: close_sinks closed via addStream
            final consumer1 = sut.createConsumer();
            addTearDown(consumer1.dispose);
            // ignore: close_sinks closed via addStream
            final consumer2 = sut.createConsumer();
            addTearDown(consumer2.dispose);

            await consumer1.addStream(Stream.fromIterable(messages));
            await consumer2.addStream(Stream.fromIterable(messages));

            final hash1 = consumer1.squeeze(32);
            final hash2 = consumer1.squeeze(24);
            final hash3 = consumer2.squeeze(56);

            printOnFailure('hash1: $hash1');
            printOnFailure('hash2: $hash2');
            printOnFailure('hash3: $hash3');

            expect(hash1, hasLength(32));
            expect(hash2, hasLength(24));
            expect(hash3, hasLength(56));

            expect(hash1, hash3.sublist(0, 32));
            expect(hash2, hash3.sublist(32));
          },
        );

        test('generates different data for different input or domain', (
          sodium,
        ) async {
          final sut = sodium.crypto.xofShake128;

          final messages1 = List.generate(
            10,
            (i) => Uint8List.fromList(List.generate(32, (j) => i + j)),
          );
          final messages2 = List.generate(
            15,
            (i) => Uint8List.fromList(List.generate(10, (j) => i * j)),
          );

          printOnFailure('message: $messages1');
          printOnFailure('message: $messages2');

          // ignore: close_sinks closed via addStream
          final consumer1 = sut.createConsumer();
          addTearDown(consumer1.dispose);
          // ignore: close_sinks closed via addStream
          final consumer2 = sut.createConsumer();
          addTearDown(consumer2.dispose);
          // ignore: close_sinks closed via addStream
          final consumer3 = sut.createConsumer(domain: 0x42);
          addTearDown(consumer3.dispose);

          await consumer1.addStream(Stream.fromIterable(messages1));
          await consumer2.addStream(Stream.fromIterable(messages2));
          await consumer3.addStream(Stream.fromIterable(messages1));

          final hash1 = consumer1.squeeze(32);
          final hash2 = consumer2.squeeze(32);
          final hash3 = consumer3.squeeze(32);

          printOnFailure('hash1: $hash1');
          printOnFailure('hash2: $hash2');
          printOnFailure('hash3: $hash3');

          expect(hash1, hasLength(32));
          expect(hash2, hasLength(32));
          expect(hash3, hasLength(32));

          expect(hash1, isNot(hash2));
          expect(hash2, isNot(hash3));
          expect(hash3, isNot(hash1));
        });
      });
    });

    group('shake256', () {
      test('constants return correct values', (sodium) {
        final sut = sodium.crypto.xofShake256;

        expect(sut.blockBytes, 136, reason: 'blockBytes');
        expect(sut.stateBytes, 256, reason: 'stateBytes');
        expect(sut.domainStandard, 0x1F, reason: 'domainStandard');
      });

      group('call', () {
        test('generates outputs with identical prefix for identical input', (
          sodium,
        ) {
          final sut = sodium.crypto.xofShake256;

          final message = Uint8List.fromList(
            List.generate(64, (index) => index + 32),
          );
          printOnFailure('message: $message');

          final hash1 = sut(message: message, outLen: 32);
          final hash2 = sut(message: message, outLen: 64);

          printOnFailure('hash1: $hash1');
          printOnFailure('hash2: $hash2');

          expect(hash1, hasLength(32));
          expect(hash2, hasLength(64));

          expect(hash1, hash2.sublist(0, 32));
        });

        test('generates different output for different data', (sodium) {
          final sut = sodium.crypto.xofShake256;

          final message1 = Uint8List.fromList(
            List.generate(64, (index) => index + 32),
          );
          final message2 = Uint8List.fromList(
            List.generate(64, (index) => index - 32),
          );

          printOnFailure('message1: $message1');
          printOnFailure('message2: $message2');

          final hash1 = sut(message: message1, outLen: 32);
          final hash2 = sut(message: message2, outLen: 32);

          printOnFailure('hash1: $hash1');
          printOnFailure('hash2: $hash2');

          expect(hash1, hasLength(32));
          expect(hash2, hasLength(32));

          expect(hash1, isNot(hash2));
        });
      });

      group('createConsumer', () {
        test(
          'generates data with identical prefix for identical input and domain',
          (sodium) async {
            final sut = sodium.crypto.xofShake256;

            final messages = List.generate(
              10,
              (i) => Uint8List.fromList(List.generate(32, (j) => i + j)),
            );

            printOnFailure('message: $messages');

            // ignore: close_sinks closed via addStream
            final consumer1 = sut.createConsumer();
            addTearDown(consumer1.dispose);
            // ignore: close_sinks closed via addStream
            final consumer2 = sut.createConsumer();
            addTearDown(consumer2.dispose);

            await consumer1.addStream(Stream.fromIterable(messages));
            await consumer2.addStream(Stream.fromIterable(messages));

            final hash1 = consumer1.squeeze(32);
            final hash2 = consumer1.squeeze(24);
            final hash3 = consumer2.squeeze(56);

            printOnFailure('hash1: $hash1');
            printOnFailure('hash2: $hash2');
            printOnFailure('hash3: $hash3');

            expect(hash1, hasLength(32));
            expect(hash2, hasLength(24));
            expect(hash3, hasLength(56));

            expect(hash1, hash3.sublist(0, 32));
            expect(hash2, hash3.sublist(32));
          },
        );

        test('generates different data for different input or domain', (
          sodium,
        ) async {
          final sut = sodium.crypto.xofShake256;

          final messages1 = List.generate(
            10,
            (i) => Uint8List.fromList(List.generate(32, (j) => i + j)),
          );
          final messages2 = List.generate(
            15,
            (i) => Uint8List.fromList(List.generate(10, (j) => i * j)),
          );

          printOnFailure('message: $messages1');
          printOnFailure('message: $messages2');

          // ignore: close_sinks closed via addStream
          final consumer1 = sut.createConsumer();
          addTearDown(consumer1.dispose);
          // ignore: close_sinks closed via addStream
          final consumer2 = sut.createConsumer();
          addTearDown(consumer2.dispose);
          // ignore: close_sinks closed via addStream
          final consumer3 = sut.createConsumer(domain: 0x42);
          addTearDown(consumer3.dispose);

          await consumer1.addStream(Stream.fromIterable(messages1));
          await consumer2.addStream(Stream.fromIterable(messages2));
          await consumer3.addStream(Stream.fromIterable(messages1));

          final hash1 = consumer1.squeeze(32);
          final hash2 = consumer2.squeeze(32);
          final hash3 = consumer3.squeeze(32);

          printOnFailure('hash1: $hash1');
          printOnFailure('hash2: $hash2');
          printOnFailure('hash3: $hash3');

          expect(hash1, hasLength(32));
          expect(hash2, hasLength(32));
          expect(hash3, hasLength(32));

          expect(hash1, isNot(hash2));
          expect(hash2, isNot(hash3));
          expect(hash3, isNot(hash1));
        });
      });
    });

    group('turboshake128', () {
      test('constants return correct values', (sodium) {
        final sut = sodium.crypto.xofTurboshake128;

        expect(sut.blockBytes, 168, reason: 'blockBytes');
        expect(sut.stateBytes, 256, reason: 'stateBytes');
        expect(sut.domainStandard, 0x1F, reason: 'domainStandard');
      });

      group('call', () {
        test('generates outputs with identical prefix for identical input', (
          sodium,
        ) {
          final sut = sodium.crypto.xofTurboshake128;

          final message = Uint8List.fromList(
            List.generate(64, (index) => index + 32),
          );
          printOnFailure('message: $message');

          final hash1 = sut(message: message, outLen: 32);
          final hash2 = sut(message: message, outLen: 64);

          printOnFailure('hash1: $hash1');
          printOnFailure('hash2: $hash2');

          expect(hash1, hasLength(32));
          expect(hash2, hasLength(64));

          expect(hash1, hash2.sublist(0, 32));
        });

        test('generates different output for different data', (sodium) {
          final sut = sodium.crypto.xofTurboshake128;

          final message1 = Uint8List.fromList(
            List.generate(64, (index) => index + 32),
          );
          final message2 = Uint8List.fromList(
            List.generate(64, (index) => index - 32),
          );

          printOnFailure('message1: $message1');
          printOnFailure('message2: $message2');

          final hash1 = sut(message: message1, outLen: 32);
          final hash2 = sut(message: message2, outLen: 32);

          printOnFailure('hash1: $hash1');
          printOnFailure('hash2: $hash2');

          expect(hash1, hasLength(32));
          expect(hash2, hasLength(32));

          expect(hash1, isNot(hash2));
        });
      });

      group('createConsumer', () {
        test(
          'generates data with identical prefix for identical input and domain',
          (sodium) async {
            final sut = sodium.crypto.xofTurboshake128;

            final messages = List.generate(
              10,
              (i) => Uint8List.fromList(List.generate(32, (j) => i + j)),
            );

            printOnFailure('message: $messages');

            // ignore: close_sinks closed via addStream
            final consumer1 = sut.createConsumer();
            addTearDown(consumer1.dispose);
            // ignore: close_sinks closed via addStream
            final consumer2 = sut.createConsumer();
            addTearDown(consumer2.dispose);

            await consumer1.addStream(Stream.fromIterable(messages));
            await consumer2.addStream(Stream.fromIterable(messages));

            final hash1 = consumer1.squeeze(32);
            final hash2 = consumer1.squeeze(24);
            final hash3 = consumer2.squeeze(56);

            printOnFailure('hash1: $hash1');
            printOnFailure('hash2: $hash2');
            printOnFailure('hash3: $hash3');

            expect(hash1, hasLength(32));
            expect(hash2, hasLength(24));
            expect(hash3, hasLength(56));

            expect(hash1, hash3.sublist(0, 32));
            expect(hash2, hash3.sublist(32));
          },
        );

        test('generates different data for different input or domain', (
          sodium,
        ) async {
          final sut = sodium.crypto.xofTurboshake128;

          final messages1 = List.generate(
            10,
            (i) => Uint8List.fromList(List.generate(32, (j) => i + j)),
          );
          final messages2 = List.generate(
            15,
            (i) => Uint8List.fromList(List.generate(10, (j) => i * j)),
          );

          printOnFailure('message: $messages1');
          printOnFailure('message: $messages2');

          // ignore: close_sinks closed via addStream
          final consumer1 = sut.createConsumer();
          addTearDown(consumer1.dispose);
          // ignore: close_sinks closed via addStream
          final consumer2 = sut.createConsumer();
          addTearDown(consumer2.dispose);
          // ignore: close_sinks closed via addStream
          final consumer3 = sut.createConsumer(domain: 0x42);
          addTearDown(consumer3.dispose);

          await consumer1.addStream(Stream.fromIterable(messages1));
          await consumer2.addStream(Stream.fromIterable(messages2));
          await consumer3.addStream(Stream.fromIterable(messages1));

          final hash1 = consumer1.squeeze(32);
          final hash2 = consumer2.squeeze(32);
          final hash3 = consumer3.squeeze(32);

          printOnFailure('hash1: $hash1');
          printOnFailure('hash2: $hash2');
          printOnFailure('hash3: $hash3');

          expect(hash1, hasLength(32));
          expect(hash2, hasLength(32));
          expect(hash3, hasLength(32));

          expect(hash1, isNot(hash2));
          expect(hash2, isNot(hash3));
          expect(hash3, isNot(hash1));
        });
      });
    });

    group('turboshake256', () {
      test('constants return correct values', (sodium) {
        final sut = sodium.crypto.xofTurboshake256;

        expect(sut.blockBytes, 136, reason: 'blockBytes');
        expect(sut.stateBytes, 256, reason: 'stateBytes');
        expect(sut.domainStandard, 0x1F, reason: 'domainStandard');
      });

      group('call', () {
        test('generates outputs with identical prefix for identical input', (
          sodium,
        ) {
          final sut = sodium.crypto.xofTurboshake256;

          final message = Uint8List.fromList(
            List.generate(64, (index) => index + 32),
          );
          printOnFailure('message: $message');

          final hash1 = sut(message: message, outLen: 32);
          final hash2 = sut(message: message, outLen: 64);

          printOnFailure('hash1: $hash1');
          printOnFailure('hash2: $hash2');

          expect(hash1, hasLength(32));
          expect(hash2, hasLength(64));

          expect(hash1, hash2.sublist(0, 32));
        });

        test('generates different output for different data', (sodium) {
          final sut = sodium.crypto.xofTurboshake256;

          final message1 = Uint8List.fromList(
            List.generate(64, (index) => index + 32),
          );
          final message2 = Uint8List.fromList(
            List.generate(64, (index) => index - 32),
          );

          printOnFailure('message1: $message1');
          printOnFailure('message2: $message2');

          final hash1 = sut(message: message1, outLen: 32);
          final hash2 = sut(message: message2, outLen: 32);

          printOnFailure('hash1: $hash1');
          printOnFailure('hash2: $hash2');

          expect(hash1, hasLength(32));
          expect(hash2, hasLength(32));

          expect(hash1, isNot(hash2));
        });
      });

      group('createConsumer', () {
        test(
          'generates data with identical prefix for identical input and domain',
          (sodium) async {
            final sut = sodium.crypto.xofTurboshake256;

            final messages = List.generate(
              10,
              (i) => Uint8List.fromList(List.generate(32, (j) => i + j)),
            );

            printOnFailure('message: $messages');

            // ignore: close_sinks closed via addStream
            final consumer1 = sut.createConsumer();
            addTearDown(consumer1.dispose);
            // ignore: close_sinks closed via addStream
            final consumer2 = sut.createConsumer();
            addTearDown(consumer2.dispose);

            await consumer1.addStream(Stream.fromIterable(messages));
            await consumer2.addStream(Stream.fromIterable(messages));

            final hash1 = consumer1.squeeze(32);
            final hash2 = consumer1.squeeze(24);
            final hash3 = consumer2.squeeze(56);

            printOnFailure('hash1: $hash1');
            printOnFailure('hash2: $hash2');
            printOnFailure('hash3: $hash3');

            expect(hash1, hasLength(32));
            expect(hash2, hasLength(24));
            expect(hash3, hasLength(56));

            expect(hash1, hash3.sublist(0, 32));
            expect(hash2, hash3.sublist(32));
          },
        );

        test('generates different data for different input or domain', (
          sodium,
        ) async {
          final sut = sodium.crypto.xofTurboshake256;

          final messages1 = List.generate(
            10,
            (i) => Uint8List.fromList(List.generate(32, (j) => i + j)),
          );
          final messages2 = List.generate(
            15,
            (i) => Uint8List.fromList(List.generate(10, (j) => i * j)),
          );

          printOnFailure('message: $messages1');
          printOnFailure('message: $messages2');

          // ignore: close_sinks closed via addStream
          final consumer1 = sut.createConsumer();
          addTearDown(consumer1.dispose);
          // ignore: close_sinks closed via addStream
          final consumer2 = sut.createConsumer();
          addTearDown(consumer2.dispose);
          // ignore: close_sinks closed via addStream
          final consumer3 = sut.createConsumer(domain: 0x42);
          addTearDown(consumer3.dispose);

          await consumer1.addStream(Stream.fromIterable(messages1));
          await consumer2.addStream(Stream.fromIterable(messages2));
          await consumer3.addStream(Stream.fromIterable(messages1));

          final hash1 = consumer1.squeeze(32);
          final hash2 = consumer2.squeeze(32);
          final hash3 = consumer3.squeeze(32);

          printOnFailure('hash1: $hash1');
          printOnFailure('hash2: $hash2');
          printOnFailure('hash3: $hash3');

          expect(hash1, hasLength(32));
          expect(hash2, hasLength(32));
          expect(hash3, hasLength(32));

          expect(hash1, isNot(hash2));
          expect(hash2, isNot(hash3));
          expect(hash3, isNot(hash1));
        });
      });
    });
  }
}
