import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

/// @nodoc
@internal
class ChunkedEventSink implements EventSink<List<int>> {
  final EventSink<Uint8List> _sink;
  final int _chunkSize;

  Uint8List _buffer;
  int _bufferIndex;

  ChunkedEventSink(this._sink, this._chunkSize, int? headerSize)
    : _buffer = Uint8List(headerSize ?? _chunkSize),
      _bufferIndex = 0;

  @override
  void add(List<int> bytes) {
    var writtenBytes = 0;

    // remainingBytesToCopy > remainingBufferSpace
    while (bytes.length - writtenBytes >= _buffer.length - _bufferIndex) {
      _buffer.setRange(_bufferIndex, _buffer.length, bytes, writtenBytes);
      writtenBytes += _buffer.length - _bufferIndex;

      _sink.add(_buffer);
      _buffer = Uint8List(_chunkSize);
      _bufferIndex = 0;
    }

    // still bytes remaining
    final remainingBytes = bytes.length - writtenBytes;
    if (remainingBytes > 0) {
      _buffer.setRange(
        _bufferIndex,
        _bufferIndex + remainingBytes,
        bytes,
        writtenBytes,
      );
      _bufferIndex += remainingBytes;
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _sink.addError(error, stackTrace);

  @override
  void close() {
    if (_bufferIndex > 0) {
      _sink.add(_buffer.sublist(0, _bufferIndex));
    }
    _sink.close();
  }
}

/// @nodoc
@internal
class ChunkedStreamTransformer
    extends StreamTransformerBase<List<int>, Uint8List> {
  final int chunkSize;
  final int? headerSize;

  const ChunkedStreamTransformer(this.chunkSize, {this.headerSize});

  @override
  Stream<Uint8List> bind(Stream<List<int>> stream) => Stream.eventTransformed(
    stream,
    (sink) => ChunkedEventSink(sink, chunkSize, headerSize),
  );
}
