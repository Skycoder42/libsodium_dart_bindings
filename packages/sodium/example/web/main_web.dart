// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:developer';
import 'dart:html';

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:sodium/sodium.dart';
import 'package:sodium_example/sodium_example.dart';

import 'interop.dart';

Future<void> main() async {
  print('init...');
  final Sodium sodium = await SodiumInit.init2(_initImpl);

  final message = "Hello, World!";
  final cipher = runSample(sodium, message);

  querySelector('#output')!.innerHtml = 'Sodium Version: ${sodium.version}<br/>'
      'Plain text: $message<br/>'
      'Secret box cipher:$cipher';
}

Future<dynamic> _initImpl() async {
  final completer = Completer<dynamic>();
  print('> create completer');

  setProperty(
    window,
    'sodium',
    SodiumBrowserInit(
      onload: allowInterop(completer.complete),
    ),
  );
  print('> setup window');

  final script = ScriptElement();
  script
    ..type = 'text/javascript'
    ..async = true
    // ignore: unsafe_html
    ..src = 'sodium.js';
  document.head!.append(script);
  print('> appended script');

  return completer.future.timeout(
    const Duration(seconds: 5),
    onTimeout: () => throw Exception(
      'You must first download sodium.js from '
      'https://github.com/jedisct1/libsodium.js/tree/master/dist/browsers '
      'and place it in the web folder!',
    ),
  );
}
