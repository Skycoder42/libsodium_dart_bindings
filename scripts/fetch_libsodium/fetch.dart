class SodiumVersion {
  final String ffiVersion;
  final String jsVersion;

  const SodiumVersion({
    required this.ffiVersion,
    required this.jsVersion,
  });

  SodiumVersion.fromJson(Map<String, dynamic> json)
      : this(
          ffiVersion: json['ffi'] as String,
          jsVersion: json['js'] as String,
        );
}

abstract class Fetch {
  const Fetch._();

  Future<void> call({
    required SodiumVersion version,
    String outDir,
  });
}
