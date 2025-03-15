import 'dart:ffi';

import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/key_pair.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';
import 'pointer_test_helpers.dart';

@isTestGroup
void testKeygen({
  required LibSodiumFFI mockSodium,
  required SecureKey Function() runKeygen,
  required int Function() keyBytesNative,
  required void Function(Pointer<UnsignedChar> k) keygenNative,
}) => group('keygen', () {
  const keyLen = 24;

  // ignore: prefer_asserts_with_message
  assert(mockSodium is Mock);

  setUp(() {
    when(keyBytesNative).thenReturn(keyLen);
  });

  test('calls native implementation on generated key', () {
    runKeygen();

    verifyInOrder([
      keyBytesNative,
      () => mockSodium.sodium_allocarray(keyLen, 1),
      () => mockSodium.sodium_mprotect_readwrite(any(that: isNot(nullptr))),
      () => keygenNative(any(that: isNot(nullptr))),
      () => mockSodium.sodium_mprotect_noaccess(any(that: isNot(nullptr))),
    ]);
  });

  test('returns generated key', () {
    final testData = List.generate(keyLen, (index) => index);
    when(() => keygenNative(any())).thenAnswer((i) {
      fillPointer(
        i.positionalArguments.first as Pointer<UnsignedChar>,
        testData,
      );
    });

    final res = runKeygen();

    expect(res.extractBytes(), testData);
  });

  test('disposes allocated key on error', () {
    when(() => keygenNative(any())).thenThrow(Exception());

    expect(() => runKeygen(), throwsA(isA<Exception>()));

    verify(() => mockSodium.sodium_free(any(that: isNot(nullptr))));
  });
});

@isTestGroup
void testKeypair({
  required LibSodiumFFI mockSodium,
  required KeyPair Function() runKeypair,
  required int Function() secretKeyBytesNative,
  required int Function() publicKeyBytesNative,
  required int Function(Pointer<UnsignedChar> pk, Pointer<UnsignedChar> sk)
  keypairNative,
}) => group('keypair', () {
  const secretKeyLen = 42;
  const publicKeyLen = 24;

  // ignore: prefer_asserts_with_message
  assert(mockSodium is Mock);

  setUp(() {
    when(secretKeyBytesNative).thenReturn(secretKeyLen);
    when(publicKeyBytesNative).thenReturn(publicKeyLen);
  });

  test('calls native implementation on both allocated keys', () {
    when(() => keypairNative(any(), any())).thenReturn(0);

    runKeypair();

    verifyInOrder([
      secretKeyBytesNative,
      publicKeyBytesNative,
      () => mockSodium.sodium_allocarray(secretKeyLen, 1),
      () => mockSodium.sodium_allocarray(publicKeyLen, 1),
      () => mockSodium.sodium_mprotect_readwrite(any(that: isNot(nullptr))),
      () => keypairNative(any(that: isNot(nullptr)), any(that: isNot(nullptr))),
      () => mockSodium.sodium_mprotect_noaccess(any(that: isNot(nullptr))),
    ]);
  });

  test('returns generated key', () {
    final testPublic = List.generate(
      publicKeyLen,
      (index) => publicKeyLen - index,
    );
    final testSecret = List.generate(secretKeyLen, (index) => index);
    when(() => keypairNative(any(), any())).thenAnswer((i) {
      fillPointer(
        i.positionalArguments[0] as Pointer<UnsignedChar>,
        testPublic,
      );
      fillPointer(
        i.positionalArguments[1] as Pointer<UnsignedChar>,
        testSecret,
      );
      return 0;
    });

    final res = runKeypair();

    expect(res.publicKey, testPublic);
    expect(res.secretKey.extractBytes(), testSecret);

    verifyNever(() => mockSodium.sodium_free(any()));
  });

  test('disposes allocated key on error', () {
    when(() => keypairNative(any(), any())).thenReturn(1);

    expect(() => runKeypair(), throwsA(isA<Exception>()));

    verify(() => mockSodium.sodium_free(any(that: isNot(nullptr)))).called(2);
  });
});

@isTestGroup
void testSeedKeypair({
  required LibSodiumFFI mockSodium,
  required KeyPair Function(SecureKey seed) runSeedKeypair,
  required int Function() seedBytesNative,
  required int Function() secretKeyBytesNative,
  required int Function() publicKeyBytesNative,
  required int Function(
    Pointer<UnsignedChar> pk,
    Pointer<UnsignedChar> sk,
    Pointer<UnsignedChar> seed,
  )
  seedKeypairNative,
}) => group('seedKeypair', () {
  const seedLen = 33;
  const secretKeyLen = 42;
  const publicKeyLen = 24;

  // ignore: prefer_asserts_with_message
  assert(mockSodium is Mock);

  setUp(() {
    when(seedBytesNative).thenReturn(seedLen);
    when(secretKeyBytesNative).thenReturn(secretKeyLen);
    when(publicKeyBytesNative).thenReturn(publicKeyLen);
  });

  test('asserts if seed is invalid', () {
    expect(
      () => runSeedKeypair(SecureKeyFake.empty(seedLen + 10)),
      throwsA(isA<RangeError>()),
    );

    verify(seedBytesNative);
  });

  test('calls native implementation on the keys with the seed', () {
    when(() => seedKeypairNative(any(), any(), any())).thenReturn(0);

    final seed = List.generate(seedLen, (index) => 3 * index);
    runSeedKeypair(SecureKeyFake(seed));

    verifyInOrder([
      seedBytesNative,
      secretKeyBytesNative,
      publicKeyBytesNative,
      () => mockSodium.sodium_allocarray(secretKeyLen, 1),
      () => mockSodium.sodium_allocarray(publicKeyLen, 1),
      () => mockSodium.sodium_mprotect_readwrite(
        any(that: isNot(hasRawData(seed))),
      ),
      () => seedKeypairNative(
        any(that: isNot(nullptr)),
        any(that: isNot(nullptr)),
        any(that: hasRawData<UnsignedChar>(seed)),
      ),
      () => mockSodium.sodium_mprotect_noaccess(
        any(that: isNot(hasRawData(seed))),
      ),
    ]);
  });

  test('returns generated key', () {
    final testPublic = List.generate(
      publicKeyLen,
      (index) => publicKeyLen - index,
    );
    final testSecret = List.generate(secretKeyLen, (index) => index);
    when(() => seedKeypairNative(any(), any(), any())).thenAnswer((i) {
      fillPointer(
        i.positionalArguments[0] as Pointer<UnsignedChar>,
        testPublic,
      );
      fillPointer(
        i.positionalArguments[1] as Pointer<UnsignedChar>,
        testSecret,
      );
      return 0;
    });

    final res = runSeedKeypair(SecureKeyFake.empty(seedLen));

    expect(res.publicKey, testPublic);
    expect(res.secretKey.extractBytes(), testSecret);

    verifyNever(
      () => mockSodium.sodium_free(any(that: hasRawData(testPublic))),
    );
  });

  test('disposes allocated key on error', () {
    when(() => seedKeypairNative(any(), any(), any())).thenReturn(1);

    expect(
      () => runSeedKeypair(SecureKeyFake.empty(seedLen)),
      throwsA(isA<Exception>()),
    );

    verify(() => mockSodium.sodium_free(any(that: isNot(nullptr)))).called(3);
  });
});
