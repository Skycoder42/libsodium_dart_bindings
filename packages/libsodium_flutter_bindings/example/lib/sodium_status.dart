import 'package:flutter/material.dart';
import 'package:libsodium_flutter_bindings/libsodium_flutter_bindings.dart';

class SodiumStatus extends StatelessWidget {
  const SodiumStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<Sodium>(
        future: SodiumInit.init(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Loading sodium failed with error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            return Text('Loaded sodium. Version: ${snapshot.data!.version}');
          }
          return const Text('Loading sodium, please wait...');
        },
      );
}
