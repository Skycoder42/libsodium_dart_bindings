import 'package:meta/meta.dart';

@internal
@immutable
class LibsodiumVersion {
  final String ffi;
  final String js;

  const LibsodiumVersion._({required this.ffi, required this.js});

  Map<String, String> toJson() => {'ffi': ffi, 'js': js};
}

@internal
sealed class HookConstants {
  static const libsodiumVersion = LibsodiumVersion._(
    ffi: '1.0.21',
    js: '0.8.2',
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
