import 'package:meta/meta.dart';

/// Placeholder type on platforms where it is not available (e.g. web).
typedef InternetAddress = dynamic;

/// Placeholder type on platforms where it is not available (e.g. web).
typedef InternetAddressType = Never;

/// @nodoc
@visibleForTesting
InternetAddress internetAddressFromString(String address) => address;
