import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../loaders/constants_loader.dart';
import '../../loaders/symbols_loader.dart';
import '../../loaders/type_mappings_loader.dart';
import '../test/test_lib_sodium_js_generator.dart';

@immutable
class TestLibraryGenerator {
  final TypeMappingsLoader _typeMappingsLoader;
  final ConstantsLoader _constantsLoader;
  final SymbolsLoader _symbolsLoader;

  const TestLibraryGenerator(
    this._typeMappingsLoader,
    this._constantsLoader,
    this._symbolsLoader,
  );

  Future<Library> build() async {
    final builder = LibraryBuilder()
      ..ignoreForFile.add('non_constant_identifier_names')
      ..ignoreForFile.add('public_member_api_docs')
      ..directives.add(Directive.import('dart:js_interop'))
      ..directives.add(Directive.import('package:mocktail/mocktail.dart'))
      ..directives.add(
        Directive.import('package:sodium/src/js/bindings/sodium.js.dart'),
      );

    await _buildBody().forEach(builder.body.add);

    return builder.build();
  }

  Stream<Spec> _buildBody() async* {
    final constants = await _constantsLoader.loadConstants();
    final symbols = await _symbolsLoader.loadSymbols();

    yield TestLibSodiumJsGenerator(
      typeMapping: _typeMappingsLoader.typeMapping,
      constants: constants,
      symbols: symbols,
    );
  }
}
