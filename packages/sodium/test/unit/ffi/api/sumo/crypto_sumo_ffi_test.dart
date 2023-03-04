@TestOn('dart-vm')
library crypto_sumo_ffi_test;

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/ffi/api/sumo/crypto_sumo_ffi.dart';
import 'package:sodium/src/ffi/api/sumo/scalarmult_sumo_ffi.dart';
import 'package:sodium/src/ffi/api/sumo/sign_sumo_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late CryptoSumoFFI sut;

  setUp(() {
    reset(mockSodium);

    sut = CryptoSumoFFI(mockSodium);
  });

  test('sign returns SignSumoFFI instance', () {
    expect(
      sut.sign,
      isA<SignSumoFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('scalarmult returns ScalarmultSumoFFI instance', () {
    expect(
      sut.scalarmult,
      isA<ScalarmultSumoFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });
}
