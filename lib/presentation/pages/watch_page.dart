import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../injection_container.dart';
import '../bloc/video_player/video_player_bloc.dart';

class WatchPage extends StatelessWidget {
  const WatchPage({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  final String videoUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VideoPlayerBloc>()..add(VideoInitialized(videoUrl)),
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: BlocBuilder<VideoPlayerBloc, VideoPlayerAppState>(
          builder: (context, state) {
            if (state.status == VideoPlayerStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == VideoPlayerStatus.error || state.controller == null) {
              return Center(child: Text(state.error ?? 'Unable to load video'));
            }

            final controller = state.controller!;
            return Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      final delta = -details.delta.dy / 400;
                      if ((details.localPosition.dx) < MediaQuery.of(context).size.width / 2) {
                        context.read<VideoPlayerBloc>().add(VideoBrightnessGestureChanged(delta));
                      } else {
                        context.read<VideoPlayerBloc>().add(VideoVolumeGestureChanged(delta));
                      }
                    },
                    onTap: () => context.read<VideoPlayerBloc>().add(VideoPlayPauseToggled()),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: controller.value.position.inMilliseconds
                      .toDouble()
                      .clamp(0, controller.value.duration.inMilliseconds.toDouble()),
                  max: controller.value.duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                  onChanged: (value) {
                    context
                        .read<VideoPlayerBloc>()
                        .add(VideoSeekRequested(Duration(milliseconds: value.toInt())));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: () => context.read<VideoPlayerBloc>().add(VideoPlayPauseToggled()),
                    ),
                    DropdownButton<double>(
                      value: state.playbackSpeed,
                      items: const [0.5, 1.0, 1.25, 1.5, 2.0]
                          .map((speed) => DropdownMenuItem(value: speed, child: Text('${speed}x')))
                          .toList(),
                      onChanged: (speed) {
                        if (speed != null) {
                          context.read<VideoPlayerBloc>().add(VideoSpeedChanged(speed));
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(state.pipEnabled ? Icons.picture_in_picture_alt : Icons.picture_in_picture),
                      onPressed: () => context.read<VideoPlayerBloc>().add(VideoPipToggled()),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Volume ${(state.volume * 100).round()}% | Brightness ${(state.brightness * 100).round()}%',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
