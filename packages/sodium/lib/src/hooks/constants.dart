import 'package:meta/meta.dart';

@internal
@immutable
// ignore: public_member_api_docs false positive
class const JsDistRef({required final String path, required final String hash});

@internal
@immutable
class LibsodiumVersion {
  final String ffi;
  final String js;
  final String jsRef;

  const new _({required this.ffi, required this.js, String? jsRef})
    : jsRef = jsRef ?? 'refs/tags/$js';
}

@internal
sealed class HookConstants {
  static const libsodiumVersion = LibsodiumVersion._(
    ffi: '1.0.22',
    js: '0.8.4',
    jsRef: 'a79e5ddbbcfd130e27dcbbda1b5ba072c7a9787d',
  );

  static const jsDist = JsDistRef(
    path: 'dist/browsers/sodium.js',
    // ignore: lines_longer_than_80_chars for hash
    hash: '73e4b53dc0597b5eca60841f11406bae825239ff773d6dd797b9115688ed3161ea053b2a567f7875b0ff23548b564288965bd724dd1d7e5a99bdc3ae3f9655e8',
  );

  static const jsSumoDist = JsDistRef(
    path: 'dist/browsers-sumo/sodium.js',
    // ignore: lines_longer_than_80_chars for hash
    hash: 'd95956f041be5bcf8a9644027e3f4866138903a38f8fe84fdb0410a0076b0121e201379b8966281b2105c67b7c85e79df6e8a68eab0eea9a8dea48bfdaf0cd2a',
  );

  static const libsodiumSigningKey =
      'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3';

  static final libsodiumSrcDownloadUri = Uri.https(
    'download.libsodium.org',
    '/libsodium/releases/libsodium-${libsodiumVersion.ffi}-stable.tar.gz',
  );

  static final libsodiumArchive = Uri.file(
    '3rdparty/libsodium-${libsodiumVersion.ffi}-stable.tar.gz',
  );

  static final libsodiumHeadersLocation = Uri.file(
    '3rdparty/libsodium-${libsodiumVersion.ffi}-stable.includes',
  );

  // Special environment variables that are picked up by the build hook
  // Must be prefixed by "NIX_" as otherwise it would be stripped.
  // See https://dart.dev/tools/hooks#environment-variables

  static const skipBuildHooksEnvVarName = 'NIX_SKIP_SODIUM_BUILD_HOOKS';

  static const exportHeadersEnvVarName = 'NIX_EXPORT_SODIUM_HEADERS';

  static const debugLogEnvVarName = 'NIX_HOOKS_ENABLE_DEBUG_LOGGING';
}
