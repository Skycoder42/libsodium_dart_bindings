export 'package:sodium/sodium.dart' hide SodiumInit;

export 'src/platforms/platforms.fallback.dart'
    if (dart.library.ffi) 'src/platforms/platforms.ffi.dart'
    if (dart.library.js) 'src/platforms/platforms.js.dart';

export 'src/sodium_init.dart';
export 'src/sodium_platform.dart';
export 'src/sodium_sumo_unavailable.dart';
