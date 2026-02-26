import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../domain/entities/comment.dart';
import '../../domain/usecases/get_comments.dart';

import '../../injection_container.dart';
import '../bloc/video_player/video_player_bloc.dart';

class WatchPage extends StatelessWidget {
  static const route = '/watch';
  const WatchPage({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.id,
  });

  final String videoUrl;
  final String title;
  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VideoPlayerBloc>()..add(VideoInitialized(videoUrl)),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _VideoPlayerSection(title: title, id: id),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _VideoInfoSection(title: title),
                    const _ChannelInfoSection(),
                    _ActionButtonsSection(videoUrl: videoUrl),
                    const _DescriptionSection(),
                    Divider(height: 1.h, color: Colors.grey[300]),
                    _CommentsSection(videoId: id),
                    Divider(height: 1.h, color: Colors.grey[300]),
                    const _UpNextSection(),
                  ],
                ),
              ),
            ],
          ),
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
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.red),
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
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: GestureDetector(
                    onTap: () => context.read<VideoPlayerBloc>().add(
                      VideoPlayPauseToggled(),
                    ),
                    child: VideoPlayer(controller),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(playedColor: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
              color: Colors.black,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            '1.2M views • 2 months ago',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

class _ChannelInfoSection extends StatelessWidget {
  const _ChannelInfoSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundImage: const NetworkImage(
              'https://picsum.photos/id/1005/200/200',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Awesome Channel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 15.sp,
                  ),
                ),
                Text(
                  '2.5M subscribers',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: const Text('Subscribe'),
          ),
        ],
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
                color: _isLiked ? Colors.black : Colors.black,
              ),
            ),
            label: '125K',
            onTap: _toggleLike,
          ),
          SizedBox(width: 8.w),
          _ActionButton(
            icon: Icon(Icons.share_outlined, size: 20.sp, color: Colors.black),
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
                      color: Colors.black,
                    ),
                  )
                : Icon(
                    Icons.download_outlined,
                    size: 20.sp,
                    color: Colors.black,
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
              color: Colors.black,
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
          color: Colors.grey[200],
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
                color: Colors.black,
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
          color: Colors.grey[200],
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
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'This is a description for the video. It can be quite long, so we truncate it initially and let the user expand it to read more details about the content, links, and timestamps.',
              maxLines: _isExpanded ? null : 2,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.sp, color: Colors.black87),
            ),
            if (!_isExpanded)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  '...more',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: Colors.black,
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
        child: const Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Text(
          'Failed to load comments.',
          style: TextStyle(color: Colors.grey[700]),
        ),
      );
    }

    if (_comments.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Text(
          'No comments yet.',
          style: TextStyle(color: Colors.grey[700]),
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
              color: Colors.black,
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
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                timeago.format(comment.publishedAt),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            comment.textDisplay,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.thumb_up_alt_outlined,
                                size: 14.sp,
                                color: Colors.grey[700],
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                comment.likeCount > 0
                                    ? comment.likeCount.toString()
                                    : '',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Icon(
                                Icons.thumb_down_alt_outlined,
                                size: 14.sp,
                                color: Colors.grey[700],
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
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Channel Name\n100K views • 1 day ago',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
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
