import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../json/constant.dart';
import '../json/type_mapping.dart';
import '../types.dart';
import 'spec_generator.dart';

@immutable
final class ConstantsGenerator extends SpecGenerator<Method> {
  final Constant constant;
  final TypeMapping typeMapping;
  final bool external;

  const ConstantsGenerator({
    required this.constant,
    required this.typeMapping,
    this.external = true,
  });

  @override
  Method build() => Method(
    (b) => b
      ..name = constant.name
      ..external = external
      ..type = MethodType.getter
      ..returns = typeMapping[constant.type]
      ..body = external
          ? null
          : Types.unimplementedError.newInstance(const []).thrown.code,
  );
}
