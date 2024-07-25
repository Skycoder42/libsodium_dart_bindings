import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../json/library_info.dart';
import '../spec_generator.dart';
import '../test/test_lib_sodium_js_generator.dart';

@immutable
final class TestLibraryGenerator extends SpecGenerator<Library> {
  final LibraryInfo libraryInfo;

  const TestLibraryGenerator(this.libraryInfo);

  @override
  Library build() => Library(
        (b) => b
          ..ignoreForFile.add('non_constant_identifier_names')
          ..ignoreForFile.add('public_member_api_docs')
          ..directives.add(Directive.import('dart:js_interop'))
          ..directives.add(Directive.import('package:mocktail/mocktail.dart'))
          ..directives.add(
            Directive.import('package:sodium/src/js/bindings/sodium.js.dart'),
          )
          ..body.addAll(_buildBody()),
      );

  Iterable<Spec> _buildBody() sync* {
    yield TestLibSodiumJsGenerator(
      typeMapping: libraryInfo.typeMapping,
      constants: libraryInfo.constants,
      symbols: libraryInfo.symbols,
    );
  }
}
