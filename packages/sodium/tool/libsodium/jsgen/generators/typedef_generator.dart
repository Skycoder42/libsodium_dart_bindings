import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../types.dart';
import 'spec_generator.dart';

@immutable
final class const TypedefGenerator({
  required final String name,
  required final String type,
}) extends SpecGenerator<TypeDef> {
  @override
  TypeDef build() => TypeDef(
    (b) => b
      ..name = name
      ..definition = Types.named(type),
  );
}
