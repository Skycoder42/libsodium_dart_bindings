import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../json/symbol.dart';
import '../json/type_mapping.dart';
import '../types.dart';
import 'spec_generator.dart';

@immutable
final class SymbolsGenerator extends SpecGenerator<Method> {
  final Symbol symbol;
  final TypeMapping typeMapping;
  final bool external;

  const SymbolsGenerator({
    required this.symbol,
    required this.typeMapping,
    this.external = true,
  });

  @override
  Method build() => Method(
    (b) =>
        b
          ..name = symbol.name
          ..external = external
          ..returns = typeMapping[_getReturnTypeName(symbol)]
          ..requiredParameters.addAll(_buildParams())
          ..body =
              external
                  ? null
                  : Types.unimplementedError.newInstance(const []).thrown.code,
  );

  Iterable<Parameter> _buildParams() sync* {
    for (final input in symbol.inputs) {
      yield Parameter(
        (b) =>
            b
              ..name = input.name
              ..type = typeMapping[input.type],
      );
    }
  }

  String _getReturnTypeName(Symbol symbol) {
    final fallbackName = '${symbol.name}_result';
    final returnValue = symbol.returnValue;
    if (typeMapping.isForced(fallbackName)) {
      return fallbackName;
    } else if (returnValue == null) {
      return 'void';
    } else if (returnValue.startsWith('libsodium.UTF8ToString')) {
      return 'string';
    } else if (symbol.outputs.length == 1) {
      return symbol.outputs.single.type;
    } else if (symbol.outputs.isEmpty &&
        (returnValue.contains('===') ||
            returnValue.contains('!==') ||
            returnValue == 'true' ||
            returnValue == 'false')) {
      return 'boolean';
    } else {
      return fallbackName;
    }
  }
}
