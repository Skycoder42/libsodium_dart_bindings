import '../../../libsodium_version.dart';

enum ArchiveType {
  tarXz('.tar.xz'),
  zip('.zip');

  final String suffix;

  const ArchiveType(this.suffix);
}

enum PluginPlatform {
  android('android', 'src/main/jniLibs', ArchiveType.zip),
  darwin('darwin', 'Libraries', ArchiveType.zip),
  linux('linux', 'lib', ArchiveType.tarXz),
  windows('windows', 'lib', ArchiveType.zip);

  final String name;
  final String binaryDir;
  final ArchiveType archiveType;

  const PluginPlatform(
    this.name,
    this.binaryDir,
    this.archiveType,
  );

  String get artifactName =>
      'libsodium-${libsodium_version.ffi}-$name${archiveType.suffix}';

  String get urlFilePath => '$artifactName.url';

  String get hashFilePath => '$artifactName.sha512';
}
