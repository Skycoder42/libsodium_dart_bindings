import 'package:meta/meta.dart';

import 'constant.dart';

@immutable
class const Symbol({
  required super.name,
  required super.type,
  required final List<Constant> inputs,
  required final List<Constant> outputs,
  final String? returnValue,
}) extends Constant {
  new fromJson(Map<String, dynamic> json)
    : this(
        name: json['name'] as String,
        type: json['type'] as String,
        inputs: Constant.fromJsonList(json['inputs'] as List<dynamic>?)
            .toList(),
        outputs: Constant.fromJsonList(json['outputs'] as List<dynamic>?)
            .toList(),
        returnValue: json['return'] as String?,
      );
}
