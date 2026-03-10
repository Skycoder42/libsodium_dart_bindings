import 'package:archive/archive.dart';

sealed class Extractor {
  static Archive extract(Uri archiveUri) {
    final tarGzInStream = InputFileStream(archiveUri.toFilePath());
    try {
      final tarOutStream = OutputMemoryStream();
      final ok = const GZipDecoder().decodeStream(
        tarGzInStream,
        tarOutStream,
        verify: true,
      );
      if (!ok) {
        throw Exception(
          'Failed to decode gzip stream from archive: $archiveUri',
        );
      }

      return TarDecoder().decodeBytes(tarOutStream.getBytes(), verify: true);
    } finally {
      tarGzInStream.close();
    }
  }
}
