export 'sodium.common.dart';
export 'src/sodium_init_fallback.dart'
    if (dart.library.ffi) 'src/ffi/sodium_ffi_init.dart'
    if (dart.library.js) 'src/js/sodium_js_init.dart';
