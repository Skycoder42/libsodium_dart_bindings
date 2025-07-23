import 'package:flutter/material.dart';
import 'package:sodium_libs/sodium_libs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const resultTextKey = Key('resultText');

  final Sodium? preInitSodium;

  const MyApp({super.key, this.preInitSodium});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'sodium_libs example app',
    home: Scaffold(
      appBar: AppBar(title: const Text('sodium_libs example app')),
      body: Center(
        child: FutureBuilder<Sodium>(
          future: preInitSodium != null
              ? Future.value(preInitSodium)
              : SodiumInit.init(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                'Loaded libsodium with version ${snapshot.data!.version}',
                key: resultTextKey,
              );
            }

            if (snapshot.hasError) {
              return Text(
                'Failed to load libsodium with error: ${snapshot.error}\n'
                '${snapshot.stackTrace}',
                key: resultTextKey,
                style: TextStyle(color: Colors.red.shade900),
              );
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    ),
  );
}
