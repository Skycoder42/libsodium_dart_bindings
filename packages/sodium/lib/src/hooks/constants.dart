import 'package:meta/meta.dart';

@internal
@immutable
class const LibsodiumVersion._({
  required final String ffi,
  required final String js,
  final String jsRef = 'tags',
}) {
  Map<String, String?> toJson() => {'ffi': ffi, 'js': js, 'jsRef': jsRef};
}

@internal
sealed class HookConstants {
  static const libsodiumVersion = LibsodiumVersion._(
    ffi: '1.0.22',
    js: 'master',
    jsRef: 'heads',
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
