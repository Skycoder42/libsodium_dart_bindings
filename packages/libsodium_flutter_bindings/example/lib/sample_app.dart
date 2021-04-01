import 'package:flutter/material.dart';
import 'package:libsodium_flutter_bindings_example/sodium_status.dart';

class SampleApp extends StatelessWidget {
  const SampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Sodium Flutter Sample'),
          ),
          body: const Center(
            child: SodiumStatus(),
          ),
        ),
      );
}
