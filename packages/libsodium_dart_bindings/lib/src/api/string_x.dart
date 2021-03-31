import 'dart:convert';
import 'dart:typed_data';

extension StringX on String {
  Int8List toCharArray() => Int8List.fromList(utf8.encode(this));
}
