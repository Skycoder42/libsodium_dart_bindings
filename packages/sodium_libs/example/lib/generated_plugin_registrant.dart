import 'package:flutter_web_plugins/flutter_web_plugins.dart';
//
// Generated file. Do not edit.
//
// ignore_for_file: lines_longer_than_80_chars
import 'package:sodium_libs/src/platforms/sodium_web.dart';

// ignore: public_member_api_docs
void registerPlugins(Registrar registrar) {
  SodiumWeb.registerWith(registrar);
  registrar.registerMessageHandler();
}
