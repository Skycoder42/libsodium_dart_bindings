import '../json/symbol.dart';
import 'file_loader.dart';

class SymbolsLoader {
  final FileLoader _wrapperLoader;

  SymbolsLoader(this._wrapperLoader);

  Stream<Symbol> loadSymbols() => _wrapperLoader.loadFilesJson(
    'symbols',
    (file) => file.path.endsWith('.json'),
    Symbol.fromJson,
  );
}
