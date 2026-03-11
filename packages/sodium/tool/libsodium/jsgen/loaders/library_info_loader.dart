import '../json/library_info.dart';
import 'constants_loader.dart';
import 'symbols_loader.dart';
import 'type_mappings_loader.dart';

class LibraryInfoLoader {
  final TypeMappingsLoader _typeMappingsLoader;
  final ConstantsLoader _constantsLoader;
  final SymbolsLoader _symbolsLoader;

  LibraryInfoLoader(
    this._typeMappingsLoader,
    this._constantsLoader,
    this._symbolsLoader,
  );

  Future<LibraryInfo> load() async => LibraryInfo(
    typeMapping: _typeMappingsLoader.typeMapping,
    typeDefs: _typeMappingsLoader.dartTypeDefs.toList(),
    structs: await _typeMappingsLoader.loadStructs().toList(),
    constants: await _constantsLoader.loadConstants().toList(),
    symbols: await _symbolsLoader.loadSymbols().toList(),
  );
}
