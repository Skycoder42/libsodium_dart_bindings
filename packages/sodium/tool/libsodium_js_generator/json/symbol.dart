import 'constant.dart';

class Symbol extends Constant {
  final List<Constant> inputs;
  final List<Constant> outputs;

  Constant get singleOutput {
    if (outputs.isEmpty) {
      return const Constant(name: 'Void', type: 'void');
    } else if (outputs.length == 1) {
      return outputs.single;
    } else {
      return const Constant(name: 'Never', type: 'never');
    }
  }

  const Symbol({
    required String name,
    required String type,
    required this.inputs,
    required this.outputs,
  }) : super(name: name, type: type);

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
        );
}
