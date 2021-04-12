class TypeMappings {
  static const _mappings = <String, String>{
    'void': 'void',
    'uint': 'num',
    'string': 'String',
  };

  const TypeMappings();

  String operator [](String type) {
    final mappedType = _mappings[type];
    if (mappedType == null) {
      return 'Never';
    } else {
      return mappedType;
    }
  }
}
