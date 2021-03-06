// ignore: test_library_import
import 'package:sodium/sodium.dart';

import '../test_case.dart';
import '../test_runner.dart';

class SodiumInitTestCase extends TestCase {
  final TestRunner runner;

  SodiumInitTestCase(this.runner) : super(runner);

  @override
  String get name => 'init';

  Sodium get sut => sodium;

  @override
  void setupTests() {
    test('can be called multiple times', () async {
      // TestRunner.loadSodium will call SodiumInit.init for the relevant
      // platform that the test is currently running on.
      //
      // Use this to ensure SodiumInit.init can be successfully called
      // more than once for each platform.
      for (var i = 0; i < 3; i++) {
        final _sodium = await runner.loadSodium();

        // Ensure this new reference to sodium actually works
        _sodium.secureRandom(1);
      }
    });
  }
}
