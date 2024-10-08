import 'key_pair.dart';
import 'secure_key.dart';
import 'sodium.dart';

/// A helper class that represents a boxed secure key that can be transferred
/// via isolates.
///
/// **Important:** This is a dangerous API, as it does not keep all the
/// guarantees that a normal [SecureKey] has. It represents an opaque handle
/// to a native resource that can be transferred between isolates. This means
/// that *you*, as the developer are responsible for managing this handle and
/// need to make sure you don't misuse it, as otherwise your whole application
/// can crash.
///
/// To use the API, obtain a transferrable key via
/// [Sodium.createTransferrableSecureKey]. This will create a **COPY** of the
/// original key in form of a [TransferrableSecureKey]. Now you can move this
/// instance to the target isolate and then restore the original key there.
///
/// Restoring the key can be done by calling
/// [Sodium.materializeTransferrableSecureKey]. The resulting [SecureKey] is
/// *not* a copy, but the actual instance that was transferred. After
/// materializing the key, the [TransferrableSecureKey] cannot be used
/// again!
///
/// **Attention:** You must **ALWAYS** materialize a [TransferrableSecureKey],
/// even if you do not intend to use it. Not doing so will leave a dangling
/// reference to secure memory, which is dangerous and must be avoided.
abstract interface class TransferrableSecureKey {}

/// A helper class that represents a boxed key pair that can be transferred
/// via isolates.
///
/// **Important:** This is a dangerous API, as it does not keep all the
/// guarantees that a normal [KeyPair] has. It represents an opaque handle
/// to a native resource that can be transferred between isolates. This means
/// that *you*, as the developer are responsible for managing this handle and
/// need to make sure you don't misuse it, as otherwise your whole application
/// can crash.
///
/// To use the API, obtain a transferrable key via
/// [Sodium.createTransferrableKeyPair]. This will create a **COPY** of the
/// original key in form of a [TransferrableKeyPair]. Now you can move this
/// instance to the target isolate and then restore the original key there.
///
/// Restoring the key can be done by calling
/// [Sodium.materializeTransferrableKeyPair]. The resulting [KeyPair] is
/// *not* a copy, but the actual instance that was transferred. After
/// materializing the key, the [TransferrableKeyPair] cannot be used
/// again!
///
/// **Attention:** You must **ALWAYS** materialize a [TransferrableSecureKey],
/// even if you do not intend to use it. Not doing so will leave a dangling
/// reference to secure memory, which is dangerous and must be avoided.
abstract interface class TransferrableKeyPair {}
