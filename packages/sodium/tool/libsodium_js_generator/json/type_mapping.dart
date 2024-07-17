import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../types.dart';
import 'type_info.dart';

@immutable
class TypeMapping {
  final Map<String, TypeInfo> _mappings;

  const TypeMapping(this._mappings);

  TypeReference operator [](String type) {
    final mappedType = _mappings[type];
    if (mappedType == null) {
      stderr.writeln('Missing type-mapping: $type');
      exitCode = 1;
      return Types.jsAny;
    } else {
      return Types.named(mappedType.dartType);
    }
  }

  bool isForced(String type) => _mappings[type]?.force ?? false;
}
