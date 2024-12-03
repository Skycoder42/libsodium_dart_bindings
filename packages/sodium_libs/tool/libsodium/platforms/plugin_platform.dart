import '../../../libsodium_version.dart';

enum ArchiveType {
  tarXz('.tar.xz'),
  zip('.zip');

  final String suffix;

  const ArchiveType(this.suffix);
}

enum PluginPlatform {
  android('android', 'src/main/jniLibs'),
  darwin('darwin', 'Libraries'),
  linux('linux', 'libs'),
  windows('windows', 'libs', archiveType: ArchiveType.zip);

  final String name;
  final String binaryDir;
  final ArchiveType archiveType;

  const PluginPlatform(
    this.name,
    this.binaryDir, {
    this.archiveType = ArchiveType.tarXz,
  });

  String get artifactName =>
      'libsodium-${libsodium_version.ffi}-$name${archiveType.suffix}';

  String get urlFilePath => '$artifactName.url';

  String get hashFilePath => '$artifactName.sha512';
}
