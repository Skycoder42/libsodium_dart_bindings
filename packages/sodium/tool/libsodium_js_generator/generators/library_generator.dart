import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../json/library_info.dart';
import 'lib_sodium_js_generator.dart';
import 'spec_generator.dart';
import 'struct_generator.dart';
import 'typedef_generator.dart';

@immutable
final class LibraryGenerator extends SpecGenerator<Library> {
  final LibraryInfo libraryInfo;

  const LibraryGenerator(this.libraryInfo);

  @override
  Library build() => Library(
    (b) => b
      ..ignoreForFile.add('non_constant_identifier_names')
      ..ignoreForFile.add('public_member_api_docs')
      ..ignoreForFile.add('document_ignores')
      ..ignoreForFile.add('lines_longer_than_80_chars')
      ..directives.add(Directive.import('dart:js_interop'))
      ..body.addAll(_buildBody()),
  );

  Iterable<Spec> _buildBody() sync* {
    for (final (name: name, type: type) in libraryInfo.typeDefs) {
      yield TypedefGenerator(name: name, type: type);
    }

    for (final struct in libraryInfo.structs) {
      yield StructGenerator(struct);
    }

    yield LibSodiumJsGenerator(
      typeMapping: libraryInfo.typeMapping,
      constants: libraryInfo.constants,
      symbols: libraryInfo.symbols,
    );
  }
}
