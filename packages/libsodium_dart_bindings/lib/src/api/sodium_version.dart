class SodiumVersion {
  final String _versionString;

  final int major;
  final int minor;

  const SodiumVersion(this.major, this.minor, this._versionString);

  @override
  String toString() => _versionString;

  @override
  bool operator ==(covariant SodiumVersion other) =>
      major == other.major && minor == other.minor;

  @override
  int get hashCode => runtimeType.hashCode ^ major.hashCode ^ minor.hashCode;

  bool operator <(SodiumVersion other) =>
      major < other.major || major == other.major && minor < other.minor;

  bool operator <=(SodiumVersion other) => (this == other) || (this < other);

  bool operator >(SodiumVersion other) =>
      major > other.major || major == other.major && minor > other.minor;

  bool operator >=(SodiumVersion other) => (this == other) || (this > other);
}
