// ignore_for_file: unnecessary_lambdas

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:dart_test_tools/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/helpers/secret_stream/chunked_stream_transformer.dart';
import 'package:test/test.dart';

class MockEventSink extends Mock implements EventSink<Uint8List> {}

void main() {
  group('$ChunkedEventSink', () {
    const testChunkSize = 10;

    final mockEventSink = MockEventSink();

    setUp(() {
      reset(mockEventSink);
    });

    test('addError forwards error events to sink', () {
      final testError = Exception('test exception');
      final testStackTrace = StackTrace.current;

      final sut = ChunkedEventSink(mockEventSink, testChunkSize, null);
      addTearDown(sut.close);
      sut.addError(testError, testStackTrace);

      verify(() => mockEventSink.addError(testError, testStackTrace));
      verifyNoMoreInteractions(mockEventSink);
    });

    test('close closes sink', () {
      ChunkedEventSink(mockEventSink, testChunkSize, null).close();

      verify(() => mockEventSink.close());
      verifyNoMoreInteractions(mockEventSink);
    });

    group('add', () {
      testData<(List<int>, List<int>, int?)>(
        'forwards data in chunks',
        [
          ([], [], null),
          ([5], [5], null),
          ([5, 5], [10], null),
          ([5, 5, 5], [10, 5], null),
          ([5, 5, 5, 5, 5], [10, 10, 5], null),
          ([10], [10], null),
          ([10, 20], [10, 10, 10], null),
          ([10, 3], [10, 3], null),
          ([23], [10, 10, 3], null),
          ([7, 1, 8], [10, 6], null),
          ([1, 2, 2, 3, 1, 4], [10, 3], null),
          ([1, 11, 2, 2, 16, 8], [10, 10, 10, 10], null),
          ([], [], 8),
          ([8], [8], 8),
          ([8], [1, 7], 1),
          ([10], [8, 2], 8),
          ([23], [8, 10, 5], 8),
          ([4], [4], 8),
          ([5, 5, 5, 5, 5, 5, 5], [8, 10, 10, 7], 8),
          ([5, 5, 5, 5, 5, 5], [15, 10, 5], 15),
        ],
        (fixture) {
          final sut = ChunkedEventSink(
            mockEventSink,
            testChunkSize,
            fixture.$3,
          );

          var offset = 0;
          for (final bytes in fixture.$1) {
            sut.add(List.generate(bytes, (i) => offset + i));
            offset += bytes;
          }
          sut.close();

          offset = 0;
          final mappedChunks = fixture.$2.map((chunk) {
            final res = Uint8List.fromList(
              List.generate(chunk, (i) => offset + i),
            );
            offset += chunk;
            return res;
          });
          verifyInOrder([
            for (final chunk in mappedChunks) () => mockEventSink.add(chunk),
            () => mockEventSink.close(),
          ]);
          verifyNoMoreInteractions(mockEventSink);
        },
      );

      testData('works with random data', [null, 24], (fixture) {
        final rand = Random.secure();
        final sut = ChunkedEventSink(mockEventSink, testChunkSize, fixture);

        final max = rand.nextInt(20) + 10;
        final totalBytes = <int>[];
        for (var i = 0; i < max; ++i) {
          final length = rand.nextInt(50);
          final bytes = List.generate(length, (_) => rand.nextInt(256));
          totalBytes.addAll(bytes);
          sut.add(bytes);
        }
        sut.close();

        final expectedChunks = <Uint8List>[
          if (fixture case int())
            Uint8List.fromList(
              totalBytes.take(fixture).toList(),
            ),
        ];
        for (var i = fixture ?? 0; i < totalBytes.length; i += testChunkSize) {
          final chunk = Uint8List.fromList(
            totalBytes.skip(i).take(testChunkSize).toList(),
          );
          expectedChunks.add(chunk);
        }

        verifyInOrder([
          for (final chunk in expectedChunks) () => mockEventSink.add(chunk),
          () => mockEventSink.close(),
        ]);
        verifyNoMoreInteractions(mockEventSink);
      });
    });
  });

  group('$ChunkedStreamTransformer', () {
    const testChunkSize = 10;

    test('transforms data using a ChunkedEventSink', () {
      final testData = Stream.fromIterable([
        [1, 2, 3],
        [4, 5, 6, 7],
        [8, 9, 10, 11, 12, 13],
      ]);

      final transformed = testData.transform(
        const ChunkedStreamTransformer(testChunkSize),
      );

      expect(
        transformed,
        emitsInOrder([
          [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
          [11, 12, 13],
          emitsDone,
        ]),
      );
    });

    test('transforms data using a ChunkedEventSink with header', () {
      final testData = Stream.fromIterable([
        [1, 2, 3],
        [4, 5, 6, 7],
        [8, 9, 10, 11, 12, 13],
      ]);

      final transformed = testData.transform(
        const ChunkedStreamTransformer(
          testChunkSize,
          headerSize: 3,
        ),
      );

      expect(
        transformed,
        emitsInOrder([
          [1, 2, 3],
          [4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
          emitsDone,
        ]),
      );
    });
  });
}
