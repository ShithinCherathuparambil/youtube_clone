import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_clone/presentation/bloc/video_player/video_player_bloc.dart';

void main() {
  group('VideoPlayerBloc', () {
    VideoPlayerBloc buildBloc() => VideoPlayerBloc();

    test('initial state has status=initial, volume=0.5, speed=1.0', () {
      final bloc = buildBloc();
      expect(bloc.state.status, VideoPlayerStatus.initial);
      expect(bloc.state.volume, 0.5);
      expect(bloc.state.playbackSpeed, 1.0);
      expect(bloc.state.pipEnabled, isFalse);
      expect(bloc.state.error, isNull);
      bloc.close();
    });

    group('VideoInitialized - invalid local file', () {
      blocTest<VideoPlayerBloc, VideoPlayerAppState>(
        'emits loading then error state for an invalid local file path',
        build: buildBloc,
        act: (bloc) => bloc.add(VideoInitialized('/nonexistent/invalid.mp4')),
        expect: () => [
          isA<VideoPlayerAppState>().having(
            (s) => s.status,
            'status',
            VideoPlayerStatus.loading,
          ),
          isA<VideoPlayerAppState>().having(
            (s) => s.status,
            'status',
            VideoPlayerStatus.error,
          ),
        ],
      );
    });

    group('VideoSpeedChanged', () {
      blocTest<VideoPlayerBloc, VideoPlayerAppState>(
        'clamps speed to 0.5 minimum',
        build: buildBloc,
        act: (bloc) => bloc.add(VideoSpeedChanged(0.1)),
        expect: () => [
          isA<VideoPlayerAppState>().having(
            (s) => s.playbackSpeed,
            'speed',
            0.5, // Clamped from 0.1
          ),
        ],
      );

      blocTest<VideoPlayerBloc, VideoPlayerAppState>(
        'clamps speed to 2.0 maximum',
        build: buildBloc,
        act: (bloc) => bloc.add(VideoSpeedChanged(5.0)),
        expect: () => [
          isA<VideoPlayerAppState>().having(
            (s) => s.playbackSpeed,
            'speed',
            2.0, // Clamped from 5.0
          ),
        ],
      );

      blocTest<VideoPlayerBloc, VideoPlayerAppState>(
        'accepts valid speed within range',
        build: buildBloc,
        act: (bloc) => bloc.add(VideoSpeedChanged(1.5)),
        expect: () => [
          isA<VideoPlayerAppState>().having(
            (s) => s.playbackSpeed,
            'speed',
            1.5,
          ),
        ],
      );
    });

    group('VideoVolumeGestureChanged', () {
      blocTest<VideoPlayerBloc, VideoPlayerAppState>(
        'increases volume by delta',
        build: buildBloc,
        act: (bloc) => bloc.add(VideoVolumeGestureChanged(0.2)),
        expect: () => [
          isA<VideoPlayerAppState>().having(
            (s) => s.volume,
            'volume',
            closeTo(0.7, 0.001), // 0.5 + 0.2
          ),
        ],
      );

      blocTest<VideoPlayerBloc, VideoPlayerAppState>(
        'clamps volume to max 1.0',
        build: buildBloc,
        act: (bloc) => bloc.add(VideoVolumeGestureChanged(0.9)),
        expect: () => [
          isA<VideoPlayerAppState>().having(
            (s) => s.volume,
            'volume',
            1.0, // Clamped
          ),
        ],
      );

      blocTest<VideoPlayerBloc, VideoPlayerAppState>(
        'clamps volume to min 0.0',
        build: buildBloc,
        act: (bloc) => bloc.add(VideoVolumeGestureChanged(-0.9)),
        expect: () => [
          isA<VideoPlayerAppState>().having(
            (s) => s.volume,
            'volume',
            0.0, // Clamped
          ),
        ],
      );
    });

    group('VideoBrightnessGestureChanged', () {
      blocTest<VideoPlayerBloc, VideoPlayerAppState>(
        'adjusts brightness by delta',
        build: buildBloc,
        act: (bloc) => bloc.add(VideoBrightnessGestureChanged(0.1)),
        expect: () => [
          isA<VideoPlayerAppState>().having(
            (s) => s.brightness,
            'brightness',
            closeTo(0.6, 0.001), // 0.5 + 0.1
          ),
        ],
      );
    });

    group('VideoPipToggled', () {
      blocTest<VideoPlayerBloc, VideoPlayerAppState>(
        'toggles PIP from false to true',
        build: buildBloc,
        act: (bloc) => bloc.add(VideoPipToggled()),
        expect: () => [
          isA<VideoPlayerAppState>().having(
            (s) => s.pipEnabled,
            'pipEnabled',
            isTrue,
          ),
        ],
      );

      blocTest<VideoPlayerBloc, VideoPlayerAppState>(
        'toggles PIP back to false on second event',
        build: buildBloc,
        act: (bloc) async {
          bloc.add(VideoPipToggled());
          await Future.delayed(Duration.zero);
          bloc.add(VideoPipToggled());
        },
        expect: () => [
          isA<VideoPlayerAppState>().having(
            (s) => s.pipEnabled,
            'pipEnabled',
            isTrue,
          ),
          isA<VideoPlayerAppState>().having(
            (s) => s.pipEnabled,
            'pipEnabled',
            isFalse,
          ),
        ],
      );
    });

    group('VideoDisposeRequested', () {
      blocTest<VideoPlayerBloc, VideoPlayerAppState>(
        'resets to initial state',
        build: buildBloc,
        seed: () => const VideoPlayerAppState(
          status: VideoPlayerStatus.ready,
          playbackSpeed: 1.5,
          pipEnabled: true,
        ),
        act: (bloc) => bloc.add(VideoDisposeRequested()),
        expect: () => [
          const VideoPlayerAppState(), // Reset to defaults
        ],
      );
    });
  });
}
