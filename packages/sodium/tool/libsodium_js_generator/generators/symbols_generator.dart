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
      ..writeSp(typeMappings[symbol.singleOutput.type])
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
}
