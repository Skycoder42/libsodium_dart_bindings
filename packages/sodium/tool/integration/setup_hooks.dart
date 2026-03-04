import 'package:dart_test_tools/tools.dart';

import '../../hook/build.dart';

Future<void> main(List<String> args) async {
  await Github.env.setOutput(skipBuildHooksVariableName, '', asEnv: true);
}
