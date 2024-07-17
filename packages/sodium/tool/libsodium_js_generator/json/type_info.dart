import 'package:meta/meta.dart';

typedef DartTypeDef = ({String name, String type});

@immutable
class TypeInfo {
  final String dartType;
  final String? typeDef;
  final bool force;

  const TypeInfo(
    this.dartType, {
    this.typeDef,
    this.force = false,
  });

  DartTypeDef? get dartTypeDef =>
      typeDef != null ? (name: dartType, type: typeDef!) : null;
}
