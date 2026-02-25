import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _videos = [];

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    setState(() => _isLoading = true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _videos = [
        {
          'title': 'The Beauty of Existence - Heart Touching Nasheed',
          'channel': 'Awesome Channel',
          'views': 19210251,
          'publishedAt': DateTime.now().subtract(const Duration(days: 365 * 5)),
          'thumb': 'https://picsum.photos/id/392/1280/720',
          'url':
              'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          'avatar': 'https://picsum.photos/id/1005/200/200',
          'duration': '4:20',
        },
        {
          'title': 'Flutter 2026 Ultimate Guide',
          'channel': 'Flutter Guru',
          'views': 150000,
          'publishedAt': DateTime.now().subtract(const Duration(days: 2)),
          'thumb': 'https://picsum.photos/id/20/1280/720',
          'url':
              'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
          'avatar': 'https://picsum.photos/id/21/200/200',
          'duration': '15:30',
        },
        {
          'title': 'Building an aesthetic YouTube Clone',
          'channel': 'CodeMaster',
          'views': 54300,
          'publishedAt': DateTime.now().subtract(const Duration(hours: 5)),
          'thumb': 'https://picsum.photos/id/3/1280/720',
          'url':
              'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          'avatar': 'https://picsum.photos/id/4/200/200',
          'duration': '1:12:05',
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _fetchVideos,
        color: Colors.red,
        child: ListView.builder(
          key: const PageStorageKey('home_feed_storage'),
          itemCount: _isLoading
              ? 3
              : _videos.length + 1, // +1 for the categories bar
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildCategoriesBar();
            }

            if (_isLoading) {
              return const _VideoCardShimmer();
            }

            final video = _videos[index - 1];
            return _VideoCard(video: video);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.play_circle_filled, color: Colors.red, size: 28.sp),
          SizedBox(width: 8.w),
          Text(
            'YouTube',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.cast, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {},
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
              Icon(Icons.explore_outlined, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Explore',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
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

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video});

  final Map<String, dynamic> video;

  String _formatViews(int views) {
    if (views >= 1000000)
      return '${(views / 1000000).toStringAsFixed(1)}M views';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K views';
    return '$views views';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/watch',
          extra: {'videoUrl': video['url'], 'title': video['title']},
        );
      },
      child: Column(
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: video['thumb'],
                height: 220.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[300]),
                errorWidget: (context, url, error) => const Icon(Icons.error),
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
                    video['duration'],
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
                  backgroundImage: CachedNetworkImageProvider(video['avatar']),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video['title'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${video['channel']} • ${_formatViews(video['views'])} • ${timeago.format(video['publishedAt'])}',
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
                Icon(Icons.more_vert, size: 20.sp, color: Colors.grey[700]),
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
