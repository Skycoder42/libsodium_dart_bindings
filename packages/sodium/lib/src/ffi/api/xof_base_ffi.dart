import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/sodium_exception.dart';
import '../../api/xof.dart';
import '../bindings/libsodium.ffi.wrapper.dart';
import '../bindings/sodium_scope.dart';
import 'helpers/xof/xof_consumer_ffi.dart';

@internal
typedef XofFn =
    int Function(
      Pointer<UnsignedChar> out,
      int outLen,
      Pointer<UnsignedChar> in$,
      int inLen,
    );

@internal
abstract class XofBaseFFI<T extends NativeType>
    with XofValidations
    implements Xof {
  final LibSodiumFFI sodium;

  XofBaseFFI(this.sodium);

  @protected
  XofFn get internalXof;

  @protected
  XofInitFn<T> get internalInit;

  @protected
  XofInitWithDomainFn<T> get internalInitWithDomain;

  @protected
  XofUpdateFn<T> get internalUpdate;

  @protected
  XofSqueezeFn<T> get internalSqueeze;

  @override
  Uint8List call({required Uint8List message, required int outLen}) {
    validateOutLen(outLen);

    return sodiumScope(sodium, (scope) {
      final outPtr = scope.alloc<UnsignedChar>(outLen);
      final inPtr = scope.copyList<UnsignedChar>(message);

      final result = internalXof(
        outPtr.ptr,
        outPtr.count,
        inPtr.ptr,
        inPtr.count,
      );
      SodiumException.checkSucceededInt(result);

      return scope.takeBytes<Uint8List>(outPtr);
    });
  }

  @override
  XofConsumer createConsumer({int? domain}) {
    if (domain != null) {
      validateDomain(domain);
      return XofConsumerFFI<T>.domain(
        sodium: sodium,
        stateBytes: stateBytes,
        xofInit: internalInitWithDomain,
        xofUpdate: internalUpdate,
        xofSqueeze: internalSqueeze,
        domain: domain,
      );
    } else {
      return XofConsumerFFI<T>(
        sodium: sodium,
        stateBytes: stateBytes,
        xofInit: internalInit,
        xofUpdate: internalUpdate,
        xofSqueeze: internalSqueeze,
      );
    }
  }
}
