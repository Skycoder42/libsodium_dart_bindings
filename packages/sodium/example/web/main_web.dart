// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:developer';
import 'dart:html';

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:sodium/sodium.dart';
// ignore: avoid_relative_lib_imports
import '../lib/sodium_example.dart';

import 'interop.dart';

Future<void> main() async {
  print('init...');
  final libsodium = await _initImpl();
  final Sodium sodium = await SodiumJSInit.init(libsodium);

  final res = runSample(sodium);

  querySelector('#output')!.innerHtml =
      'Sodium Version: ${sodium.version}<br/>Hash-Result: $res';
}

Future<dynamic> _initImpl() async {
  final completer = Completer<dynamic>();
  print('> create completer');

  setProperty(
    window,
    'sodium',
    SodiumInit(
      onload: allowInterop(completer.complete),
    ),
  );
  print('> setup window');

  final script = ScriptElement();
  script
    ..async = true
    // ignore: unsafe_html
    ..src = 'sodium.js';
  document.head!.append(script);
  print('> appended script');

  return completer.future;
}
