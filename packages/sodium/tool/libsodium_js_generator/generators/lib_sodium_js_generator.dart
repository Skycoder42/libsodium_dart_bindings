import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../json/constant.dart';
import '../json/symbol.dart';
import '../json/type_mapping.dart';
import '../types.dart';
import 'constants_generator.dart';
import 'spec_generator.dart';
import 'symbols_generator.dart';

@immutable
final class LibSodiumJsGenerator extends SpecGenerator<ExtensionType>
    with LibSodiumJsExtraMethodsMixin {
  @override
  final TypeMapping typeMapping;
  final Iterable<Constant> constants;
  final Iterable<Symbol> symbols;

  const LibSodiumJsGenerator({
    required this.typeMapping,
    required this.constants,
    required this.symbols,
  });

  @override
  ExtensionType build() => ExtensionType(
    (b) => b
      ..name = 'LibSodiumJS'
      ..representationDeclaration = RepresentationDeclaration(
        (b) => b
          ..declaredRepresentationType = Types.jsObject
          ..name = '_',
      )
      ..primaryConstructorName = '_'
      ..implements.add(Types.jsObject)
      ..methods.addAll(_buildMethods()),
  );

  Iterable<Method> _buildMethods() sync* {
    yield Method(
      (b) => b
        ..name = 'ready'
        ..external = external
        ..type = MethodType.getter
        ..returns = Types.jsPromise,
    );

    for (final constant in constants) {
      yield ConstantsGenerator(
        constant: constant,
        typeMapping: typeMapping,
      ).build();
    }
    for (final symbol in symbols) {
      yield SymbolsGenerator(symbol: symbol, typeMapping: typeMapping).build();
    }

    yield* buildExtraMethods();
  }
}

base mixin LibSodiumJsExtraMethodsMixin<T extends Spec> on SpecGenerator<T> {
  TypeMapping get typeMapping;

  bool get external => true;

  Iterable<Method> buildExtraMethods() sync* {
    yield Method(
      (b) => b
        ..name = 'randombytes_seedbytes'
        ..external = external
        ..returns = typeMapping['uint']
        ..body = external
            ? null
            : Types.unimplementedError.newInstance(const []).thrown.code,
    );
    yield Method(
      (b) => b
        ..name = 'memzero'
        ..external = external
        ..returns = typeMapping['void']
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = 'bytes'
              ..type = typeMapping['buf'],
          ),
        )
        ..body = external
            ? null
            : Types.unimplementedError.newInstance(const []).thrown.code,
    );
    yield Method(
      (b) => b
        ..name = 'pad'
        ..external = external
        ..returns = typeMapping['buf']
        ..requiredParameters.addAll([
          Parameter(
            (b) => b
              ..name = 'buf'
              ..type = typeMapping['buf'],
          ),
          Parameter(
            (b) => b
              ..name = 'blocksize'
              ..type = typeMapping['uint'],
          ),
        ])
        ..body = external
            ? null
            : Types.unimplementedError.newInstance(const []).thrown.code,
    );
    yield Method(
      (b) => b
        ..name = 'unpad'
        ..external = external
        ..returns = typeMapping['buf']
        ..requiredParameters.addAll([
          Parameter(
            (b) => b
              ..name = 'buf'
              ..type = typeMapping['buf'],
          ),
          Parameter(
            (b) => b
              ..name = 'blocksize'
              ..type = typeMapping['uint'],
          ),
        ])
        ..body = external
            ? null
            : Types.unimplementedError.newInstance(const []).thrown.code,
    );
  }
}
