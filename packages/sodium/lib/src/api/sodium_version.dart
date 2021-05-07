/// A Version number class that providies the libsodium implementation version.
class SodiumVersion {
  final String _versionString;

  /// Provides sodium_library_version_major.
  final int major;

  /// Provides sodium_library_version_minor.
  final int minor;

  /// Default constructor
  const SodiumVersion(this.major, this.minor, this._versionString);

  /// Provides sodium_version_string.
  @override
  String toString() => _versionString;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else if (other is SodiumVersion) {
      return major == other.major && minor == other.minor;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => runtimeType.hashCode ^ major.hashCode ^ minor.hashCode;

  /// Checks if this version is less than other.
  bool operator <(SodiumVersion other) =>
      major < other.major || major == other.major && minor < other.minor;

  /// Checks if this version is less or equal than other.
  bool operator <=(SodiumVersion other) => (this == other) || (this < other);

  /// Checks if this version is greater than other.
  bool operator >(SodiumVersion other) =>
      major > other.major || major == other.major && minor > other.minor;

  /// Checks if this version is greater or equal than other.
  bool operator >=(SodiumVersion other) => (this == other) || (this > other);
}
