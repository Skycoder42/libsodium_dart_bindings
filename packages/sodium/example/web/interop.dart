@JS()
library interop;

import 'package:js/js.dart';

@JS()
@anonymous
class SodiumBrowserInit {
  external void Function(dynamic sodium) get onload;

  external factory SodiumBrowserInit({void Function(dynamic sodium) onload});
}
