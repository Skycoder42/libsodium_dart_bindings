// coverage:ignore-file
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'init_push_result.freezed.dart';

@freezed
@internal
class InitPushResult<TState extends Object> with _$InitPushResult<TState> {
  const factory InitPushResult({
    required Uint8List header,
    required TState state,
  }) = _InitPushResult<TState>;
}
