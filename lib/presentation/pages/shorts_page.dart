import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../domain/entities/video.dart';
import '../../domain/usecases/get_home_videos.dart';
import '../../domain/usecases/get_shorts.dart';
import '../../injection_container.dart';
import '../bloc/video_player/video_player_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShortsPage extends StatefulWidget {
  static const route = '/shorts';
  const ShortsPage({super.key});

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  final PageController _pageController = PageController();

  bool _isLoading = true;
  bool _isFetchingNextPage = false;
  String? _error;
  String? _nextPageToken;
  List<Video> _shorts = [];

  @override
  void initState() {
    super.initState();
    _fetchShorts();
  }

  Future<void> _fetchShorts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final getShorts = sl<GetShorts>();
    final result = await getShorts(const GetHomeVideosParams());

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _error = failure.message;
        });
      },
      (paginatedVideos) {
        setState(() {
          _isLoading = false;
          _shorts = paginatedVideos.videos;
          _nextPageToken = paginatedVideos.nextPageToken;
        });
      },
    );
  }

  Future<void> _fetchNextPage() async {
    if (_isFetchingNextPage ||
        _nextPageToken == null ||
        _isLoading ||
        _error != null) {
      return;
    }

    setState(() => _isFetchingNextPage = true);

    final getShorts = sl<GetShorts>();
    final result = await getShorts(
      GetHomeVideosParams(pageToken: _nextPageToken),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isFetchingNextPage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more shorts: ${failure.message}'),
          ),
        );
      },
      (paginatedVideos) {
        setState(() {
          _isFetchingNextPage = false;
          _shorts.addAll(paginatedVideos.videos);
          _nextPageToken = paginatedVideos.nextPageToken;
        });
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 64.sp),
                    SizedBox(height: 16.h),
                    Text(
                      'Something went wrong',
                      style: TextStyle(color: Colors.white, fontSize: 18.sp),
                    ),
                    SizedBox(height: 8.h),
                    ElevatedButton(
                      onPressed: _fetchShorts,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: _shorts.length,
                    onPageChanged: (index) {
                      if (index == _shorts.length - 2) {
                        _fetchNextPage();
                      }
                    },
                    itemBuilder: (context, index) {
                      return _ShortVideoPlayer(shortData: _shorts[index]);
                    },
                  ),
                  Positioned(
                    top: 16.h,
                    right: 16.w,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            FontAwesomeIcons.magnifyingGlass,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {},
                        ),
                        SizedBox(width: 8.w),
                        IconButton(
                          icon: const Icon(
                            FontAwesomeIcons.camera,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {},
                        ),
                        SizedBox(width: 8.w),
                        IconButton(
                          icon: const Icon(
                            FontAwesomeIcons.ellipsisVertical,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ShortVideoPlayer extends StatefulWidget {
  const _ShortVideoPlayer({required this.shortData});
  final Video shortData;

  @override
  State<_ShortVideoPlayer> createState() => _ShortVideoPlayerState();
}

class _ShortVideoPlayerState extends State<_ShortVideoPlayer> {
  late VideoPlayerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<VideoPlayerBloc>()
      ..add(VideoInitialized(widget.shortData.videoUrl));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () {
              _bloc.add(VideoPlayPauseToggled());
            },
            child: BlocBuilder<VideoPlayerBloc, VideoPlayerAppState>(
              builder: (context, state) {
                if (state.status == VideoPlayerStatus.loading ||
                    state.controller == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                final controller = state.controller!;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                    if (!controller.value.isPlaying)
                      const Center(
                        child: Icon(
                          FontAwesomeIcons.play,
                          color: Colors.white60,
                          size: 80,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Right action bar
          Positioned(
            right: 12.w,
            bottom: 20.h,
            child: _ShortsActionBar(shortData: widget.shortData),
          ),

          // Bottom info overlay
          Positioned(
            left: 16.w,
            bottom: 20.h,
            right: 80.w, // Leave space for action bar
            child: _ShortsInfoOverlay(shortData: widget.shortData),
          ),

          // Custom Bottom Progress Bar specific to Shorts
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BlocBuilder<VideoPlayerBloc, VideoPlayerAppState>(
              builder: (context, state) {
                if (state.controller == null) return const SizedBox.shrink();
                return VideoProgressIndicator(
                  state.controller!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.red,
                    bufferedColor: Colors.white30,
                    backgroundColor: Colors.transparent,
                  ),
                  padding: EdgeInsets.zero,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortsActionBar extends StatelessWidget {
  const _ShortsActionBar({required this.shortData});
  final Video shortData;

  String _formatNumber(int num) {
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return num.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionItem(
          icon: FontAwesomeIcons.thumbsUp,
          label: _formatNumber(shortData.views ~/ 10),
        ), // Simulated likes
        SizedBox(height: 16.h),
        _ActionItem(icon: FontAwesomeIcons.thumbsDown, label: 'Dislike'),
        SizedBox(height: 16.h),
        _ActionItem(
          icon: FontAwesomeIcons.comment,
          label: _formatNumber(shortData.views ~/ 100), // Simulated comments
        ),
        SizedBox(height: 16.h),
        _ActionItem(icon: FontAwesomeIcons.share, label: 'Share'),
        SizedBox(height: 16.h),
        _ActionItem(icon: FontAwesomeIcons.retweet, label: 'Remix'),
        SizedBox(height: 24.h),
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(shortData.channelName)}&background=random&format=png',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 32.sp),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ShortsInfoOverlay extends StatelessWidget {
  const _ShortsInfoOverlay({required this.shortData});
  final Video shortData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundImage: CachedNetworkImageProvider(
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(shortData.channelName)}&background=random&format=png',
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              shortData.channelName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                'Subscribe',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          shortData.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            shadows: const [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black54,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Icon(FontAwesomeIcons.music, color: Colors.white, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              'Original Sound - ${shortData.channelName}',
              style: TextStyle(color: Colors.white, fontSize: 13.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }
}
