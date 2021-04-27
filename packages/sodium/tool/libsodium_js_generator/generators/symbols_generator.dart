import '../json/symbol.dart';
import '../type_mappings.dart';
import 'generator.dart';

class SymbolsGenerator implements Generator {
  final TypeMappings typeMappings;

  const SymbolsGenerator(this.typeMappings);

  @override
  void writeDefinitions(
    dynamic wrapperDefinitions,
    StringSink sink,
    int intendent,
  ) {
    final symbol = Symbol.fromJson(wrapperDefinitions as Map<String, dynamic>);

    sink
      ..writeIntendent(intendent)
      ..writeSp('external')
      ..writeSp(typeMappings[_getReturnType(symbol)])
      ..write(symbol.name)
      ..writeln('(');

    for (final arg in symbol.inputs) {
      sink
        ..writeIntendent(intendent + 1)
        ..writeSp(typeMappings[arg.type])
        ..write(arg.name)
        ..writeln(',');
    }

    sink
      ..writeIntendent(intendent)
      ..writeln(');')
      ..writeln();
  }

  String _getReturnType(Symbol symbol) {
    final fallbackName = '${symbol.name}_result';
    if (typeMappings.isForced(fallbackName)) {
      return fallbackName;
    }

    if (symbol.returnValue == null) {
      return 'void';
    } else if (symbol.returnValue!.startsWith('libsodium.UTF8ToString')) {
      return 'string';
    } else if (symbol.outputs.length == 1) {
      return symbol.outputs.single.type;
    } else if (symbol.outputs.isEmpty &&
        (symbol.returnValue!.contains('===') ||
            symbol.returnValue!.contains('!==') ||
            symbol.returnValue == 'true' ||
            symbol.returnValue == 'false')) {
      return 'boolean';
    } else {
      return fallbackName;
    }
  }
}
