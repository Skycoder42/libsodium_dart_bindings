@TestOn('dart-vm')
library;

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/ffi/api/aead_chacha20poly1305_ffi.dart';
import 'package:sodium/src/ffi/api/aead_xchacha20poly1305ietf_ffi.dart';
import 'package:sodium/src/ffi/api/auth_ffi.dart';
import 'package:sodium/src/ffi/api/box_ffi.dart';
import 'package:sodium/src/ffi/api/crypto_ffi.dart';
import 'package:sodium/src/ffi/api/generic_hash_ffi.dart';
import 'package:sodium/src/ffi/api/kdf_ffi.dart';
import 'package:sodium/src/ffi/api/kx_ffi.dart';
import 'package:sodium/src/ffi/api/secret_box_ffi.dart';
import 'package:sodium/src/ffi/api/secret_stream_ffi.dart';
import 'package:sodium/src/ffi/api/short_hash_ffi.dart';
import 'package:sodium/src/ffi/api/sign_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late CryptoFFI sut;

  setUp(() {
    reset(mockSodium);

    sut = CryptoFFI(mockSodium);
  });

  test('secretBox returns SecretBoxFFI instance', () {
    expect(
      sut.secretBox,
      isA<SecretBoxFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('secretStream returns SecretStreamFFI instance', () {
    expect(
      sut.secretStream,
      isA<SecretStreamFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('aeadChaCha20Poly1305 returns AeadChacha20Poly1305FFI instance', () {
    expect(
      sut.aeadChaCha20Poly1305,
      isA<AeadChacha20Poly1305FFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test(
      'aeadXChaCha20Poly1305IETF returns AeadXChaCha20Poly1305IETFFFI instance',
      () {
    expect(
      sut.aeadXChaCha20Poly1305IETF,
      isA<AeadXChaCha20Poly1305IETFFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('auth returns AuthFFI instance', () {
    expect(
      sut.auth,
      isA<AuthFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('box returns BoxFFI instance', () {
    expect(
      sut.box,
      isA<BoxFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('sign returns SignFFI instance', () {
    expect(
      sut.sign,
      isA<SignFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('genericHash returns GenericHashFFI instance', () {
    expect(
      sut.genericHash,
      isA<GenericHashFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('shortHash returns ShortHashFFI instance', () {
    expect(
      sut.shortHash,
      isA<ShortHashFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('kdf returns KdfFFI instance', () {
    expect(
      sut.kdf,
      isA<KdfFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('kx returns KxFFI instance', () {
    expect(
      sut.kx,
      isA<KxFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });
}
