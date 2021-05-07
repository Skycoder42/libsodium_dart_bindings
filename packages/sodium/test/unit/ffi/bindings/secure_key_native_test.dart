import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:sodium/src/ffi/bindings/memory_protection.dart';
import 'package:sodium/src/ffi/bindings/secure_key_native.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../test_data.dart';
import '../pointer_test_helpers.dart';

class MockLibSodiumFFI extends Mock implements LibSodiumFFI {}

class MockSodiumPointer extends Mock implements SodiumPointer<Uint8> {}

class MockSecureKey extends Mock implements SecureKey {}

class MockSecureKeyNative extends Mock implements SecureKeyNative {}

void main() {
  final mockSodium = MockLibSodiumFFI();

  setUpAll(() {
    registerPointers();
    registerFallbackValue<Object? Function(SodiumPointer<Uint8>)>((_) => null);
    registerFallbackValue<Object? Function(Uint8List)>((_) => null);
  });

  setUp(() {
    reset(mockSodium);
  });

  group('SecureKeySafeCastX', () {
    test('SecureKeyNative calls runUnlockedNative', () {
      final mockPtr = MockSodiumPointer();
      final sutMock = MockSecureKeyNative();
      when(
        () => sutMock.runUnlockedNative(
          any(),
          writable: any(named: 'writable'),
        ),
      ).thenAnswer((i) {
        final cb = i.positionalArguments.first as dynamic Function(
          SodiumPointer<Uint8>,
        );
        return cb(mockPtr);
      });

      final SecureKey sut = sutMock;
      final result = sut.runUnlockedNative(mockSodium, (pointer) {
        expect(pointer, mockPtr);
        return 42;
      }, writable: true);
      expect(result, 42);

      verify(() => sutMock.runUnlockedNative(any(), writable: true));
    });

    group('SecureKey', () {
      late MockSecureKey sutMock;

      setUp(() {
        mockAllocArray(mockSodium);

        sutMock = MockSecureKey();
      });

      void mockRun(Uint8List data) => when(
            () => sutMock.runUnlockedSync(
              any(),
              writable: any(named: 'writable'),
            ),
          ).thenAnswer((i) {
            final callback = i.positionalArguments.first as dynamic Function(
              Uint8List,
            );
            return callback(data);
          });

      testData<Tuple2<bool, MemoryProtection>>(
        'creates temporary pointer from data',
        const [
          Tuple2(false, MemoryProtection.readOnly),
          Tuple2(true, MemoryProtection.readWrite),
        ],
        (fixture) {
          final testData = List.generate(20, (index) => index);
          mockRun(Uint8List.fromList(testData));

          final result = sutMock.runUnlockedNative(mockSodium, (pointer) {
            expect(pointer.count, testData.length);
            expect(pointer.ptr, hasRawData<Uint8>(testData));
            expect(pointer.memoryProtection, fixture.item2);
            return true;
          }, writable: fixture.item1);
          expect(result, isTrue);

          verifyInOrder([
            () => mockSodium.sodium_allocarray(20, 1),
            () => mockSodium.sodium_free(any()),
          ]);
        },
      );

      test('updates data if writable', () {
        final testData = Uint8List.fromList(List.filled(15, 0));
        final resultData = Uint8List.fromList(
          List.generate(testData.length, (index) => index),
        );
        mockRun(testData);

        final result = sutMock.runUnlockedNative(mockSodium, (pointer) {
          pointer.asList().setAll(0, resultData);
          return true;
        }, writable: true);
        expect(result, isTrue);

        expect(testData, resultData);
      });

      test('disposes testptr on failure', () {
        mockRun(Uint8List(5));

        expect(
          () => sutMock.runUnlockedNative(
            mockSodium,
            (pointer) => throw Exception(),
          ),
          throwsA(isA<Exception>()),
        );

        verify(() => mockSodium.sodium_free(any()));
      });
    });
  });
}
