import '../test_case.dart';

class ScalarMultTestCase extends TestCase {
  ScalarMultTestCase(super._runner);

  @override
  String get name => 'scalarmult';

  @override
  void setupTests() {
    testSumo('constants return correct values', (sodium) {
      final sut = sodium.crypto.scalarmult;

      expect(sut.bytes, 32, reason: 'bytes');
      expect(sut.scalarBytes, 32, reason: 'scalarBytes');
    });

    testSumo('base calculates public key for private key', (sodium) {
      final n = sodium.secureRandom(sodium.crypto.scalarmult.scalarBytes);

      printOnFailure('n: ${n.extractBytes()}');

      final q = sodium.crypto.scalarmult.base(n: n);

      expect(q, hasLength(sodium.crypto.scalarmult.bytes));
    });

    testSumo('call calculates shared key for keypair', (sodium) {
      final n1 = sodium.secureRandom(sodium.crypto.scalarmult.scalarBytes);
      final n2 = sodium.secureRandom(sodium.crypto.scalarmult.scalarBytes);

      printOnFailure('n1: ${n1.extractBytes()}');
      printOnFailure('n2: ${n2.extractBytes()}');

      final p1 = sodium.crypto.scalarmult.base(n: n1);
      final p2 = sodium.crypto.scalarmult.base(n: n2);

      printOnFailure('p1: $p1');
      printOnFailure('p2: $p2');

      final q1 = sodium.crypto.scalarmult(n: n1, p: p2);
      final q2 = sodium.crypto.scalarmult(n: n2, p: p1);

      expect(q1, q2);
    });
  }
}
