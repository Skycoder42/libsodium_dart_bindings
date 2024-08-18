import 'dart:async';

class _ProxySink implements StreamConsumer<List<int>> {
  final List<int> _buffer;

  const _ProxySink(this._buffer);

  @override
  Future addStream(Stream<List<int>> stream) =>
      stream.listen(_buffer.addAll).asFuture();

  @override
  Future close() async {}
}

class FileHelper {
  final _buffers = <String, List<int>>{};

  FileHelper._();

  static Future<FileHelper> instance() async => FileHelper._();

  Future<void> writeBytes(String name, List<int> bytes) async =>
      _buffers[name] = bytes;

  Future<List<int>> readBytes(String name) async => _buffer(name);

  Stream<List<int>> read(String name) => Stream.value(_buffer(name));

  StreamConsumer<List<int>> write(String name) => _ProxySink(_buffer(name));

  int length(String name) => _buffer(name).length;

  List<int> _buffer(String name) => _buffers.putIfAbsent(name, () => []);
}
