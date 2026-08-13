import 'package:meta/meta.dart';

import '../bindings/libsodium.ffi.dart' show crypto_xof_shake128_state;
import 'helpers/xof/xof_consumer_ffi.dart';
import 'xof_base_ffi.dart';

@internal
class XofShake128FFI extends XofBaseFFI<crypto_xof_shake128_state> {
  XofShake128FFI(super.sodium);

  @override
  int get blockBytes => sodium.crypto_xof_shake128_blockbytes();

  @override
  int get stateBytes => sodium.crypto_xof_shake128_statebytes();

  @override
  int get domainStandard => sodium.crypto_xof_shake128_domain_standard();

  @override
  XofFn get internalXof => sodium.crypto_xof_shake128;

  @override
  XofInitFn<crypto_xof_shake128_state> get internalInit =>
      sodium.crypto_xof_shake128_init;

  @override
  XofInitWithDomainFn<crypto_xof_shake128_state> get internalInitWithDomain =>
      sodium.crypto_xof_shake128_init_with_domain;

  @override
  XofUpdateFn<crypto_xof_shake128_state> get internalUpdate =>
      sodium.crypto_xof_shake128_update;

  @override
  XofSqueezeFn<crypto_xof_shake128_state> get internalSqueeze =>
      sodium.crypto_xof_shake128_squeeze;
}
