// ignore_for_file: unnecessary_lambdas to catch member access errors

import 'dart:js_interop';

import 'package:meta/meta.dart';

import '../bindings/sodium.js.dart';
import 'helpers/xof/xof_consumer_js.dart';
import 'xof_base_js.dart';

@internal
class XofShake256JS extends XofBaseJS<XofShake256State> {
  new(super.sodium);

  @override
  int get blockBytes => sodium.crypto_xof_shake256_BLOCKBYTES;

  @override
  int get stateBytes => sodium.crypto_xof_shake256_STATEBYTES;

  @override
  JSUint8Array internalXof(int outLen, JSUint8Array message) =>
      sodium.crypto_xof_shake256(outLen, message);

  @override
  XofInitJsFn<XofShake256State> get internalInit =>
      () => sodium.crypto_xof_shake256_init();

  @override
  XofInitWithDomainJsFn<XofShake256State> get internalInitWithDomain =>
      (domain) => sodium.crypto_xof_shake256_init_with_domain(domain);

  @override
  XofUpdateJsFn<XofShake256State> get internalUpdate =>
      (state, messageChunk) =>
          sodium.crypto_xof_shake256_update(state, messageChunk);

  @override
  XofSqueezeJsFn<XofShake256State> get internalSqueeze =>
      (state, outLen) => sodium.crypto_xof_shake256_squeeze(state, outLen);
}
