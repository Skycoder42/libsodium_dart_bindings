# sodium_example
Demonstrates how to use the sodium package. Uses flutter to show and test that
the packages works for all flutter supported platforms.

## crypto_service.dart
This file contains the application logic for the example and works independently
of flutter. It showcases:
- How to do simple, symmetric encryption
- How to use the stream helper to encrypt large files efficiently
- How to use the secure password hashing to derive secure keys

## main.dart
Contains the flutter wrapper to showcase the different parts of the crypto
service. It consists of:
- A version information box
- A box to display and generate a new key used for the encryption
- A box to encrypt and decrypt plain text input or files
