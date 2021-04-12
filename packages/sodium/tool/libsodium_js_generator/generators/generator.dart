abstract class Generator {
  void writeDefinitions(
    dynamic wrapperDefinitions,
    StringSink sink,
    int intendent,
  );
}

extension StringSinkX on StringSink {
  void writeIntendent(int intendent) => write('  ' * intendent);

  void writeSp(Object? object) {
    write(object);
    write(' ');
  }
}
