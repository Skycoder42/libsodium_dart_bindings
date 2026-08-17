import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/xof.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';
import 'helpers/xof/xof_consumer_js.dart';

@internal
abstract class XofBaseJS<T extends JSNumber>
    with XofValidations
    implements Xof {
  final LibSodiumJS sodium;

  new(this.sodium);

  @protected
  JSUint8Array internalXof(int outLen, JSUint8Array message);

  @protected
  XofInitJsFn<T> get internalInit;

  @protected
  XofInitWithDomainJsFn<T> get internalInitWithDomain;

  @protected
  XofUpdateJsFn<T> get internalUpdate;

  @protected
  XofSqueezeJsFn<T> get internalSqueeze;

  // libsodium.js does not export crypto_xof_XXX_DOMAIN_STANDARD - only
  // BLOCKBYTES and STATEBYTES are available. The value is therefore hardcoded
  // here; it is 0x1F for all four variants, as defined by
  // crypto_xof_XXX_DOMAIN_STANDARD in the libsodium headers.
  @override
  int get domainStandard => 0x1F;

  @override
  Uint8List call({required Uint8List message, required int outLen}) {
    validateOutLen(outLen);

    return jsErrorWrap(() => internalXof(outLen, message.toJS).toDart);
  }

  @override
  XofConsumer createConsumer({int? domain}) {
    if (domain != null) {
      validateDomain(domain);
      return XofConsumerJS<T>.domain(
        sodium: sodium,
        xofInit: internalInitWithDomain,
        xofUpdate: internalUpdate,
        xofSqueeze: internalSqueeze,
        domain: domain,
      );
    } else {
      return XofConsumerJS<T>(
        sodium: sodium,
        xofInit: internalInit,
        xofUpdate: internalUpdate,
        xofSqueeze: internalSqueeze,
      );
    }
  }
}
