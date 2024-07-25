import '../json/constant.dart';
import 'file_loader.dart';

class ConstantsLoader {
  final FileLoader _wrapperLoader;

  ConstantsLoader(this._wrapperLoader);

  Stream<Constant> loadConstants() async* {
    final constants = await _wrapperLoader.loadFileJson(
      'constants.json',
      Constant.fromJsonList,
    );
    yield* Stream.fromIterable(constants);
  }
}
