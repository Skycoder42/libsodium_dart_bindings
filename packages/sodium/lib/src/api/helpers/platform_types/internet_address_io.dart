import 'dart:io';

import 'package:meta/meta.dart';

export 'dart:io' show InternetAddress, InternetAddressType;

/// @nodoc
@visibleForTesting
InternetAddress internetAddressFromString(String address) =>
    InternetAddress(address);
