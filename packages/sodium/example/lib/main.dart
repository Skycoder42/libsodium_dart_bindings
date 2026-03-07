import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sodium/sodium.dart';
import 'package:sodium_example/crypto_service.dart';

void main() async {
  var sodium = await SodiumInit.init();

  runApp(MainApp(sodium: sodium));
}

class MainApp extends StatefulWidget {
  final Sodium sodium;

  const MainApp({super.key, required this.sodium});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final CryptoService _cryptoService;
  late final TextEditingController _inlineController;

  @override
  void initState() {
    super.initState();
    _cryptoService = CryptoService(widget.sodium);
    _inlineController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _cryptoService.dispose();
    _inlineController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inlineController,
                      decoration: InputDecoration(
                        label: Text("Text to encrypt"),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _inlineEncrypt,
                    child: Text("Encrypt Text"),
                  ),
                  ElevatedButton(
                    onPressed: _inlineDecrypt,
                    child: Text("Decrypt Text"),
                  ),
                  ElevatedButton(
                    onPressed: _fileEncrypt,
                    child: Text("Encrypt File"),
                  ),
                  ElevatedButton(
                    onPressed: _fileDecrypt,
                    child: Text("Decrypt File"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
}
