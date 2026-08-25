import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

import 'constant.dart';
import 'struct.dart';
import 'symbol.dart';
import 'type_info.dart';
import 'type_mapping.dart';

@immutable
class const Digests({
  required final Digest standard,
  required final Digest sumo,
});

@immutable
class const LibraryInfo({
  required final TypeMapping typeMapping,
  required final List<DartTypeDef> typeDefs,
  required final List<Struct> structs,
  required final List<Constant> constants,
  required final List<Symbol> symbols,
  required final Digests distHashes,
});
