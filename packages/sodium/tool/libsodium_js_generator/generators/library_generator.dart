import 'generator.dart';

class LibraryGenerator {
  const LibraryGenerator();

  void writeImports(StringSink sink) {
    sink
      ..writeln(
        '// ignore_for_file: non_constant_identifier_names, public_member_api_docs',
      )
      ..writeln()
      ..writeln("import 'dart:js_interop';")
      ..writeln();
  }

  void writeClassPre(StringSink sink) {
    sink.writeln(
      'extension type LibSodiumJS._(JSObject _) implements JSObject {',
    );
  }

  void writeExtraDefinitions(StringSink sink, int intendent) {
    sink
      ..writeIntendent(intendent)
      ..writeln('external num randombytes_seedbytes();')
      ..writeln()
      ..writeln('external void memzero(JSUint8Array bytes);')
      ..writeln()
      ..writeln('external JSUint8Array pad(JSUint8Array buf, num blocksize);')
      ..writeln()
      ..writeln('external JSUint8Array unpad(JSUint8Array buf, num blocksize);')
      ..writeln();
  }

  void writeClassPost(StringSink sink) {
    sink.writeln('}');
  }
}
