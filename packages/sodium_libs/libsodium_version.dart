import 'dart:convert';
import 'dart:io';

class _Version {
  final String ffi;
  final String js;

  const _Version({
    required this.ffi,
    required this.js,
  });

  Map<String, String> toJson() => {
        'ffi': ffi,
        'js': js,
      };
}

// ignore: constant_identifier_names
const libsodium_version = _Version(
  ffi: '1.0.18',
  js: '0.7.11',
);

void main() {
  stdout.writeln(json.encode(libsodium_version));
}
