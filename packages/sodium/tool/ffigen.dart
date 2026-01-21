import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart' as cb;
import 'package:dart_style/dart_style.dart';
import 'package:ffigen/ffigen.dart';

void main() async {
  final bindingsUri = _ffigen();
  await _generateWrapper(bindingsUri);
}

final _pragmaInline = const cb.Reference(
  'pragma',
).call([cb.literalString('vm:prefer-inline')]);

Uri _ffigen() {
  final packageRoot = Platform.script.resolve('../');
  final outUri = packageRoot.resolve('lib/src/ffi/bindings/libsodium.ffi.dart');
  FfiGenerator(
    output: Output(
      dartFile: outUri,
      style: const NativeExternalBindings(assetId: 'package:sodium/libsodium'),
    ),
    headers: Headers(
      entryPoints: [
        if (Platform.isMacOS)
          packageRoot.resolve(
            'test/integration/binaries/macos/include/sodium.h',
          )
        else
          packageRoot.resolve(
            'test/integration/binaries/linux/include/sodium.h',
          ),
      ],
    ),
    macros: const Macros(include: _matchesLibsodium),
    globals: const Globals(include: _matchesLibsodium),
    enums: const Enums(include: _matchesLibsodium),
    structs: const Structs(include: _matchesLibsodium),
    unions: const Unions(include: _matchesLibsodium),
    functions: const Functions(include: _matchesLibsodium),
    typedefs: const Typedefs(include: _matchesLibsodium),
  ).generate();

  // add missing ignore
  final generatedFile = File.fromUri(outUri);
  final generatedContent = generatedFile.readAsStringSync();
  final updatedContent = generatedContent.replaceFirst(
    'unused_import',
    'unused_import, unused_field',
  );
  generatedFile.writeAsStringSync(updatedContent);

  return outUri;
}

bool _matchesLibsodium(Declaration declaration) {
  final lowerName = declaration.originalName.toLowerCase();
  return lowerName.startsWith('sodium') ||
      lowerName.startsWith('crypto') ||
      lowerName.startsWith('randombytes');
}

Future<void> _generateWrapper(Uri bindingsUri) async {
  final filePath = bindingsUri.toFilePath();
  final result = await AnalysisContextCollection(
    includedPaths: [filePath],
  ).contextFor(filePath).currentSession.getResolvedLibrary(filePath);
  if (result is! ResolvedLibraryResult) {
    throw Exception('Could not resolve $filePath: $result');
  }

  final buffer = StringBuffer();
  _buildWrapperLibrary(result.element).accept(
    cb.DartEmitter.scoped(useNullSafetySyntax: true, orderDirectives: true),
    buffer,
  );

  final wrapperFile = File.fromUri(
    bindingsUri.resolve(
      bindingsUri.pathSegments.last.replaceFirst('.dart', '.wrapper.dart'),
    ),
  );
  final formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );
  await wrapperFile.writeAsString(
    formatter.format(buffer.toString(), uri: wrapperFile.uri),
  );
}

cb.Library _buildWrapperLibrary(LibraryElement library) => cb.Library(
  (b) => b
    ..ignoreForFile.add('document_ignores')
    ..ignoreForFile.add('prefer_relative_imports')
    ..ignoreForFile.add('public_member_api_docs')
    ..ignoreForFile.add('non_constant_identifier_names')
    ..body.add(_buildWrapperClass(library)),
);

cb.Class _buildWrapperClass(LibraryElement library) => cb.Class(
  (b) => b
    ..name = 'LibSodiumFFI'
    ..constructors.add(cb.Constructor((b) => b..constant = true))
    ..methods.add(
      cb.Method(
        (b) => b
          ..name = 'sodium_freePtr'
          ..type = .getter
          ..returns = cb.TypeReference(
            (b) => b
              ..symbol = 'Pointer'
              ..url = 'dart:ffi'
              ..isNullable = true
              ..types.add(
                cb.TypeReference(
                  (b) => b
                    ..symbol = 'NativeFinalizerFunction'
                    ..url = 'dart:ffi',
                ),
              ),
          )
          ..body =
              cb.TypeReference(
                (b) => b
                  ..symbol = 'Native'
                  ..url = 'dart:ffi',
              ).property('addressOf').call([
                cb.refer('sodium_free', library.uri.toString()),
              ]).code,
      ),
    )
    ..methods.addAll(library.topLevelFunctions.map(_buildWrapperMethod)),
);

cb.Method _buildWrapperMethod(TopLevelFunctionElement method) => cb.Method(
  (b) => b
    ..name = method.name
    ..annotations.add(_pragmaInline)
    ..returns = _typeFromDartType(method.returnType)
    ..requiredParameters.addAll(method.formalParameters.map(_buildParameter))
    ..body = cb
        .refer(method.name!, method.library.uri.toString())
        .call(method.formalParameters.map((p) => cb.refer(p.name!)))
        .code,
);

cb.Parameter _buildParameter(FormalParameterElement param) => cb.Parameter(
  (b) => b
    ..name = param.name!
    ..type = _typeFromDartType(param.type),
);

cb.Reference _typeFromDartType(DartType type) => switch (type) {
  VoidType() => cb.TypeReference((b) => b..symbol = 'void'),
  FunctionType() => cb.FunctionType((b) {
    b
      ..returnType = _typeFromDartType(type.returnType)
      ..isNullable = type.nullabilitySuffix != .none;
    for (final param in type.formalParameters) {
      final type = _typeFromDartType(param.type);
      if (param.isRequiredPositional) {
        b.requiredParameters.add(type);
      } else if (param.isOptionalPositional) {
        b.optionalParameters.add(type);
      } else if (param.isRequiredNamed) {
        b.namedRequiredParameters[param.name!] = type;
      } else if (param.isOptionalNamed) {
        b.namedParameters[param.name!] = type;
      }
    }
  }),
  InterfaceType() => cb.TypeReference(
    (b) => b
      ..symbol = type.element.name
      ..url = type.element.library.uri.toString()
      ..isNullable = type.nullabilitySuffix != .none
      ..types.addAll(type.typeArguments.map(_typeFromDartType)),
  ),
  _ => throw UnsupportedError('Unsupported Dart type: $type'),
};
