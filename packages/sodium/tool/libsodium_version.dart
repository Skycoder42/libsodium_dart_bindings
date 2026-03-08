import 'dart:convert';
import 'dart:io';

class _Version {
  final String ffi;
  final String js;

  const _Version({required this.ffi, required this.js});

  Map<String, String> toJson() => {'ffi': ffi, 'js': js};
}

// ignore: constant_identifier_names for compatibility
const libsodium_version = _Version(ffi: '1.0.20', js: '0.7.14');

// ignore: unreachable_from_main used elsewhere
const libsodiumSigningKey =
    'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3';

void main() {
  stdout.writeln(json.encode(libsodium_version));
}
