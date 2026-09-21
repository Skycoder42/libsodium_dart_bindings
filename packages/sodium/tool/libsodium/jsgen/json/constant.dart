import 'package:meta/meta.dart';

@immutable
class const Constant({required final String name, required final String type}) {
  new fromJson(Map<String, dynamic> json)
    : this(name: json['name'] as String, type: json['type'] as String);

  static Iterable<Constant> fromJsonList(List<dynamic>? json) =>
      json?.cast<Map<String, dynamic>>().map(Constant.fromJson) ?? const [];
}
