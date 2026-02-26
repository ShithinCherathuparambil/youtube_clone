import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/youtube_icons.dart';
import '../../core/usecases/usecase.dart';
import '../../core/utils/image_extensions.dart';
import '../../domain/entities/channel.dart';
import '../../domain/usecases/get_popular_channels.dart';
import '../../injection_container.dart';
import 'search_page.dart';

class SubscriptionsPage extends StatefulWidget {
  static const route = '/subscriptions';
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  bool _isLoadingChannels = true;
  String? _channelsError;
  List<Channel> _channels = [];

  @override
  void initState() {
    super.initState();
    _fetchChannels();
  }

  Future<void> _fetchChannels() async {
    final getChannels = sl<GetPopularChannels>();
    final result = await getChannels(NoParams());

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isLoadingChannels = false;
        _channelsError = failure.message;
      }),
      (channels) => setState(() {
        _isLoadingChannels = false;
        _channels = channels;
      }),
    );
  }

  final List<String> _filters = [
    'All',
    'Today',
    'Videos',
    'Shorts',
    'Live',
    'Podcasts',
  ];
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChannelList(),
            _buildFilterChips(),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Text(
                'Most relevant',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            _buildVideoGrid(),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
              child: Row(
                children: [
                  SvgPicture.string(
                    YoutubeIcons.shortsFilled,
                    width: 24.sp,
                    height: 24.sp,
                    colorFilter: ColorFilter.mode(
                      Color(0xFFFF0000),
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Shorts',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            _buildShortsGrid(),
            Divider(
              thickness: 4.h,
              color: Theme.of(context).dividerColor,
              height: 32.h,
            ),
            _buildPostShortsVideo(),
            Padding(
              padding: EdgeInsets.only(top: 24.h),
              child: _buildRelevantVideoCard(
                title: 'Building India\'s Smart Ports',
                channel: 'btTV',
                views: '4.5K views',
                time: '2 hours ago',
                duration: '45:12',
                thumbUrl: 'https://picsum.photos/id/1023/400/225',
              ),
            ),
            SizedBox(height: 20.h),
          ],
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
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                FontAwesomeIcons.bell,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {},
            ),
            Positioned(
              top: 10.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '9+',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            FontAwesomeIcons.magnifyingGlass,
            color: Theme.of(context).iconTheme.color,
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

  Widget _buildChannelList() {
    if (_isLoadingChannels) {
      return SizedBox(
        height: 100.h,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (_channelsError != null) {
      return SizedBox(
        height: 100.h,
        child: Center(
          child: Text(
            'Error loading channels',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        itemCount: _channels.length + 1,
        itemBuilder: (context, index) {
          if (index == _channels.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'All',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            );
          }

          final channel = _channels[index];
          return Container(
            width: 72.w,
            margin: EdgeInsets.only(right: 4.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      backgroundImage: channel.thumbnailUrl.isNotEmpty
                          ? CachedNetworkImageProvider(channel.thumbnailUrl)
                          : null,
                      child: channel.thumbnailUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              color: Theme.of(
                                context,
                              ).iconTheme.color?.withOpacity(0.5),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  channel.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 40.h,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        itemCount: _filters.length + 1,
        itemBuilder: (context, index) {
          if (index == _filters.length) {
            return GestureDetector(
              onTap: () {},
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            );
          }

          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.inverseSurface
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onInverseSurface
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildRelevantVideoCard(
              title: 'ഭൂമിയിലെ ഏറ്റവും വലിയ ബാധ്യത ഉയരമാണ് | Height Explained',
              channel: 'JR STUDIO Sci-Talk Malayalam',
              views: '58K views',
              time: '5 days ago',
              duration: '12:02',
              thumbUrl: 'https://picsum.photos/id/29/400/225',
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildRelevantVideoCard(
              title: 'മുന്നുപേർക്കും ആഘോഷിച്ചു',
              channel: 'Aswin Madappally',
              views: '118K views',
              time: '4 days ago',
              duration: '18:45',
              thumbUrl: 'https://picsum.photos/id/35/400/225',
              badge: 'DEATH SENTENCE',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelevantVideoCard({
    required String title,
    required String channel,
    required String views,
    required String time,
    required String duration,
    required String thumbUrl,
    String? badge,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: thumbUrl,
                height: 100.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            if (badge != null)
              Positioned(
                top: 4.h,
                left: 4.w,
                child: Text(
                  badge,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
            Positioned(
              bottom: 4.h,
              right: 4.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  duration,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.2,
                ),
              ),
            ),
            Icon(
              FontAwesomeIcons.ellipsisVertical,
              size: 16.sp,
              color: Theme.of(context).iconTheme.color,
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          channel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '$views • $time',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildShortsGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildShortCard(
              title: '8 വർഷം കൽപ്പണി ഇന്നിപ്പോൾ Software E...',
              views: '3.4K views',
              thumbUrl: 'https://picsum.photos/id/45/300/500',
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildShortCard(
              title: '"അവൻമാരോട് ഒന്നു വരാൻ പറയു...ക്യാമറ ...',
              views: 'No views',
              thumbUrl: 'https://picsum.photos/id/65/300/500',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortCard({
    required String title,
    required String views,
    required String thumbUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: thumbUrl,
                height: 240.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 4),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    views,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPostShortsVideo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 24.h, bottom: 8.h),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: 'https://picsum.photos/id/180/1280/720',
                height: 220.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              Positioned(
                bottom: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.wifi,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: const CachedNetworkImageProvider(
                  'https://picsum.photos/id/1011/200/200',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IT Infrastructure Conclave: Sarbananda Sonowal On Building India\'s Smart Ports & Maritime Future',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Business Today • 3 watching',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
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
    );
  }
}
