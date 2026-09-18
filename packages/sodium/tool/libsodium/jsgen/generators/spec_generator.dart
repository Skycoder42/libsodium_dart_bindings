import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

@immutable
abstract base class const SpecGenerator<T extends Spec>() implements Spec {
  @protected
  T build();

  @override
  R accept<R>(SpecVisitor<R> visitor, [R? context]) =>
      build().accept<R>(visitor, context);
}
