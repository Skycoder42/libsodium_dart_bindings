// ignore_for_file: unnecessary_lambdas to catch member access errors

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/kdf_hkdf.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';
import 'helpers/kdf_hkdf/kdf_hkdf_extract_consumer_js.dart';
import 'secure_key_js.dart';

@internal
abstract class KdfHkdfBaseJS<T extends JSNumber>
    with KdfHkdfValidations
    implements KdfHkdf {
  final LibSodiumJS sodium;

  KdfHkdfBaseJS(this.sodium);

  @override
  SecureKey keygen() =>
      SecureKeyJS(sodium, jsErrorWrap(() => internalKeygen()));

  @override
  SecureKey extract({Uint8List? salt, required Uint8List ikm}) => SecureKeyJS(
    sodium,
    jsErrorWrap(() => internalExtract(salt?.toJS, ikm.toJS)),
  );

  @override
  KdfHkdfExtractConsumer createExtractConsumer({Uint8List? salt}) =>
      KdfHkdfExtractConsumerJS<T>(
        sodium: sodium,
        extractInit: internalExtractInit,
        extractUpdate: internalExtractUpdate,
        extractFinal: internalExtractFinal,
        salt: salt,
      );

  @override
  SecureKey expand({
    required SecureKey masterKey,
    required String context,
    required int outLen,
  }) {
    validateMasterKey(masterKey);
    validateOutLen(outLen);

    return SecureKeyJS(
      sodium,
      jsErrorWrap(
        () => masterKey.runUnlockedSync(
          (masterKeyData) =>
              internalExpand(outLen, context, masterKeyData.toJS),
        ),
      ),
    );
  }

  @protected
  JSUint8Array internalKeygen();

  @protected
  JSUint8Array internalExtract(JSUint8Array? salt, JSUint8Array ikm);

  @protected
  JSUint8Array internalExpand(int outLen, String context, JSUint8Array prk);

  @protected
  HkdfExtractInitJsFn<T> get internalExtractInit;

  @protected
  HkdfExtractUpdateJsFn<T> get internalExtractUpdate;

  @protected
  HkdfExtractFinalJsFn<T> get internalExtractFinal;
}
