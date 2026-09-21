import 'dart:async';

class const _ProxySink(final List<int> _buffer)
    implements StreamConsumer<List<int>> {
  @override
  Future<void> addStream(Stream<List<int>> stream) =>
      stream.listen(_buffer.addAll).asFuture();

  @override
  Future<void> close() async {}
}

class FileHelper._() {
  final _buffers = <String, List<int>>{};

  static Future<FileHelper> instance() async => FileHelper._();

  Future<void> writeBytes(String name, List<int> bytes) async =>
      _buffers[name] = bytes;

  Future<List<int>> readBytes(String name) async => _buffer(name);

  Stream<List<int>> read(String name) => Stream.value(_buffer(name));

  StreamConsumer<List<int>> write(String name) => _ProxySink(_buffer(name));

  int length(String name) => _buffer(name).length;

  List<int> _buffer(String name) => _buffers.putIfAbsent(name, () => []);
}
