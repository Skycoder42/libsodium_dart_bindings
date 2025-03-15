import 'package:meta/meta.dart';

@immutable
class Struct {
  final String name;
  final Map<String, String> members;

  const Struct({required this.name, required this.members});

  Struct.fromJson(Map<String, dynamic> json)
    : this(
        name: json['name'] as String,
        members: (json['members'] as Map).cast(),
      );
}
