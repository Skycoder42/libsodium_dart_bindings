import 'package:dart_test_tools/tools.dart';

import '../../hook/build.dart';
import '../download_libsodium.dart';

Future<void> main(List<String> args) => Github.runZoned(() async {
  await downloadLibsodium();
  await Github.env.setOutput(skipBuildHooksVariableName, '0', asEnv: true);
});
