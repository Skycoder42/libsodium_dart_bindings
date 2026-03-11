import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:dart_test_tools/tools.dart';
import 'package:path/path.dart';

import 'constants.dart' show libsodiumVersion;
import 'jsgen/generators/library_generator.dart';
import 'jsgen/generators/test/test_library_generator.dart';
import 'jsgen/json/library_info.dart';
import 'jsgen/loaders/constants_loader.dart';
import 'jsgen/loaders/file_loader.dart';
import 'jsgen/loaders/library_info_loader.dart';
import 'jsgen/loaders/repo_loader.dart';
import 'jsgen/loaders/symbols_loader.dart';
import 'jsgen/loaders/type_mappings_loader.dart';

Future<void> main() async {
  final libraryInfo = await _loadLibraryInfo();

  await _generate(
    LibraryGenerator(libraryInfo),
    File(
      join(
        FileLoader.scriptDir.path,
        '..',
        '..',
        'lib',
        'src',
        'js',
        'bindings',
        'sodium.js.dart',
      ),
    ),
  );

  await _generate(
    TestLibraryGenerator(libraryInfo),
    File(
      join(
        FileLoader.scriptDir.path,
        '..',
        '..',
        'test',
        'unit',
        'js',
        'sodium_js_mock.dart',
      ),
    ),
  );
}

Future<LibraryInfo> _loadLibraryInfo() async {
  final repoLoader = RepoLoader();
  final wrapperDir = await repoLoader.downloadRepo(libsodiumVersion.js);
  final wrapperLoader = FileLoader(wrapperDir);

  final sourceDir = Directory(join(FileLoader.scriptDir.path, 'jsgen'));
  final sourceLoader = FileLoader(sourceDir);

  final typeMappings = TypeMappingsLoader(sourceLoader);
  final constantsLoader = ConstantsLoader(wrapperLoader);
  final symbolsLoader = SymbolsLoader(wrapperLoader);
  final libraryInfoLoader = LibraryInfoLoader(
    typeMappings,
    constantsLoader,
    symbolsLoader,
  );

  return await libraryInfoLoader.load();
}

Future<void> _generate(Spec codeSpec, File outFile) async {
  final outSink = outFile.openWrite();
  try {
    final emitter = DartEmitter(
      orderDirectives: true,
      useNullSafetySyntax: true,
    );
    codeSpec.accept(emitter, outSink);
    await outSink.flush();
  } finally {
    await outSink.close();
  }

  await Github.exec('dart', ['format', outFile.path]);
  await Github.exec('dart', ['fix', '--apply', outFile.path]);
  await Github.exec('dart', ['format', outFile.path]);
}
