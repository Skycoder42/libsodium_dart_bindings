import 'generator.dart';

class LibraryGenerator {
  const LibraryGenerator();

  void writeImports(StringSink sink) {
    sink
      ..writeln(
        '// ignore_for_file: non_constant_identifier_names, public_member_api_docs',
      )
      ..writeln()
      ..writeln('@JS()')
      ..writeln('library sodium.js;')
      ..writeln()
      ..writeln("import 'dart:typed_data';")
      ..writeln()
      ..writeln("import 'package:js/js.dart';")
      ..writeln();
  }

  void writeClassPre(StringSink sink) {
    sink
      ..writeln('@JS()')
      ..writeln('@anonymous')
      ..writeln('class LibSodiumJS {');
  }

  void writeExtraDefinitions(StringSink sink, int intendent) {
    sink
      ..writeIntendent(intendent)
      ..writeln('external num randombytes_seedbytes();')
      ..writeln()
      ..writeln('external void memzero(Uint8List bytes);')
      ..writeln()
      ..writeln('external Uint8List pad(Uint8List buf, num blocksize);')
      ..writeln()
      ..writeln('external Uint8List unpad(Uint8List buf, num blocksize);')
      ..writeln();
  }

  void writeClassPost(StringSink sink) {
    sink.writeln('}');
  }
}
