// ignore_for_file: unnecessary_lambdas to catch member access errors

import 'dart:js_interop';

import 'package:meta/meta.dart';

import '../bindings/sodium.js.dart';
import 'helpers/xof/xof_consumer_js.dart';
import 'xof_base_js.dart';

@internal
class XofTurboshake128JS extends XofBaseJS<XofTurboshake128State> {
  new(super.sodium);

  @override
  int get blockBytes => sodium.crypto_xof_turboshake128_BLOCKBYTES;

  @override
  int get stateBytes => sodium.crypto_xof_turboshake128_STATEBYTES;

  @override
  JSUint8Array internalXof(int outLen, JSUint8Array message) =>
      sodium.crypto_xof_turboshake128(outLen, message);

  @override
  XofInitJsFn<XofTurboshake128State> get internalInit =>
      () => sodium.crypto_xof_turboshake128_init();

  @override
  XofInitWithDomainJsFn<XofTurboshake128State> get internalInitWithDomain =>
      (domain) => sodium.crypto_xof_turboshake128_init_with_domain(domain);

  @override
  XofUpdateJsFn<XofTurboshake128State> get internalUpdate =>
      (state, messageChunk) =>
          sodium.crypto_xof_turboshake128_update(state, messageChunk);

  @override
  XofSqueezeJsFn<XofTurboshake128State> get internalSqueeze =>
      (state, outLen) => sodium.crypto_xof_turboshake128_squeeze(state, outLen);
}
