class LibraryGenerator {
  const LibraryGenerator();

  void writePre(StringSink sink) {
    sink
      ..writeln('// ignore_for_file: non_constant_identifier_names')
      ..writeln()
      ..writeln('@JS()')
      ..writeln('library sodium.js;')
      ..writeln()
      ..writeln("import 'dart:typed_data';")
      ..writeln()
      ..writeln("import 'package:js/js.dart';")
      ..writeln()
      ..writeln('@JS()')
      ..writeln('@anonymous')
      ..writeln('class LibSodiumJS {');
  }

  void writePost(StringSink sink) {
    sink.writeln('}');
  }
}
