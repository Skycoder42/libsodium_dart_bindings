import 'package:meta/meta.dart';

import 'constant.dart';
import 'struct.dart';
import 'symbol.dart';
import 'type_info.dart';
import 'type_mapping.dart';

@immutable
class LibraryInfo {
  final TypeMapping typeMapping;
  final List<DartTypeDef> typeDefs;
  final List<Struct> structs;
  final List<Constant> constants;
  final List<Symbol> symbols;

  const LibraryInfo({
    required this.typeMapping,
    required this.typeDefs,
    required this.structs,
    required this.constants,
    required this.symbols,
  });
}
