part of 'video_player_bloc.dart';

sealed class VideoPlayerEvent {}

class VideoInitialized extends VideoPlayerEvent {
  VideoInitialized(this.url);
  final String url;
}

class VideoPlayPauseToggled extends VideoPlayerEvent {}

class VideoSeekRequested extends VideoPlayerEvent {
  VideoSeekRequested(this.position);
  final Duration position;
}

class VideoSpeedChanged extends VideoPlayerEvent {
  VideoSpeedChanged(this.speed);
  final double speed;
}

class VideoVolumeGestureChanged extends VideoPlayerEvent {
  VideoVolumeGestureChanged(this.delta);
  final double delta;
}

class VideoBrightnessGestureChanged extends VideoPlayerEvent {
  VideoBrightnessGestureChanged(this.delta);
  final double delta;
}

class VideoPipToggled extends VideoPlayerEvent {}

class VideoDisposeRequested extends VideoPlayerEvent {}
