import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../json/struct.dart';
import '../types.dart';
import 'spec_generator.dart';

@immutable
final class StructGenerator extends SpecGenerator<ExtensionType> {
  final Struct struct;

  const StructGenerator(this.struct);

  @override
  ExtensionType build() => ExtensionType(
    (b) =>
        b
          ..name = struct.name
          ..representationDeclaration = RepresentationDeclaration(
            (b) =>
                b
                  ..declaredRepresentationType = Types.jsObject
                  ..name = '_',
          )
          ..primaryConstructorName = '_'
          ..implements.add(Types.jsObject)
          ..constructors.add(_buildConstructor())
          ..methods.addAll(_buildMethods()),
  );

  Constructor _buildConstructor() => Constructor(
    (b) =>
        b
          ..external = true
          ..optionalParameters.addAll(_buildParameters()),
  );

  Iterable<Parameter> _buildParameters() sync* {
    for (final MapEntry(key: name, value: type) in struct.members.entries) {
      yield Parameter(
        (b) =>
            b
              ..name = name
              ..named = true
              ..required = true
              ..type = refer(type),
      );
    }
  }

  Iterable<Method> _buildMethods() sync* {
    for (final MapEntry(key: name, value: type) in struct.members.entries) {
      yield Method(
        (b) =>
            b
              ..name = name
              ..external = true
              ..type = MethodType.getter
              ..returns = refer(type),
      );
    }
  }
}
