import 'package:flutter/material.dart';
import 'package:sodium_libs/sodium_libs.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'sodium_libs example app',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('sodium_libs example app'),
          ),
          body: Center(
            child: FutureBuilder<Sodium>(
              future: SodiumInit.init(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    'Loaded libsodium with version ${snapshot.data!.version}',
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Failed to load libsodium with error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                }

                return const CircularProgressIndicator();
              },
            ),
          ),
        ),
      );
}
