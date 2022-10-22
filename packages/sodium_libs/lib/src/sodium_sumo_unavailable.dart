import 'package:flutter/services.dart';

/// A customized [PlatformException] with a predefined [code] and [message].
class SodiumSumoUnavailable extends PlatformException {
  /// The [PlatformException.code] for all [SodiumSumoUnavailable] exceptions.
  static const messageCode = 'SODIUM_SUMO_UNAVAILABLE';

  @override
  String get message => super.message!;

  /// Default constructor.
  SodiumSumoUnavailable({
    super.details,
    super.stacktrace,
  }) : super(
          code: messageCode,
          message: 'The current platform implementation '
              'does not support the advanced sodium sumo APIs',
        );
}
