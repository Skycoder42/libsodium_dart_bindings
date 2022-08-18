import 'package:meta/meta.dart';
import 'package:test/test.dart';

@isTestGroup
void testData<T>(
  dynamic description,
  List<T> fixtures,
  dynamic Function(T fixture) body, {
  String? testOn,
  Timeout? timeout,
  dynamic skip,
  dynamic tags,
  Map<String, dynamic>? onPlatform,
  int? retry,
  String Function(T fixture)? fixtureToString,
}) {
  assert(fixtures.isNotEmpty, 'fixtures must not be empty');
  group(description, () {
    for (final fixture in fixtures) {
      test(
        fixtureToString != null ? fixtureToString(fixture) : fixture.toString(),
        () => body(fixture),
        testOn: testOn,
        timeout: timeout,
        skip: skip,
        tags: tags,
        onPlatform: onPlatform,
        retry: retry,
      );
    }
  });
}
