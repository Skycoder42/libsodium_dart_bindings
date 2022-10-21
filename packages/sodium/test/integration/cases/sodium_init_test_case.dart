import '../test_case.dart';
import '../test_runner.dart';

class SodiumInitTestCase extends TestCase {
  final TestRunner runner;

  SodiumInitTestCase(this.runner) : super(runner);

  @override
  String get name => 'init';

  @override
  void setupTests() {
    test('can be called multiple times', (sodium) async {
      // TestRunner.loadSodium will call SodiumInit.init for the relevant
      // platform that the test is currently running on.
      //
      // Use this to ensure SodiumInit.init can be successfully called
      // more than once for each platform.
      for (var i = 0; i < 3; i++) {
        final sodium = await runner.loadSodium();

        // Ensure this new reference to sodium actually works
        sodium.secureRandom(1);
      }
    });
  }
}
