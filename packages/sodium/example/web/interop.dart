@JS()
library interop;

import 'package:js/js.dart';
import 'package:sodium/sodium.js.dart';

@JS()
@anonymous
class SodiumInit {
  external void Function(dynamic sodium) get onload;

  external factory SodiumInit({void Function(dynamic sodium) onload});
}
