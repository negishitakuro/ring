import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ring/models/entities/entities.dart';

part 'webrtc_state.freezed.dart';

@freezed
abstract class WebRtcState with _$WebRtcState {
  const factory WebRtcState({
    @Default(0) int viewIndex,
    @Default(<WebRtcUser>[]) List<WebRtcUser> users,
    @Default(AvStatus()) AvStatus localAvStatus,
    @Default(AvStatus()) AvStatus remoteAvStatus,
  }) = _WebRtcState;
}
