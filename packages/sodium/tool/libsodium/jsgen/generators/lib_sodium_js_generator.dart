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

  const new({
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
    yield Method(
      (b) => b
        ..name = 'free'
        ..external = external
        ..returns = typeMapping['void']
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = 'state_address'
              ..type = typeMapping['state_address'],
          ),
        )
        ..body = external
            ? null
            : Types.unimplementedError.newInstance(const []).thrown.code,
    );
    yield Method(
      (b) => b
        ..name = 'memcmp'
        ..external = external
        ..returns = typeMapping['boolean']
        ..requiredParameters.addAll([
          Parameter(
            (b) => b
              ..name = 'b1'
              ..type = typeMapping['buf'],
          ),
          Parameter(
            (b) => b
              ..name = 'b2'
              ..type = typeMapping['buf'],
          ),
        ])
        ..body = external
            ? null
            : Types.unimplementedError.newInstance(const []).thrown.code,
    );
    yield Method(
      (b) => b
        ..name = 'compare'
        ..external = external
        ..returns = typeMapping['uint']
        ..requiredParameters.addAll([
          Parameter(
            (b) => b
              ..name = 'b1'
              ..type = typeMapping['buf'],
          ),
          Parameter(
            (b) => b
              ..name = 'b2'
              ..type = typeMapping['buf'],
          ),
        ])
        ..body = external
            ? null
            : Types.unimplementedError.newInstance(const []).thrown.code,
    );
    yield Method(
      (b) => b
        ..name = 'is_zero'
        ..external = external
        ..returns = typeMapping['boolean']
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
        ..name = 'increment'
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
        ..name = 'add'
        ..external = external
        ..returns = typeMapping['void']
        ..requiredParameters.addAll([
          Parameter(
            (b) => b
              ..name = 'a'
              ..type = typeMapping['buf'],
          ),
          Parameter(
            (b) => b
              ..name = 'b'
              ..type = typeMapping['buf'],
          ),
        ])
        ..body = external
            ? null
            : Types.unimplementedError.newInstance(const []).thrown.code,
    );
    yield Method(
      (b) => b
        ..name = 'to_hex'
        ..external = external
        ..returns = typeMapping['string']
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = 'input'
              ..type = typeMapping['buf'],
          ),
        )
        ..body = external
            ? null
            : Types.unimplementedError.newInstance(const []).thrown.code,
    );
    yield Method(
      (b) => b
        ..name = 'from_hex'
        ..external = external
        ..returns = typeMapping['buf']
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = 'input'
              ..type = typeMapping['string'],
          ),
        )
        ..body = external
            ? null
            : Types.unimplementedError.newInstance(const []).thrown.code,
    );
  }
}
