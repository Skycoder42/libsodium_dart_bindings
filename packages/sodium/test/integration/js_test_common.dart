import 'package:meta/meta.dart';

import 'package:web/web.dart';

mixin JsLoaderMixin {
  String get sodiumJsSrc;

  @protected
  void attachSodiumJs() {
    final script = HTMLScriptElement()..text = sodiumJsSrc;
    document.head!.append(script);
  }
}
