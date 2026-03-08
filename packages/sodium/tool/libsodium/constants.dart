class LibsodiumVersion {
  final String ffi;
  final String js;

  const LibsodiumVersion({required this.ffi, required this.js});

  Map<String, String> toJson() => {'ffi': ffi, 'js': js};
}

const libsodiumSigningKey =
    'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3';

const libsodiumVersion = LibsodiumVersion(ffi: '1.0.21', js: '0.8.2');

final libsodiumSrcDownloadUri = Uri.https(
  'download.libsodium.org',
  '/libsodium/releases/libsodium-${libsodiumVersion.ffi}-stable.tar.gz',
);
