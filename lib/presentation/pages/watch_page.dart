import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../domain/entities/comment.dart';
import '../../domain/usecases/get_comments.dart';

import '../../injection_container.dart';
import '../bloc/video_player/video_player_bloc.dart';
import '../bloc/download/download_manager_cubit.dart';
import '../bloc/download/download_manager_state.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/add_to_history.dart';

class WatchPage extends StatefulWidget {
  static const route = '/watch';
  const WatchPage({super.key, required this.video});

  final Video video;

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Add to watch history
    sl<AddToHistory>()(widget.video);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<VideoPlayerBloc>()..add(VideoInitialized(widget.video.videoUrl)),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return Container(
                color: Colors.black,
                child: Center(child: _VideoPlayerSection(video: widget.video)),
              );
            }
            return SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _VideoPlayerSection(video: widget.video),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _VideoInfoSection(video: widget.video),
                        _ChannelInfoSection(video: widget.video),
                        _ActionButtonsSection(video: widget.video),
                        const _DescriptionSection(),
                        Divider(
                          height: 1.h,
                          color: Theme.of(context).dividerColor,
                        ),
                        _CommentsSection(videoId: widget.video.id),
                        Divider(
                          height: 1.h,
                          color: Theme.of(context).dividerColor,
                        ),
                        const _UpNextSection(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VideoPlayerSection extends StatelessWidget {
  const _VideoPlayerSection({required this.video});
  final Video video;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerBloc, VideoPlayerAppState>(
      builder: (context, state) {
        if (state.status == VideoPlayerStatus.loading) {
          return Hero(
            tag: 'video_thumb_${video.id}',
            child: Material(
              color: Colors.black,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        if (state.status == VideoPlayerStatus.error ||
            state.controller == null) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  state.error ?? 'Error',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }

        final controller = state.controller!;
        return Hero(
          tag: 'video_thumb_${video.id}',
          child: Material(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: _CustomVideoPlayerControls(controller: controller),
            ),
          ),
        );
      },
    );
  }
}

class _CustomVideoPlayerControls extends StatefulWidget {
  const _CustomVideoPlayerControls({required this.controller});
  final VideoPlayerController controller;

  @override
  State<_CustomVideoPlayerControls> createState() =>
      _CustomVideoPlayerControlsState();
}

class _CustomVideoPlayerControlsState
    extends State<_CustomVideoPlayerControls> {
  bool _showControls = true;
  Timer? _hideTimer;
  bool _showSeekIndicator = false;
  bool _isSeekForward = false;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _onSideDoubleTap(bool isLeft) {
    _startHideTimer();
    final current = widget.controller.value.position;
    final seekDuration = isLeft
        ? -const Duration(seconds: 10)
        : const Duration(seconds: 10);
    final newPosition = current + seekDuration;

    context.read<VideoPlayerBloc>().add(VideoSeekRequested(newPosition));

    // Show visual feedback
    setState(() {
      _showSeekIndicator = true;
      _isSeekForward = !isLeft;
    });

    Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showSeekIndicator = false;
        });
      }
    });

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seeked 10s ${isLeft ? 'back' : 'forward'}'),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  String _selectedQuality = 'Auto (1080p)';

  void _showSettingsBottomSheet() {
    _startHideTimer();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.speed_rounded,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text(
                  'Playback speed',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                trailing: Text(
                  '${widget.controller.value.playbackSpeed}x',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showPlaybackSpeedBottomSheet();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.hd_rounded,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text(
                  'Quality',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                trailing: Text(
                  _selectedQuality,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showQualityBottomSheet();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPlaybackSpeedBottomSheet() {
    final speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: speeds.length,
            itemBuilder: (context, index) {
              final speed = speeds[index];
              final isSelected = widget.controller.value.playbackSpeed == speed;
              return ListTile(
                leading: isSelected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).iconTheme.color,
                      )
                    : SizedBox(width: 24.w),
                title: Text(
                  speed == 1.0 ? 'Normal' : '${speed}x',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  context.read<VideoPlayerBloc>().add(VideoSpeedChanged(speed));
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showQualityBottomSheet() {
    final qualities = [
      '1080p Premium HD',
      '1080p60 HD',
      '720p60 HD',
      '480p',
      '360p',
      '240p',
      '144p',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: qualities.length,
            itemBuilder: (context, index) {
              final quality = qualities[index];
              final isSelected =
                  quality == _selectedQuality ||
                  (_selectedQuality.startsWith('Auto') &&
                      quality == '1080p60 HD');
              return ListTile(
                leading: isSelected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).iconTheme.color,
                      )
                    : SizedBox(width: 24.w),
                title: Text(
                  quality,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedQuality = quality;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Quality changed to $quality')),
                  );
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _toggleFullScreen() {
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _handleHorizontalDrag(DragUpdateDetails details) {
    // Scaffold simple seek on drag
    final double dx = details.delta.dx;
    final Duration currentPosition = widget.controller.value.position;
    final Duration newPosition =
        currentPosition + Duration(seconds: (dx / 5).round());
    if (newPosition.inSeconds >= 0 &&
        newPosition.inSeconds <= widget.controller.value.duration.inSeconds) {
      context.read<VideoPlayerBloc>().add(VideoSeekRequested(newPosition));
    }
  }

  void _handleVerticalDrag(DragUpdateDetails details, double screenWidth) {
    final double dy = details.delta.dy;
    // Drag down implies decrease (positive dy), drag up implies increase (negative dy)
    final double delta = -(dy / 200);

    if (details.globalPosition.dx < screenWidth / 2) {
      // Left side: Brightness
      context.read<VideoPlayerBloc>().add(VideoBrightnessGestureChanged(delta));
    } else {
      // Right side: Volume
      context.read<VideoPlayerBloc>().add(VideoVolumeGestureChanged(delta));
    }
    _startHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: _toggleControls,
      onHorizontalDragUpdate: _handleHorizontalDrag,
      onVerticalDragUpdate: (details) => _handleVerticalDrag(details, width),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: VideoPlayer(widget.controller),
            ),
          ),
          // Double-tap detectors (always active, translucent)
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: () => _onSideDoubleTap(true),
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: () => _onSideDoubleTap(false),
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
              ],
            ),
          ),
          // Seek Indicator Overlay
          if (_showSeekIndicator)
            Positioned(
              left: _isSeekForward ? null : 0,
              right: _isSeekForward ? 0 : null,
              top: 0,
              bottom: 0,
              child: Container(
                width: width / 3,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.horizontal(
                    left: _isSeekForward ? Radius.circular(100) : Radius.zero,
                    right: _isSeekForward ? Radius.zero : Radius.circular(100),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isSeekForward
                            ? Icons.fast_forward_rounded
                            : Icons.fast_rewind_rounded,
                        color: Colors.white,
                        size: 40.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '10 seconds',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !_showControls,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.black54),
                  Positioned(
                    top: 16.h,
                    right: 16.w,
                    child: IconButton(
                      icon: Icon(
                        Icons.settings_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                      onPressed: _showSettingsBottomSheet,
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 36,
                          color: Colors.white,
                          icon: const Icon(Icons.skip_previous_rounded),
                          onPressed: () {
                            _startHideTimer();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Previous video')),
                            );
                          },
                        ),
                        SizedBox(width: 24.w),
                        ValueListenableBuilder(
                          valueListenable: widget.controller,
                          builder: (context, VideoPlayerValue value, child) {
                            return IconButton(
                              iconSize: 56,
                              color: Colors.white,
                              icon: Icon(
                                value.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              onPressed: () {
                                _startHideTimer();
                                context.read<VideoPlayerBloc>().add(
                                  VideoPlayPauseToggled(),
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(width: 24.w),
                        IconButton(
                          iconSize: 36,
                          color: Colors.white,
                          icon: const Icon(Icons.skip_next_rounded),
                          onPressed: () {
                            _startHideTimer();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Next video')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.picture_in_picture_alt_rounded,
                                color: Colors.white,
                              ),

                              onPressed: () {
                                _startHideTimer();
                                context.read<VideoPlayerBloc>().add(
                                  VideoPipToggled(),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Picture-in-Picture activated',
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.fullscreen_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _startHideTimer();
                                _toggleFullScreen();
                              },
                            ),
                          ],
                        ),
                        ValueListenableBuilder(
                          valueListenable: widget.controller,
                          builder: (context, VideoPlayerValue value, child) {
                            final position = value.position;
                            final duration = value.duration;
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                      ),
                                      child: VideoProgressIndicator(
                                        widget.controller,
                                        allowScrubbing: true,
                                        colors: const VideoProgressColors(
                                          playedColor: Colors.red,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoInfoSection extends StatelessWidget {
  const _VideoInfoSection({required this.video});
  final Video video;

  String _formatViews(int views) {
    if (views >= 1000000) return '${(views / 1000000).toStringAsFixed(1)}M';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K';
    return views.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            '${_formatViews(video.views)} views • ${timeago.format(video.publishedAt)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelInfoSection extends StatelessWidget {
  const _ChannelInfoSection({required this.video});
  final Video video;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/channel/${video.channelId}');
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              backgroundImage: video.channelName.isNotEmpty
                  ? CachedNetworkImageProvider(
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(video.channelName)}&background=random&format=png',
                    )
                  : null,
              child: video.channelName.isEmpty
                  ? Icon(
                      Icons.person,
                      color: Theme.of(
                        context,
                      ).iconTheme.color?.withValues(alpha: 0.5),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.channelName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 15.sp,
                    ),
                  ),
                  Text(
                    '2.5M subscribers',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: const Text('Subscribe'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtonsSection extends StatefulWidget {
  const _ActionButtonsSection({required this.video});
  final Video video;

  @override
  State<_ActionButtonsSection> createState() => _ActionButtonsSectionState();
}

class _ActionButtonsSectionState extends State<_ActionButtonsSection>
    with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  late AnimationController _likeController;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _toggleLike() {
    setState(() => _isLiked = !_isLiked);
    if (_isLiked) {
      _likeController.forward(from: 0.0);
    }
  }

  Future<void> _startDownload() async {
    context.read<DownloadManagerCubit>().queueDownload(
      videoId: widget.video.id,
      title: widget.video.title,
      sourceUrl: widget.video.videoUrl,
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          _ActionButton(
            icon: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.3).animate(
                CurvedAnimation(
                  parent: _likeController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Icon(
                _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                size: 20.sp,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            label: '125K',
            onTap: _toggleLike,
          ),
          SizedBox(width: 8.w),
          _ActionButton(
            icon: Icon(
              Icons.share_outlined,
              size: 20.sp,
              color: Theme.of(context).iconTheme.color,
            ),
            label: 'Share',
            onTap: () {
              Share.share(
                'Check out this awesome video: ${widget.video.videoUrl}',
              );
            },
          ),
          SizedBox(width: 8.w),
          BlocBuilder<DownloadManagerCubit, DownloadManagerState>(
            builder: (context, state) {
              final id = widget.video.id;
              final item = state.downloads
                  .where((e) => e.videoId == id)
                  .firstOrNull;

              final isDownloading =
                  item?.status == DownloadStatus.downloading ||
                  item?.status == DownloadStatus.queued ||
                  item?.status == DownloadStatus.encrypting;
              final progress = item?.progress ?? 0.0;
              final isCompleted = item?.status == DownloadStatus.completed;

              return _ActionButton(
                icon: isDownloading
                    ? SizedBox(
                        width: 20.sp,
                        height: 20.sp,
                        child: CircularProgressIndicator(
                          value: progress > 0 ? progress : null,
                          strokeWidth: 2,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      )
                    : Icon(
                        isCompleted
                            ? Icons.download_done
                            : Icons.download_outlined,
                        size: 20.sp,
                        color: isCompleted
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).iconTheme.color,
                      ),
                label: isDownloading
                    ? '${(progress * 100).toInt()}%'
                    : isCompleted
                    ? 'Downloaded'
                    : 'Download',
                onTap: isCompleted ? () {} : _startDownload,
              );
            },
          ),
          SizedBox(width: 8.w),
          _ActionButton(
            icon: Icon(
              Icons.library_add_outlined,
              size: 20.sp,
              color: Theme.of(context).iconTheme.color,
            ),
            label: 'Save',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionSection extends StatefulWidget {
  const _DescriptionSection();

  @override
  State<_DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<_DescriptionSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1.2M views  2 months ago',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'This is a description for the video. It can be quite long, so we truncate it initially and let the user expand it to read more details about the content, links, and timestamps.',
              maxLines: _isExpanded ? null : 2,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            if (!_isExpanded)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  '...more',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CommentsSection extends StatefulWidget {
  const _CommentsSection({required this.videoId});
  final String videoId;

  @override
  State<_CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<_CommentsSection> {
  bool _isLoading = true;
  String? _error;
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final getComments = sl<GetComments>();
    final result = await getComments(GetCommentsParams(widget.videoId));

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _error = failure.message;
        });
      },
      (comments) {
        setState(() {
          _isLoading = false;
          _comments = comments;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Text(
          'Failed to load comments.',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      );
    }

    if (_comments.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Text(
          'No comments yet.',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comments',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 12.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: comment.authorProfileImageUrl,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 16.r,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) => CircleAvatar(
                        radius: 16.r,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        radius: 16.r,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.person, size: 16.sp),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                comment.authorName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.sp,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                timeago.format(comment.publishedAt),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            comment.textDisplay,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.thumb_up_alt_outlined,
                                size: 14.sp,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                comment.likeCount > 0
                                    ? comment.likeCount.toString()
                                    : '',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Icon(
                                Icons.thumb_down_alt_outlined,
                                size: 14.sp,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UpNextSection extends StatelessWidget {
  const _UpNextSection();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: 'https://picsum.photos/seed/picsum/160/90',
                  width: 160.w,
                  height: 90.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        FontAwesomeIcons.youtube,
                        color: Colors.red.withValues(alpha: 0.5),
                        size: 30.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Up Next Video $index',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Channel Name\n100K views • 1 day ago',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
