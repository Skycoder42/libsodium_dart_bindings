import '../json/constant.dart';
import 'file_loader.dart';

class ConstantsLoader {
  final FileLoader _wrapperLoader;

  ConstantsLoader(this._wrapperLoader);

  Future<Iterable<Constant>> loadConstants() async =>
      await _wrapperLoader.loadFileJson(
        'constants.json',
        Constant.fromJsonList,
      );
}
