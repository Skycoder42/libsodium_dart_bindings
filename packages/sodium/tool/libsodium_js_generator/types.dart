import 'package:code_builder/code_builder.dart';

sealed class Types {
  Types._();

  static TypeReference named(String symbol, [String? url]) => TypeReference(
        (b) => b
          ..symbol = symbol
          ..url = url,
      );

  static final TypeReference jsAny = named('JSAny');

  static final TypeReference jsObject = named('JSObject');

  static final TypeReference jsPromise = named('JSPromise');

  static final TypeReference unimplementedError = named('UnimplementedError');
}
