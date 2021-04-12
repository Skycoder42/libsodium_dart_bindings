import 'dart:convert';
import 'dart:io';

import 'libsodium_js_generator/generators/constants_generator.dart';
import 'libsodium_js_generator/generators/library_generator.dart';
import 'libsodium_js_generator/generators/symbols_generator.dart';
import 'libsodium_js_generator/type_mappings.dart';

extension FileX on File {
  Future<dynamic> readAsJson() async => json.decode(await readAsString());
}

Future<void> main() async {
  const typeMappings = TypeMappings();
  const libraryGenerator = LibraryGenerator();
  const constantsGenerator = ConstantsGenerator(typeMappings);
  const symbolsGenerator = SymbolsGenerator(typeMappings);

  final wrapperDir = Directory('/tmp/tmp.rQkeBNjDxI/libsodium.js/wrapper');
  final outFile = File(
    '/home/felix/repos/libsodium_dart_bindings/packages/sodium/lib/src/js/bindings/sodium.js.g.dart',
  );
  final outSink = outFile.openWrite();

  try {
    libraryGenerator.writePre(outSink);

    final constantsFile = File('${wrapperDir.path}/constants.json');
    constantsGenerator.writeDefinitions(
      await constantsFile.readAsJson(),
      outSink,
      1,
    );

    final symbolsDir = Directory('${wrapperDir.path}/symbols');
    final symbolFiles = symbolsDir
        .list()
        .where((entry) => entry is File)
        .cast<File>()
        .where((entry) => entry.path.endsWith('.json'));
    await for (final symbolFile in symbolFiles) {
      print('processing symbol-file: ${symbolFile.path}');
      symbolsGenerator.writeDefinitions(
        await symbolFile.readAsJson(),
        outSink,
        1,
      );
    }

    libraryGenerator.writePost(outSink);
    await outSink.close();
  } finally {
    await outSink.close();
  }
}
