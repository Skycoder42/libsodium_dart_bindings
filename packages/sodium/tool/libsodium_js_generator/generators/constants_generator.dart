import '../json/constant.dart';
import '../type_mappings.dart';
import 'generator.dart';

class ConstantsGenerator implements Generator {
  final TypeMappings typeMappings;

  const ConstantsGenerator(this.typeMappings);

  @override
  void writeDefinitions(
    dynamic wrapperDefinitions,
    StringSink sink,
    int intendent,
  ) {
    final constants = Constant.fromJsonList(
      wrapperDefinitions as List<dynamic>,
    );

    for (final constant in constants) {
      sink
        ..writeIntendent(intendent)
        ..writeSp('external')
        ..writeSp(typeMappings[constant.type])
        ..write(constant.name)
        ..writeln(';')
        ..writeln();
    }
  }
}
