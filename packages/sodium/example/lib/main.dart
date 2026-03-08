import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sodium/sodium_sumo.dart';
import 'package:sodium_example/crypto_service.dart';

void main() async {
  // var sodium = await SodiumInit.init();
  var sodium = await SodiumSumoInit.init();

  runApp(MaterialApp(home: MainPage(sodium: sodium)));
}

class MainPage extends StatefulWidget {
  final SodiumSumo sodium;

  const MainPage({super.key, required this.sodium});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final CryptoService _cryptoService;
  late final TextEditingController _passwordController;
  late final TextEditingController _inlineController;

  late final Uint8List _salt;

  Future<void>? _passwordFuture;
  late String _secretKeyString;

  @override
  void initState() {
    super.initState();
    _cryptoService = CryptoService(widget.sodium);
    _passwordController = TextEditingController();
    _inlineController = TextEditingController();

    _salt = _cryptoService.generateSalt();
    _secretKeyString = _cryptoService.secretKey.runUnlockedSync(base64.encode);
  }

  @override
  void dispose() {
    super.dispose();
    _cryptoService.dispose();
    _passwordController.dispose();
    _inlineController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              spacing: 8,
              crossAxisAlignment: .stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: .start,
                      spacing: 8,
                      children: [
                        Text(
                          "Version",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          "Using libsodium version ${_cryptoService.version}",
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: .start,
                      spacing: 8,
                      children: [
                        Text(
                          "Keys",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(label: Text("Password")),
                        ),
                        FutureBuilder(
                          future: _passwordFuture,
                          builder: (context, snapshot) => Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ElevatedButton(
                                onPressed: snapshot.connectionState == .waiting
                                    ? null
                                    : _catching(
                                        () => setState(() {
                                          _passwordFuture = _generateKey();
                                        }),
                                      ),
                                child: Text("Derived Key"),
                              ),
                              if (snapshot.connectionState == .waiting)
                                CircularProgressIndicator(),
                            ],
                          ),
                        ),
                        Text("Current key: $_secretKeyString"),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: .start,
                      spacing: 8,
                      children: [
                        Text(
                          "Encryption",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextField(
                          controller: _inlineController,
                          decoration: InputDecoration(
                            label: Text("Text or file to encrypt"),
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton(
                              onPressed: _catching(_inlineEncrypt),
                              child: Text("Encrypt Text"),
                            ),
                            ElevatedButton(
                              onPressed: _catching(_inlineDecrypt),
                              child: Text("Decrypt Text"),
                            ),
                            ElevatedButton(
                              onPressed: _catching(_fileEncrypt),
                              child: Text("Encrypt File"),
                            ),
                            ElevatedButton(
                              onPressed: _catching(_fileDecrypt),
                              child: Text("Decrypt File"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateKey() async {
    await _cryptoService.deriveNewKey(_passwordController.text, _salt);
    setState(() {
      _secretKeyString = _cryptoService.secretKey.runUnlockedSync(
        base64.encode,
      );
    });
  }

  void _inlineEncrypt() {
    var plain = _inlineController.text;
    var cipher = _cryptoService.encryptSample(plain);
    _inlineController.text = base64.encode(cipher);
  }

  void _inlineDecrypt() {
    var cipher = base64.decode(_inlineController.text);
    var plain = _cryptoService.decryptSample(cipher);
    _inlineController.text = plain;
  }

  void _fileEncrypt() async {
    var plain = _inlineController.text;
    var cipher = await _cryptoService.encryptFileInChunks(plain);
    _inlineController.text = cipher;
  }

  void _fileDecrypt() async {
    var cipher = (_inlineController.text);
    var plain = await _cryptoService.decryptFileInChunks(cipher);
    _inlineController.text = plain;
  }

  void Function() _catching(FutureOr<void> Function() callback) => () async {
    try {
      await callback();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            showCloseIcon: true,
            closeIconColor: Theme.of(context).colorScheme.onError,
          ),
        );
      }
    }
  };
}
