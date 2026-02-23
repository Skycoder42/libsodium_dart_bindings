import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../../json/constant.dart';
import '../../json/symbol.dart';
import '../../json/type_mapping.dart';
import '../../types.dart';
import '../constants_generator.dart';
import '../lib_sodium_js_generator.dart';
import '../spec_generator.dart';
import '../symbols_generator.dart';

@immutable
final class TestLibSodiumJsGenerator extends SpecGenerator<Class>
    with LibSodiumJsExtraMethodsMixin {
  @override
  final TypeMapping typeMapping;
  final Iterable<Constant> constants;
  final Iterable<Symbol> symbols;

  @override
  bool get external => false;

  const TestLibSodiumJsGenerator({
    required this.typeMapping,
    required this.constants,
    required this.symbols,
  });

  @override
  R accept<R>(SpecVisitor<R> visitor, [R? context]) {
    final newContext = buildInterface().accept<R>(visitor, context);
    return super.accept<R>(visitor, newContext);
  }

  @override
  Class build() => Class(
    (b) => b
      ..name = 'MockLibSodiumJS'
      ..extend = Types.named('Mock')
      ..implements.add(Types.named('_MockLibSodiumJS'))
      ..annotations.add(Types.named('JSExport').newInstance(const []))
      ..methods.add(_buildCast()),
  );

  @protected
  Class buildInterface() => Class(
    (b) => b
      ..name = '_MockLibSodiumJS'
      ..abstract = true
      ..annotations.add(Types.named('JSExport').newInstance(const []))
      ..methods.addAll(_buildMethods()),
  );

  Iterable<Method> _buildMethods() sync* {
    for (final constant in constants) {
      yield ConstantsGenerator(
        constant: constant,
        typeMapping: typeMapping,
        external: false,
      ).build();
    }
    for (final symbol in symbols) {
      yield SymbolsGenerator(
        symbol: symbol,
        typeMapping: typeMapping,
        external: false,
      ).build();
    }

    yield* buildExtraMethods();
  }

  Method _buildCast() => Method(
    (b) => b
      ..name = 'asLibSodiumJS'
      ..type = MethodType.getter
      ..returns = Types.named('LibSodiumJS')
      ..body = const Reference('createJSInteropWrapper')
          .call(
            const [Reference('this')],
            const {},
            [Types.named('MockLibSodiumJS')],
          )
          .asA(Types.named('LibSodiumJS'))
          .code,
  );
}
