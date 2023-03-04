import 'dart:async';
import 'dart:ffi';

import '../../../bindings/libsodium.ffi.dart';

/// A callback method to retrieve an instance of [DynamicLibrary].
typedef DynamicLibraryFactory = FutureOr<DynamicLibrary> Function();

/// A callback method to retrieve an instance of [LibSodiumFFI].
typedef LibSodiumFFIFactory = FutureOr<LibSodiumFFI> Function();
