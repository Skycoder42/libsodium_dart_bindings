import 'package:code_assets/code_assets.dart';
import 'package:meta/meta.dart';

@internal
extension UriX on Uri {
  String toBashSafePath({String drivePrefix = '/'}) {
    if (OS.current == .windows) {
      return replace(
        pathSegments: [
          ...drivePrefix.split('/').where((s) => s.isNotEmpty),
          pathSegments.first.substring(0, 1).toLowerCase(),
          ...pathSegments.skip(1),
        ],
      ).toFilePath(windows: false);
    } else {
      return toFilePath();
    }
  }
}
