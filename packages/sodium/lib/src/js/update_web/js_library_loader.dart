import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

import '../../hooks/constants.dart';

@internal
// ignore: public_member_api_docs false positive
class InvalidSha512SumException({
  required final Digest expected,
  required final Digest actual,
}) implements Exception {
  @override
  String toString() =>
      'InvalidSha512SumException: sha512sum $actual '
      'does not match expected: $expected';
}

@internal
// ignore: public_member_api_docs false positive
class const JsLibraryLoader() {
  Future<void> downloadTo(JsDistRef distRef, File out) async {
    final fileSink = out.openWrite();
    try {
      await downloadInto(distRef, fileSink);
      await fileSink.flush();
      await fileSink.close();
    } catch (_) {
      await fileSink.close();
      await out.delete();
      rethrow;
    }
  }

  Future<void> downloadInto(
    JsDistRef distRef,
    StreamSink<List<int>> out,
  ) async {
    final expectedDigest = Digest(hex.decode(distRef.hash));

    final downloadUri = Uri.https(
      'raw.githubusercontent.com',
      '/jedisct1/libsodium.js/${HookConstants.libsodiumVersion.jsRef}/${distRef.path}',
    );

    final client = HttpClient();
    try {
      final request = await client.getUrl(downloadUri);
      final response = await request.close();
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download $downloadUri with status: ${response.statusCode}',
        );
      }

      final hashingSink = _HashingSink(out);
      await response.pipe(hashingSink);

      if (hashingSink.digest != expectedDigest) {
        throw InvalidSha512SumException(
          expected: expectedDigest,
          actual: hashingSink.digest,
        );
      }
    } finally {
      client.close();
    }
  }
}

class _HashingSink(final StreamSink<List<int>> out)
    implements StreamConsumer<List<int>> {
  final _digestSink = AccumulatorSink<Digest>();
  late final ByteConversionSink _signer;

  this {
    _signer = sha512.startChunkedConversion(_digestSink);
  }

  Digest get digest => _digestSink.events.single;

  @override
  Future<void> addStream(Stream<List<int>> stream) {
    final completer = Completer<void>();
    stream.listen(
      (event) {
        _signer.add(event);
        out.add(event);
      },
      onError: out.addError,
      onDone: completer.complete,
      cancelOnError: false,
    );
    return completer.future;
  }

  @override
  Future<void> close() {
    _signer.close();
    _digestSink.close();
    return .value();
  }
}
