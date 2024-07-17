import 'package:code_builder/code_builder.dart';
import 'package:code_builder/src/visitors.dart';
import 'package:meta/meta.dart';

@immutable
abstract base class SpecGenerator<T extends Spec> implements Spec {
  const SpecGenerator();

  @protected
  T build();

  @override
  R accept<R>(SpecVisitor<R> visitor, [R? context]) =>
      build().accept<R>(visitor, context);
}
