// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.sumo.dart';
import 'package:sodium/src/api/advanced/advanced_scalar_mult.dart';

import '../../test_case.dart';
import '../../test_runner.dart';

class AdvancedScalarMultTestCase extends AdvancedTestCase {
  AdvancedScalarMultTestCase(TestRunner runner) : super(runner);

  @override
  String get name => 'advanced_scalarmult';

  AdvancedScalarMult get sut => sodium.crypto.scalarMult;

  @override
  void setupTests() {
    test('constants return correct values', () {
      expect(sut.bytes, 32, reason: 'bytes');
      expect(sut.scalarBytes, 32, reason: 'scalarBytes');
    });

    group('base', () {
      test('generates correct public keys', () {
        final keys = sodium.crypto.kx.keyPair();

        printOnFailure(
          'keys.secretKey: ${keys.secretKey.extractBytes()}',
        );
        printOnFailure('keys.publicKey: ${keys.publicKey}');

        final calculatedPublicKey = sut.base(secretKey: keys.secretKey);

        printOnFailure('calculatedPublicKey: $calculatedPublicKey');

        expect(calculatedPublicKey, hasLength(sut.bytes));
        expect(calculatedPublicKey, keys.publicKey);
      });
    });

    group('scalarmult', () {
      test('generates correct session key pairs', () {
        final clientKeys = sodium.crypto.kx.keyPair();
        final serverKeys = sodium.crypto.kx.keyPair();

        printOnFailure(
          'clientKeys.secretKey: ${clientKeys.secretKey.extractBytes()}',
        );
        printOnFailure('clientKeys.publicKey: ${clientKeys.publicKey}');
        printOnFailure(
          'serverKeys.secretKey: ${serverKeys.secretKey.extractBytes()}',
        );
        printOnFailure('serverKeys.publicKey: ${serverKeys.publicKey}');

        final clientSharedKey = sut.call(
          secretKey: clientKeys.secretKey,
          otherPublicKey: serverKeys.publicKey,
        );
        final serverSharedKey = sut.call(
          secretKey: serverKeys.secretKey,
          otherPublicKey: clientKeys.publicKey,
        );

        printOnFailure('clientSharedKey: ${clientSharedKey.extractBytes()}');
        printOnFailure('serverSharedKey: ${serverSharedKey.extractBytes()}');

        expect(clientSharedKey, serverSharedKey);
      });
    });
  }
}
