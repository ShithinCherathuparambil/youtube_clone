part of 'video_player_bloc.dart';

enum VideoPlayerStatus { initial, loading, ready, error }

class VideoPlayerAppState extends Equatable {
  const VideoPlayerAppState({
    this.status = VideoPlayerStatus.initial,
    this.controller,
    this.volume = 0.5,
    this.brightness = 0.5,
    this.playbackSpeed = 1,
    this.pipEnabled = false,
    this.error,
  });

  final VideoPlayerStatus status;
  final VideoPlayerController? controller;
  final double volume;
  final double brightness;
  final double playbackSpeed;
  final bool pipEnabled;
  final String? error;

  VideoPlayerAppState copyWith({
    VideoPlayerStatus? status,
    VideoPlayerController? controller,
    double? volume,
    double? brightness,
    double? playbackSpeed,
    bool? pipEnabled,
    String? error,
  }) {
    return VideoPlayerAppState(
      status: status ?? this.status,
      controller: controller ?? this.controller,
      volume: volume ?? this.volume,
      brightness: brightness ?? this.brightness,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      pipEnabled: pipEnabled ?? this.pipEnabled,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        controller,
        volume,
        brightness,
        playbackSpeed,
        pipEnabled,
        error,
      ];
}
