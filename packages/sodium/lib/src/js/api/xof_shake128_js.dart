// ignore_for_file: unnecessary_lambdas to catch member access errors

import 'dart:js_interop';

import 'package:meta/meta.dart';

import '../bindings/sodium.js.dart';
import 'helpers/xof/xof_consumer_js.dart';
import 'xof_base_js.dart';

@internal
class XofShake128JS extends XofBaseJS<XofShake128State> {
  XofShake128JS(super.sodium);

  @override
  int get blockBytes => sodium.crypto_xof_shake128_BLOCKBYTES;

  @override
  int get stateBytes => sodium.crypto_xof_shake128_STATEBYTES;

  @override
  JSUint8Array internalXof(int outLen, JSUint8Array message) =>
      sodium.crypto_xof_shake128(outLen, message);

  @override
  XofInitJsFn<XofShake128State> get internalInit =>
      () => sodium.crypto_xof_shake128_init();

  @override
  XofInitWithDomainJsFn<XofShake128State> get internalInitWithDomain =>
      (domain) => sodium.crypto_xof_shake128_init_with_domain(domain);

  @override
  XofUpdateJsFn<XofShake128State> get internalUpdate =>
      (state, messageChunk) =>
          sodium.crypto_xof_shake128_update(state, messageChunk);

  @override
  XofSqueezeJsFn<XofShake128State> get internalSqueeze =>
      (state, outLen) => sodium.crypto_xof_shake128_squeeze(state, outLen);
}
