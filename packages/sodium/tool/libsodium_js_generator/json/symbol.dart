import 'package:meta/meta.dart';

import 'constant.dart';

@immutable
class Symbol extends Constant {
  final List<Constant> inputs;
  final List<Constant> outputs;
  final String? returnValue;

  const Symbol({
    required super.name,
    required super.type,
    required this.inputs,
    required this.outputs,
    this.returnValue,
  });

  Symbol.fromJson(Map<String, dynamic> json)
    : this(
        name: json['name'] as String,
        type: json['type'] as String,
        inputs: Constant.fromJsonList(
          json['inputs'] as List<dynamic>?,
        ).toList(),
        outputs: Constant.fromJsonList(
          json['outputs'] as List<dynamic>?,
        ).toList(),
        returnValue: json['return'] as String?,
      );
}
