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

import '../../domain/entities/comment.dart';
import '../../domain/usecases/get_comments.dart';

import '../../injection_container.dart';
import '../bloc/video_player/video_player_bloc.dart';

class WatchPage extends StatefulWidget {
  static const route = '/watch';
  const WatchPage({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.id,
    this.channelName,
    this.channelId,
  });

  final String videoUrl;
  final String title;
  final String id;
  final String? channelName;
  final String? channelId;

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
          sl<VideoPlayerBloc>()..add(VideoInitialized(widget.videoUrl)),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return Container(
                color: Colors.black,
                child: Center(
                  child: _VideoPlayerSection(
                    title: widget.title,
                    id: widget.id,
                  ),
                ),
              );
            }
            return SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _VideoPlayerSection(title: widget.title, id: widget.id),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _VideoInfoSection(title: widget.title),
                        _ChannelInfoSection(
                          channelName: widget.channelName,
                          channelId: widget.channelId,
                        ),
                        _ActionButtonsSection(videoUrl: widget.videoUrl),
                        const _DescriptionSection(),
                        Divider(
                          height: 1.h,
                          color: Theme.of(context).dividerColor,
                        ),
                        _CommentsSection(videoId: widget.id),
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
  const _VideoPlayerSection({required this.title, required this.id});
  final String title;
  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerBloc, VideoPlayerAppState>(
      builder: (context, state) {
        if (state.status == VideoPlayerStatus.loading) {
          return Hero(
            tag: 'video_thumb_$id',
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
          tag: 'video_thumb_$id',
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
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.speed_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    _startHideTimer();
                                    final currentSpeed =
                                        widget.controller.value.playbackSpeed;
                                    final newSpeed = currentSpeed >= 2.0
                                        ? 0.5
                                        : currentSpeed + 0.25;
                                    context.read<VideoPlayerBloc>().add(
                                      VideoSpeedChanged(newSpeed),
                                    );
                                  },
                                ),
                                ValueListenableBuilder(
                                  valueListenable: widget.controller,
                                  builder:
                                      (context, VideoPlayerValue value, child) {
                                        return Text(
                                          '${value.playbackSpeed}x',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                          ),
                                        );
                                      },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.hd_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    _startHideTimer();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Quality changed to 1080p',
                                        ),
                                      ),
                                    );
                                  },
                                ),
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
  const _VideoInfoSection({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
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
            '1.2M views • 2 months ago',
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
  const _ChannelInfoSection({this.channelName, this.channelId});
  final String? channelName;
  final String? channelId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (channelId != null) {
          context.push('/channel/$channelId');
        }
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
              backgroundImage: channelName != null && channelName!.isNotEmpty
                  ? CachedNetworkImageProvider(
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(channelName!)}&background=random&format=png',
                    )
                  : null,
              child: channelName == null || channelName!.isEmpty
                  ? Icon(
                      Icons.person,
                      color: Theme.of(
                        context,
                      ).iconTheme.color?.withOpacity(0.5),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channelName ?? 'Unknown Channel',
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
  const _ActionButtonsSection({required this.videoUrl});
  final String videoUrl;

  @override
  State<_ActionButtonsSection> createState() => _ActionButtonsSectionState();
}

class _ActionButtonsSectionState extends State<_ActionButtonsSection>
    with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  late AnimationController _likeController;

  bool _isDownloading = false;
  double _downloadProgress = 0.0;

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
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    // Simulate download progress
    for (int i = 1; i <= 100; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 30));
      setState(() {
        _downloadProgress = i / 100.0;
      });
    }

    if (!mounted) return;
    setState(() => _isDownloading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Download complete!')));
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
              Share.share('Check out this awesome video: ${widget.videoUrl}');
            },
          ),
          SizedBox(width: 8.w),
          _ActionButton(
            icon: _isDownloading
                ? SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: CircularProgressIndicator(
                      value: _downloadProgress,
                      strokeWidth: 2,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  )
                : Icon(
                    Icons.download_outlined,
                    size: 20.sp,
                    color: Theme.of(context).iconTheme.color,
                  ),
            label: _isDownloading
                ? '${(_downloadProgress * 100).toInt()}%'
                : 'Download',
            onTap: _startDownload,
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
          ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
          ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                    CircleAvatar(
                      radius: 16.r,
                      backgroundImage: NetworkImage(
                        comment.authorProfileImageUrl,
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
              Container(
                width: 160.w,
                height: 90.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://picsum.photos/seed/picsum/160/90',
                    ),
                    fit: BoxFit.cover,
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
