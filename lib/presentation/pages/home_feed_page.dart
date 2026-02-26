import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/youtube_icons.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/get_home_videos.dart';
import '../../injection_container.dart';
import 'search_page.dart';

class HomeFeedPage extends StatefulWidget {
  static const route = '/home';
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  bool _isLoading = true;
  bool _isFetchingNextPage = false;
  String? _error;
  String? _nextPageToken;
  List<Video> _videos = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchVideos();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchNextPage();
    }
  }

  Future<void> _fetchVideos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final getHomeVideos = sl<GetHomeVideos>();
    final result = await getHomeVideos(const GetHomeVideosParams());

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
          _videos = paginatedVideos.videos;
          _nextPageToken = paginatedVideos.nextPageToken;
        });
      },
    );
  }

  Future<void> _fetchNextPage() async {
    if (_isFetchingNextPage ||
        _nextPageToken == null ||
        _isLoading ||
        _error != null)
      return;

    setState(() => _isFetchingNextPage = true);

    final getHomeVideos = sl<GetHomeVideos>();
    final result = await getHomeVideos(
      GetHomeVideosParams(pageToken: _nextPageToken),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isFetchingNextPage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more videos: ${failure.message}'),
          ),
        );
      },
      (paginatedVideos) {
        setState(() {
          _isFetchingNextPage = false;
          _videos.addAll(paginatedVideos.videos);
          _nextPageToken = paginatedVideos.nextPageToken;
        });
      },
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            _error ?? 'Unknown error',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _fetchVideos,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _error != null
          ? _buildErrorView()
          : RefreshIndicator(
              onRefresh: _fetchVideos,
              color: Colors.red,
              child: ListView.builder(
                controller: _scrollController,
                key: const PageStorageKey('home_feed_storage'),
                itemCount: _isLoading
                    ? 3
                    : _videos.length +
                          2 +
                          (_isFetchingNextPage
                              ? 1
                              : 0), // +1 for categories, +1 for Shorts, +1 for loading indicator
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildCategoriesBar();
                  }

                  if (_isLoading) {
                    return const _VideoCardShimmer();
                  }

                  if (index == 2) {
                    return _buildShortsShelf();
                  }

                  if (index == _videos.length + 2) {
                    return Padding(
                      padding: EdgeInsets.all(16.h),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      ),
                    );
                  }

                  final videoIndex = index > 2 ? index - 2 : index - 1;
                  final video = _videos[videoIndex];
                  return VideoCard(video: video);
                },
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Image.network(
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/YouTube_Logo_2017.svg/512px-YouTube_Logo_2017.svg.png',
        height: 22.h,
      ),
      actions: [
        IconButton(
          icon: const Icon(FontAwesomeIcons.chromecast, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(FontAwesomeIcons.bell, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            FontAwesomeIcons.magnifyingGlass,
            color: Colors.black,
          ),
          onPressed: () => context.push(SearchPage.route),
        ),
        Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: CircleAvatar(
            radius: 14.r,
            backgroundImage: const NetworkImage(
              'https://picsum.photos/id/1027/100/100',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesBar() {
    return Container(
      height: 48.h,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.compass, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Explore',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          VerticalDivider(
            width: 1.w,
            thickness: 1,
            color: const Color(0xFFD6D6D6),
          ),
          SizedBox(width: 12.w),
          const _TopicChip(label: 'All', selected: true),
          SizedBox(width: 8.w),
          const _TopicChip(label: 'Flutter'),
          SizedBox(width: 8.w),
          const _TopicChip(label: 'Music'),
          SizedBox(width: 8.w),
          const _TopicChip(label: 'Live'),
        ],
      ),
    );
  }

  Widget _buildShortsShelf() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          child: Row(
            children: [
              SvgPicture.string(
                YoutubeIcons.shortsFilled,
                width: 24.sp,
                height: 24.sp,
                colorFilter: const ColorFilter.mode(
                  Colors.red,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Shorts',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Icon(
                FontAwesomeIcons.ellipsisVertical,
                size: 20.sp,
                color: Colors.black,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: [
              _buildShortCard(
                title: 'ഇങ്ങനൊരു ❤️ soulmate നിങ്ങൾക്കുണ്ടോ ? #com...',
                views: '1.2M views',
                thumbUrl: 'https://picsum.photos/id/64/300/400',
              ),
              SizedBox(width: 12.w),
              _buildShortCard(
                title: 'Iron-Spider Attack Dr Octopuss hidden things #s...',
                views: '540K views',
                thumbUrl: 'https://picsum.photos/id/65/300/400',
              ),
              SizedBox(width: 12.w),
              _buildShortCard(
                title: 'അവകാശികളില്ലാതെ ആർക്കും വേണ്ടാതെ 2000...',
                views: '890K views',
                thumbUrl: 'https://picsum.photos/id/66/300/400',
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Divider(thickness: 4.h, color: Colors.grey[200], height: 4.h),
      ],
    );
  }

  Widget _buildShortCard({
    required String title,
    required String views,
    required String thumbUrl,
  }) {
    return SizedBox(
      width: 160.w,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: CachedNetworkImage(
              imageUrl: thumbUrl,
              height: 280.h,
              width: 160.w,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Icon(
              FontAwesomeIcons.ellipsisVertical,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          Positioned(
            bottom: 8.h,
            left: 8.w,
            right: 8.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black87, blurRadius: 4),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  views,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black87, blurRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? Colors.black : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? Colors.black : const Color(0xFFCECECE),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: selected ? Colors.white : Colors.black,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  const VideoCard({super.key, required this.video});

  final Video video;

  String _formatViews(int views) {
    if (views >= 1000000)
      return '${(views / 1000000).toStringAsFixed(1)}M views';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K views';
    return '$views views';
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds == 0) return '';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/watch',
          extra: {
            'videoUrl': video.videoUrl,
            'title': video.title,
            'id': video.id,
          },
        );
      },
      child: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: 'video_thumb_${video.id}',
                child: Material(
                  color: Colors.transparent,
                  child: CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    height: 220.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[300]),
                    errorWidget: (context, url, error) =>
                        const Icon(FontAwesomeIcons.circleExclamation),
                  ),
                ),
              ),
              Positioned(
                bottom: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _formatDuration(video.duration),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: CachedNetworkImageProvider(
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(video.channelName)}&background=random&format=png',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${video.channelName} • ${_formatViews(video.views)} • ${timeago.format(video.publishedAt)}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  FontAwesomeIcons.ellipsisVertical,
                  size: 20.sp,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoCardShimmer extends StatelessWidget {
  const _VideoCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(height: 220.h, width: double.infinity, color: Colors.white),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 20.r, backgroundColor: Colors.white),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16.h,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 16.h,
                        width: 200.w,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(height: 20.h, width: 20.w, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
