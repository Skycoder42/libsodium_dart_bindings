import 'dart:convert';
import 'dart:io';

const version = {"ffi": "1.0.18", "js": "0.7.9"};

abstract class LibsodiumVersion {
  const LibsodiumVersion._();

  static const ffi = '1.0.18';
  static const js = '0.7.9';
}

void main() {
  stdout.writeln(
    json.encode(
      {
        "ffi": LibsodiumVersion.ffi,
        "js": LibsodiumVersion.js,
      },
    ),
  );
}
