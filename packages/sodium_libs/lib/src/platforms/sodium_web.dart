import 'dart:async';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:sodium/sodium.dart' show Sodium;
import 'package:sodium/sodium.js.dart';
import 'package:sodium/sodium_sumo.dart' show SodiumSumo;

import '../sodium_platform.dart';

/// Web platform implementation of SodiumPlatform
class SodiumWeb extends SodiumPlatform {
  /// Registers the [SodiumWeb] as [SodiumPlatform.instance]
  static void registerWith([Registrar? registrar]) {
    SodiumPlatform.instance = SodiumWeb();
  }

  @override
  Future<Sodium> loadSodium() async => await SodiumInit.init();

  @override
  Future<SodiumSumo> loadSodiumSumo() => SodiumSumoInit.init();
  @override
  String get updateHint =>
      'Please run `flutter pub run sodium_libs:update_web` again.';
}
