import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/channel.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/get_channel_details.dart';
import '../../domain/usecases/search_videos.dart';
import '../../injection_container.dart';
import 'home_feed_page.dart';

class ChannelProfilePage extends StatefulWidget {
  final String channelId;

  const ChannelProfilePage({super.key, required this.channelId});

  @override
  State<ChannelProfilePage> createState() => _ChannelProfilePageState();
}

class _ChannelProfilePageState extends State<ChannelProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Channel? _channel;
  List<Vido> _videos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final getChannelDetails = sl<GetChannelDetails>();
    final searchVideos = sl<SearchVideos>();

    final channelResult = await getChannelDetails(widget.channelId);

    if (!mounted) return;

    channelResult.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _error = failure.message;
        });
      },
      (channel) async {
        setState(() => _channel = channel);

        // Fetch channel videos using search API
        final videosResult = await searchVideos(
          SearchVideosParams(query: channel.title),
        );

        if (!mounted) return;

        videosResult.fold((failure) => null, (paginatedVideos) {
          setState(() {
            _videos = paginatedVideos.videos;
            _isLoading = false;
          });
        });
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (_error != null || _channel == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? 'Unknown error')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.h,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              foregroundColor: Theme.of(context).iconTheme.color,
              actions: [
                IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  children: [
                    if (_channel?.bannerUrl != null)
                      CachedNetworkImage(
                        imageUrl: _channel!.bannerUrl!,
                        height: 100.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        height: 100.h,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildChannelHeader()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                  unselectedLabelColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                  indicatorColor: Theme.of(context).textTheme.bodyLarge?.color,
                  indicatorWeight: 2,
                  tabs: const [
                    Tab(text: 'HOME'),
                    Tab(text: 'VIDEOS'),
                    Tab(text: 'SHORTS'),
                    Tab(text: 'LIVE'),
                    Tab(text: 'PLAYLISTS'),
                    Tab(text: 'COMMUNITY'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildVideosTab(),
            _buildVideosTab(),
            const Center(child: Text('Shorts')),
            const Center(child: Text('Live')),
            const Center(child: Text('Playlists')),
            const Center(child: Text('Community')),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundImage: CachedNetworkImageProvider(_channel!.thumbnailUrl),
          ),
          SizedBox(height: 12.h),
          Text(
            _channel!.title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${_formatSubscribers(_channel!.subscriberCount)} subscribers',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).textTheme.bodyLarge?.color,
              foregroundColor: Theme.of(context).scaffoldBackgroundColor,
              minimumSize: Size(double.infinity, 36.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }

  Widget _buildVideosTab() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        return VideoCard(video: _videos[index]);
      },
    );
  }

  String _formatSubscribers(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
