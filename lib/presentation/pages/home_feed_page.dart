import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youtube_clone/presentation/pages/shorts_page.dart';
import '../../core/constants/youtube_icons.dart';
import '../../core/usecases/usecase.dart';
import '../../core/utils/image_extensions.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/video_category.dart';
import '../../domain/usecases/get_home_videos.dart';
import '../../domain/usecases/get_shorts.dart';
import '../../domain/usecases/get_video_categories.dart';
import '../../injection_container.dart';
import '../widgets/short_card.dart';
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
  List<Vido> _videos = [];
  List<VideoCategory> _categories = [];
  String _selectedCategoryId = '0';
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingShorts = true;
  List<Vido> _shorts = [];
  String? _shortsNextPageToken;

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndVideos();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchCategoriesAndVideos() async {
    await Future.wait([_fetchCategories(), _fetchVideos(), _fetchShorts()]);
  }

  Future<void> _fetchCategories() async {
    final getCategories = sl<GetVideoCategories>();
    final result = await getCategories(const NoParams());
    if (!mounted) return;

    result.fold((failure) => null, (categories) {
      setState(() {
        _categories = categories;
      });
    });
  }

  Future<void> _fetchShorts() async {
    final getShorts = sl<GetShorts>();
    final result = await getShorts(const GetHomeVideosParams());

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoadingShorts = false;
        });
      },
      (paginatedVideos) {
        setState(() {
          _isLoadingShorts = false;
          _shorts = paginatedVideos.videos;
          _shortsNextPageToken = paginatedVideos.nextPageToken;
        });
      },
    );
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
    final result = await getHomeVideos(
      GetHomeVideosParams(
        categoryId: _selectedCategoryId == '0' ? null : _selectedCategoryId,
      ),
    );

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
        _error != null) {
      return;
    }

    setState(() => _isFetchingNextPage = true);

    final getHomeVideos = sl<GetHomeVideos>();
    final result = await getHomeVideos(
      GetHomeVideosParams(
        pageToken: _nextPageToken,
        categoryId: _selectedCategoryId == '0' ? null : _selectedCategoryId,
      ),
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
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 48.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            _error!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _fetchCategoriesAndVideos,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _error != null
          ? _buildErrorView()
          : RefreshIndicator(
              onRefresh: _fetchVideos,
              color: Theme.of(context).colorScheme.primary,
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
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      title: Image.asset(
        Theme.of(context).brightness == Brightness.dark
            ? 'youtube_icon_with_white_title'.webpImages
            : 'youtube_icon_with_black_title'.webpImages,
        height: 22.h,
      ),
      actions: [
        IconButton(
          icon: Icon(
            FontAwesomeIcons.chromecast,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            FontAwesomeIcons.bell,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            FontAwesomeIcons.magnifyingGlass,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => context.push(SearchPage.route),
        ),
        SizedBox(width: 8.w),
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
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        children: [
          Row(
            children: [
              Icon(
                Icons.explore_outlined,
                size: 20.sp,
                color: Theme.of(context).iconTheme.color,
              ),
              SizedBox(width: 8.w),
              Text(
                'Explore',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          VerticalDivider(
            width: 1.w,
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          SizedBox(width: 12.w),
          _TopicChip(
            label: 'All',
            selected: _selectedCategoryId == '0',
            onTap: () {
              if (_selectedCategoryId != '0') {
                setState(() => _selectedCategoryId = '0');
                _fetchVideos();
              }
            },
          ),
          ..._categories.map((category) {
            return Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: _TopicChip(
                label: category.title,
                selected: _selectedCategoryId == category.id,
                onTap: () {
                  if (_selectedCategoryId != category.id) {
                    setState(() => _selectedCategoryId = category.id);
                    _fetchVideos();
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildShortsShelf() {
    if (_isLoadingShorts) {
      return SizedBox(
        height: 300.h,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (_shorts.isEmpty) {
      return const SizedBox.shrink();
    }

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
                  Color(0xFFFF0000),
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
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Icon(
                FontAwesomeIcons.ellipsisVertical,
                size: 20.sp,
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: _shorts.asMap().entries.map((entry) {
              final index = entry.key;
              final short = entry.value;
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: ShortCard(
                  title: short.title,
                  views: '${_formatViewsShorts(short.views)} views',
                  thumbUrl: short.thumbnailUrl,
                  onTap: () {
                    context.push(
                      ShortsPage.route,
                      extra: {
                        'initialVideos': _shorts,
                        'initialIndex': index,
                        'nextPageToken': _shortsNextPageToken,
                      },
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 16.h),
        Divider(
          thickness: 4.h,
          color: Theme.of(context).dividerColor,
          height: 4.h,
        ),
      ],
    );
  }

  String _formatViewsShorts(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    }
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K';
    return views.toString();
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.label, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.inverseSurface
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.inverseSurface
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: selected
                  ? Theme.of(context).colorScheme.onInverseSurface
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  const VideoCard({super.key, required this.video});

  final Vido video;

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M views';
    }
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
            'channelName': video.channelName,
            'channelId': video.channelId,
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
                    placeholder: (context, url) => Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                    errorWidget: (context, url, error) => Icon(
                      FontAwesomeIcons.circleExclamation,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _formatDuration(video.duration),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
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
                GestureDetector(
                  onTap: () => context.push('/channel/${video.channelId}'),
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundImage: CachedNetworkImageProvider(
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(video.channelName)}&background=random&format=png',
                    ),
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
                          color: Theme.of(context).textTheme.bodyLarge?.color,
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  color: Theme.of(context).iconTheme.color,
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
