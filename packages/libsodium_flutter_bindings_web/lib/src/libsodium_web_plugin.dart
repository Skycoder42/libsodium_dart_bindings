import 'dart:html';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:sodium/sodium.dart';
import 'package:libsodium_flutter_bindings_platform_interface/libsodium_flutter_bindings_platform_interface.dart';

class LibsodiumWebPlugin extends LibsodiumPlatform {
  static void registerWith([Registrar? registrar]) {
    LibsodiumPlatform.instance = LibsodiumWebPlugin();
  }

  @override
  Future<Sodium> loadSodium() async {
    final jsInit = SodiumJSInit.init() as Future<Sodium>;
    final script = document.createElement('script') as ScriptElement;
    script
      ..async = true
      // ignore: unsafe_html
      ..src = 'sodium.js';
    document.head!.append(script);
    return jsInit;
  }
}
