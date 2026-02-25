import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:video_player/video_player.dart';

part 'video_player_event.dart';
part 'video_player_state.dart';

@injectable
class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerAppState> {
  VideoPlayerBloc() : super(const VideoPlayerAppState()) {
    on<VideoInitialized>(_onInitialized);
    on<VideoPlayPauseToggled>(_onPlayPauseToggled);
    on<VideoSeekRequested>(_onSeekRequested);
    on<VideoSpeedChanged>(_onSpeedChanged);
    on<VideoVolumeGestureChanged>(_onVolumeGestureChanged);
    on<VideoBrightnessGestureChanged>(_onBrightnessGestureChanged);
    on<VideoPipToggled>(_onPipToggled);
    on<VideoDisposeRequested>(_onDisposeRequested);
  }

  Future<void> _onInitialized(
    VideoInitialized event,
    Emitter<VideoPlayerAppState> emit,
  ) async {
    emit(state.copyWith(status: VideoPlayerStatus.loading, error: null));
    try {
      await state.controller?.dispose();
      final controller = VideoPlayerController.networkUrl(Uri.parse(event.url));
      await controller.initialize();
      await controller.setVolume(state.volume);
      await controller.setPlaybackSpeed(state.playbackSpeed);
      emit(
        state.copyWith(
          status: VideoPlayerStatus.ready,
          controller: controller,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: VideoPlayerStatus.error,
          error: 'Failed to initialize video: $e',
        ),
      );
    }
  }

  Future<void> _onPlayPauseToggled(
    VideoPlayPauseToggled event,
    Emitter<VideoPlayerAppState> emit,
  ) async {
    try {
      final controller = state.controller;
      if (controller == null) return;
      if (controller.value.isPlaying) {
        await controller.pause();
      } else {
        await controller.play();
      }
      emit(state.copyWith(status: VideoPlayerStatus.ready, error: null));
    } catch (e) {
      emit(state.copyWith(status: VideoPlayerStatus.error, error: 'Play/pause failed: $e'));
    }
  }

  Future<void> _onSeekRequested(
    VideoSeekRequested event,
    Emitter<VideoPlayerAppState> emit,
  ) async {
    try {
      final controller = state.controller;
      if (controller == null) return;
      await controller.seekTo(event.position);
      emit(state.copyWith(status: VideoPlayerStatus.ready, error: null));
    } catch (e) {
      emit(state.copyWith(status: VideoPlayerStatus.error, error: 'Seek failed: $e'));
    }
  }

  Future<void> _onSpeedChanged(
    VideoSpeedChanged event,
    Emitter<VideoPlayerAppState> emit,
  ) async {
    try {
      final speed = event.speed.clamp(0.5, 2.0);
      await state.controller?.setPlaybackSpeed(speed);
      emit(state.copyWith(playbackSpeed: speed, error: null));
    } catch (e) {
      emit(state.copyWith(status: VideoPlayerStatus.error, error: 'Speed change failed: $e'));
    }
  }

  Future<void> _onVolumeGestureChanged(
    VideoVolumeGestureChanged event,
    Emitter<VideoPlayerAppState> emit,
  ) async {
    try {
      final next = min(1.0, max(0, state.volume + event.delta));
      await state.controller?.setVolume(next);
      emit(state.copyWith(volume: next, error: null));
    } catch (e) {
      emit(state.copyWith(status: VideoPlayerStatus.error, error: 'Volume update failed: $e'));
    }
  }

  void _onBrightnessGestureChanged(
    VideoBrightnessGestureChanged event,
    Emitter<VideoPlayerAppState> emit,
  ) {
    try {
      final next = min(1.0, max(0, state.brightness + event.delta));
      // Hook here with system brightness plugin if required.
      emit(state.copyWith(brightness: next, error: null));
    } catch (e) {
      emit(state.copyWith(status: VideoPlayerStatus.error, error: 'Brightness update failed: $e'));
    }
  }

  void _onPipToggled(
    VideoPipToggled event,
    Emitter<VideoPlayerAppState> emit,
  ) {
    try {
      // Hook here with platform-specific PIP plugin as needed.
      emit(state.copyWith(pipEnabled: !state.pipEnabled, error: null));
    } catch (e) {
      emit(state.copyWith(status: VideoPlayerStatus.error, error: 'PIP toggle failed: $e'));
    }
  }

  Future<void> _onDisposeRequested(
    VideoDisposeRequested event,
    Emitter<VideoPlayerAppState> emit,
  ) async {
    await state.controller?.dispose();
    emit(const VideoPlayerAppState());
  }

  @override
  Future<void> close() async {
    await state.controller?.dispose();
    return super.close();
  }
}
