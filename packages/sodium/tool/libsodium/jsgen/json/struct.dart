import 'package:meta/meta.dart';

@immutable
class const Struct({
  required final String name,
  required final Map<String, String> members,
}) {
  new fromJson(Map<String, dynamic> json)
    : this(
        name: json['name'] as String,
        members: (json['members'] as Map).cast(),
      );
}
