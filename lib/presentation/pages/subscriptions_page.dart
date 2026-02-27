import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/channel.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/paginated_videos.dart';
import '../../domain/usecases/get_home_videos.dart';
import '../../domain/usecases/get_popular_channels.dart';
import '../../injection_container.dart';
import '../bloc/profile/profile_cubit.dart';
import '../bloc/search/search_bloc.dart';
import '../widgets/video_card.dart';
import '../widgets/error_view.dart';
import '../widgets/connection_error_view.dart';
import 'custom_search_delegate.dart';

class SubscriptionsPage extends StatefulWidget {
  static const route = '/subscriptions';
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  bool _isLoadingChannels = true;
  bool _isLoadingVideos = true;
  List<Channel> _channels = [];
  List<Video> _videos = [];
  Failure? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoadingChannels = true;
      _isLoadingVideos = true;
      _error = null;
    });

    final getPopularChannels = sl<GetPopularChannels>();
    final getHomeVideos = sl<GetHomeVideos>();

    final results = await Future.wait([
      getPopularChannels(const NoParams()),
      getHomeVideos(const GetHomeVideosParams(categoryId: '0')),
    ]);

    if (!mounted) return;

    results[0].fold(
      (failure) => _error = failure,
      (channels) => _channels = channels as List<Channel>,
    );

    results[1].fold(
      (failure) => _error = failure,
      (paginatedVideos) =>
          _videos = (paginatedVideos as PaginatedVideos).videos,
    );

    setState(() {
      _isLoadingChannels = false;
      _isLoadingVideos = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const PageStorageKey<String>('subscriptions'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Subscriptions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.shareFromSquare,
              size: 20.sp,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.bell,
              size: 20.sp,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.magnifyingGlass,
              size: 20.sp,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(context.read<SearchBloc>()),
              );
            },
          ),
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              String? imagePath;
              if (state is ProfileLoaded) {
                imagePath = state.profileImagePath;
              }
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: CircleAvatar(
                  radius: 14.r,
                  backgroundImage: imagePath != null
                      ? FileImage(File(imagePath)) as ImageProvider
                      : const NetworkImage(
                          'https://picsum.photos/id/1027/100/100',
                        ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: Theme.of(context).colorScheme.primary,
        child: _error != null && _videos.isEmpty && _channels.isEmpty
            ? Center(
                child: _error is ConnectionFailure
                    ? ConnectionErrorView(onRetry: _fetchData)
                    : ErrorView(message: _error!.message, onRetry: _fetchData),
              )
            : ListView(
                children: [
                  _buildChannelsList(),
                  _buildFilterChips(),
                  _buildVideosList(),
                ],
              ),
      ),
    );
  }

  Widget _buildChannelsList() {
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

    if (_channels.isEmpty && _error != null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 110.h,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        itemCount: _channels.length + 1,
        itemBuilder: (context, index) {
          if (index == _channels.length) {
            return Padding(
              padding: EdgeInsets.only(left: 12.w, top: 20.h),
              child: Column(
                children: [
                  Text(
                    'All',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          final channel = _channels[index];
          return Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28.r,
                      backgroundImage: NetworkImage(channel.thumbnailUrl),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.fiber_manual_record,
                          color: Colors.white,
                          size: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  channel.title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Today', 'Continue watching', 'Unwatched', 'Posts'];
    return SizedBox(
      height: 48.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Chip(
              label: Text(filters[index], style: TextStyle(fontSize: 13.sp)),
              backgroundColor: index == 0
                  ? Theme.of(context).textTheme.bodyLarge?.color
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              labelStyle: TextStyle(
                color: index == 0
                    ? Theme.of(context).scaffoldBackgroundColor
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideosList() {
    if (_isLoadingVideos) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) => const VideoCardShimmer(),
      );
    }

    if (_error != null && _videos.isEmpty) {
      if (_channels.isNotEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              _error!.message,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _videos.length,
      itemBuilder: (context, index) => VideoCard(video: _videos[index]),
    );
  }
}
