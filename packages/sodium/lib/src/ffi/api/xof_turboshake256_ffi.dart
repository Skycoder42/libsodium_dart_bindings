import 'package:meta/meta.dart';

import '../bindings/libsodium.ffi.dart' show crypto_xof_turboshake256_state;
import 'helpers/xof/xof_consumer_ffi.dart';
import 'xof_base_ffi.dart';

@internal
class XofTurboshake256FFI extends XofBaseFFI<crypto_xof_turboshake256_state> {
  new(super.sodium);

  @override
  int get blockBytes => sodium.crypto_xof_turboshake256_blockbytes();

  @override
  int get stateBytes => sodium.crypto_xof_turboshake256_statebytes();

  @override
  int get domainStandard => sodium.crypto_xof_turboshake256_domain_standard();

  @override
  XofFn get internalXof => sodium.crypto_xof_turboshake256;

  @override
  XofInitFn<crypto_xof_turboshake256_state> get internalInit =>
      sodium.crypto_xof_turboshake256_init;

  @override
  XofInitWithDomainFn<crypto_xof_turboshake256_state>
  get internalInitWithDomain =>
      sodium.crypto_xof_turboshake256_init_with_domain;

  @override
  XofUpdateFn<crypto_xof_turboshake256_state> get internalUpdate =>
      sodium.crypto_xof_turboshake256_update;

  @override
  XofSqueezeFn<crypto_xof_turboshake256_state> get internalSqueeze =>
      sodium.crypto_xof_turboshake256_squeeze;
}
