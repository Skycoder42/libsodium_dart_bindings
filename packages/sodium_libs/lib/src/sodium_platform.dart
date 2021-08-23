import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sodium/sodium.dart';

/// The abstract platform interface
///
/// This interface is implemented by the package for each supported native
/// platform. When using the package, you can get a reference to the current
/// instance via [SodiumPlatform.instance].
///
/// **Note:** When implementing your own platform instance, you have to extend
/// this class. Implementing it is not allowed
abstract class SodiumPlatform extends PlatformInterface {
  static final Object _token = Object();

  static SodiumPlatform? _instance;

  /// Default constructor
  SodiumPlatform() : super(token: _token);

  /// Returns the currently loaded native instance of this plugin
  static SodiumPlatform get instance => _instance!;

  /// @nodoc
  @internal
  static bool get isRegistered => _instance != null;

  /// Overrides or initializes the plugin with the given [instance].
  static set instance(SodiumPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Load an instance of [Sodium] for the current platform.
  ///
  /// This is the primary method that all implementers of the platform interface
  /// must implement. Inside this method, they should load a native instance of
  /// [Sodium] and return that loaded instance.
  ///
  /// Check out the sodium package documentation for details on how to obtain
  /// a native instance on each platform.
  Future<Sodium> loadSodium({
    @Deprecated('initNative is no longer required and will be ignored.')
        bool initNative = true,
  });

  /// A hint for the user if an outdated version of libsodium is detected.
  ///
  /// If your implementation requires some user action to update the embedded
  /// native libsodium implementation, you can override this getter to tell
  /// the user what they need to do to update it.
  @visibleForOverriding
  String get updateHint => 'Please file an issue at '
      'https://github.com/Skycoder42/libsodium_dart_bindings/issues.';
}
