import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../types.dart';
import 'spec_generator.dart';

@immutable
final class TypedefGenerator extends SpecGenerator<TypeDef> {
  final String name;
  final String type;

  const TypedefGenerator({required this.name, required this.type});

  @override
  TypeDef build() => TypeDef(
    (b) => b
      ..name = name
      ..definition = Types.named(type),
  );
}
