import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'helpers/validations.dart';

/// A typed [StreamConsumer], which is used to absorb data into an incremental
/// XOF (extendable output function) computation and to extract output of an
/// arbitrary length from it.
///
/// A consumer is created via [Xof.createConsumer]. Data is absorbed into it by
/// adding it to the consumer, either synchronously via [Sink.add] or
/// asynchronously via [StreamConsumer.addStream] - both invoke
/// crypto_xof_XXX_update internally. Output is then extracted via [squeeze].
///
/// The consumer holds native resources and thus **must** be disposed via
/// [dispose] as soon as it is no longer needed.
///
/// See [Xof.createConsumer] for more details.
///
/// See https://libsodium.gitbook.io/doc/hashing/xof#multi-part-api
/// and https://libsodium.gitbook.io/doc/hashing/xof#multi-part-api-1
abstract interface class XofConsumer
    implements StreamConsumer<Uint8List>, Sink<Uint8List> {
  /// Closes the absorbing phase of the consumer.
  ///
  /// After having been closed, no more data can be added to the consumer, but
  /// output can still be extracted from it via [squeeze]. Closing the consumer
  /// does not free its resources - [dispose] must still be called.
  ///
  /// See [StreamConsumer.close] for more details.
  @override
  Future<void> close();

  /// Provides crypto_xof_XXX_squeeze.
  ///
  /// Extracts [outLen] bytes of output from the consumer. Can be called
  /// multiple times to extract more output - the concatenation of all extracted
  /// outputs is identical to a single squeeze of the combined length.
  ///
  /// **Note:** Data can only be absorbed before any output is extracted.
  /// Therefore, calling this method on a consumer that has not been closed yet
  /// will implicitly [close] it first. In other words: after the first
  /// [squeeze], the consumer behaves as if [close] had been called on it and no
  /// more data can be added to it.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/xof#incremental-output
  Uint8List squeeze(int outLen);

  /// Disposes the consumer and frees all associated resources.
  ///
  /// After the consumer has been disposed, it cannot be used anymore - neither
  /// for absorbing more data nor for extracting more output.
  void dispose();
}

/// A meta class that provides access to all libsodium xof APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/hashing/xof.
/// Please refer to that documentation for more details about these APIs.
///
/// This interface represents a single XOF variant. The operations are identical
/// for all variants; only the underlying permutation and the reported constant
/// sizes differ. In the documentation of the members, `XXX` is a placeholder
/// for the variant, i.e. `shake128`, `shake256`, `turboshake128` or
/// `turboshake256`.
abstract interface class Xof {
  /// Provides crypto_xof_XXX_BLOCKBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/xof#constants
  /// and https://libsodium.gitbook.io/doc/hashing/xof#constants-1
  int get blockBytes;

  /// Provides crypto_xof_XXX_STATEBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/xof#constants
  /// and https://libsodium.gitbook.io/doc/hashing/xof#constants-1
  int get stateBytes;

  /// Provides crypto_xof_XXX_DOMAIN_STANDARD.
  ///
  /// This is the domain separation byte that is used by the standard variant of
  /// the algorithm, i.e. the one that [call] and a [createConsumer] without a
  /// domain use.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/xof#custom-domain-separation
  /// and https://libsodium.gitbook.io/doc/hashing/xof#custom-domain-separation-1
  int get domainStandard;

  /// Provides crypto_xof_XXX.
  ///
  /// Computes [outLen] bytes of output for the given [message] in a single
  /// step.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/xof#single-part-api
  /// and https://libsodium.gitbook.io/doc/hashing/xof#single-part-api-1
  Uint8List call({required Uint8List message, required int outLen});

  /// Provides crypto_xof_XXX_init and crypto_xof_XXX_init_with_domain.
  ///
  /// Creates a new [XofConsumer] for an incremental XOF computation. If a
  /// [domain] is specified, crypto_xof_XXX_init_with_domain is used, which
  /// creates an output that is independent of the standard variant. It must be
  /// a value between `0x01` and `0x7F`. Without a [domain], crypto_xof_XXX_init
  /// is used, which is the same as using [domainStandard].
  ///
  /// The returned [XofConsumer] is a typed [StreamConsumer], which wraps the
  /// incremental XOF APIs. Data can be absorbed into it via [Sink.add] or
  /// [StreamConsumer.addStream], which invoke crypto_xof_XXX_update, and output
  /// can be extracted via [XofConsumer.squeeze], which invokes
  /// crypto_xof_XXX_squeeze.
  ///
  /// The returned consumer must be disposed via [XofConsumer.dispose] after
  /// use.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/xof#multi-part-api
  /// and https://libsodium.gitbook.io/doc/hashing/xof#multi-part-api-1
  XofConsumer createConsumer({int? domain});
}

@internal
mixin XofValidations implements Xof {
  void validateOutLen(int outLen) =>
      Validations.checkAtLeast(outLen, 1, 'outLen');

  void validateDomain(int domain) =>
      Validations.checkInRange(domain, 0x01, 0x7F, 'domain');
}

@internal
mixin XofConsumerValidations implements XofConsumer {
  void validateOutLen(int outLen) =>
      Validations.checkAtLeast(outLen, 1, 'outLen');
}
