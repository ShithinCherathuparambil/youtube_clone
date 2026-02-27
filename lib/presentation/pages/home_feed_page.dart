import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/youtube_icons.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/video_category.dart';
import '../../domain/entities/paginated_videos.dart';
import '../../domain/usecases/get_home_videos.dart';
import '../../domain/usecases/get_shorts.dart';
import '../../domain/usecases/get_video_categories.dart';
import '../../injection_container.dart';
import '../bloc/profile/profile_cubit.dart';
import '../bloc/search/search_bloc.dart';
import '../widgets/short_card.dart';
import '../widgets/video_card.dart';
import '../widgets/error_view.dart';
import '../widgets/connection_error_view.dart';
import 'custom_search_delegate.dart';

class HomeFeedPage extends StatefulWidget {
  static const route = '/home';
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  bool _isLoading = true;
  bool _isFetchingNextPage = false;
  Failure? _error;
  String? _nextPageToken;
  List<Video> _videos = [];
  List<VideoCategory> _categories = [];
  String _selectedCategoryId = '0';
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingShorts = true;
  List<Video> _shorts = [];

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndVideos();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchNextPage();
    }
  }

  Future<void> _fetchCategoriesAndVideos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final getCategories = sl<GetVideoCategories>();
    final getHomeVideos = sl<GetHomeVideos>();
    final getShorts = sl<GetShorts>();

    final results = await Future.wait([
      getCategories(const NoParams()),
      getHomeVideos(GetHomeVideosParams(categoryId: _selectedCategoryId)),
      getShorts(const GetHomeVideosParams()),
    ]);

    if (!mounted) return;

    results[0].fold(
      (failure) => _error = failure,
      (categories) => _categories = categories as List<VideoCategory>,
    );

    results[1].fold((failure) => _error = failure, (paginatedVideos) {
      final data = paginatedVideos as PaginatedVideos;
      _videos = data.videos;
      _nextPageToken = data.nextPageToken;
    });

    results[2].fold((_) => null, (paginatedShorts) {
      final data = paginatedShorts as PaginatedVideos;
      _shorts = data.videos;
    });

    setState(() {
      _isLoading = false;
      _isLoadingShorts = false;
    });
  }

  Future<void> _fetchVideosByCategory(String categoryId) async {
    if (_selectedCategoryId == categoryId) return;

    setState(() {
      _selectedCategoryId = categoryId;
      _isLoading = true;
      _videos.clear();
      _nextPageToken = null;
      _error = null;
    });

    final getHomeVideos = sl<GetHomeVideos>();
    final result = await getHomeVideos(
      GetHomeVideosParams(categoryId: categoryId),
    );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isLoading = false;
        _error = failure;
      }),
      (paginatedVideos) => setState(() {
        _isLoading = false;
        _error = null;
        _videos = paginatedVideos.videos;
        _nextPageToken = paginatedVideos.nextPageToken;
      }),
    );
  }

  Future<void> _fetchNextPage() async {
    if (_isFetchingNextPage || _nextPageToken == null) return;

    setState(() => _isFetchingNextPage = true);

    final getHomeVideos = sl<GetHomeVideos>();
    final result = await getHomeVideos(
      GetHomeVideosParams(
        categoryId: _selectedCategoryId,
        pageToken: _nextPageToken,
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
      (paginatedVideos) => setState(() {
        _isFetchingNextPage = false;
        _videos.addAll(paginatedVideos.videos);
        _nextPageToken = paginatedVideos.nextPageToken;
      }),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const PageStorageKey<String>('home_feed'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _fetchCategoriesAndVideos,
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.youtube,
                    color: Colors.red,
                    size: 28.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'YouTube',
                    style: TextStyle(
                      fontFamily: 'Oswald',
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      letterSpacing: -0.5,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.shareFromSquare,
                    color: Theme.of(context).iconTheme.color,
                    size: 20.sp,
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
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(
                        context.read<SearchBloc>(),
                      ),
                    );
                  },
                ),
                SizedBox(width: 8.w),
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
            if (_error != null && _videos.isEmpty)
              SliverFillRemaining(
                child: _error is ConnectionFailure
                    ? ConnectionErrorView(onRetry: _fetchCategoriesAndVideos)
                    : ErrorView(
                        message: _error!.message,
                        onRetry: _fetchCategoriesAndVideos,
                      ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return _buildCategoriesBar();
                    }

                    if (_isLoading) {
                      return const VideoCardShimmer();
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

                    // Adjust index for categories and shorts shelf
                    int videoIndex = index - 1;
                    if (index > 2) videoIndex = index - 2;

                    if (videoIndex >= 0 && videoIndex < _videos.length) {
                      return VideoCard(video: _videos[videoIndex]);
                    }

                    return const SizedBox.shrink();
                  },
                  childCount: _isLoading
                      ? 3
                      : _videos.length +
                            2 +
                            (_isFetchingNextPage
                                ? 1
                                : 0), // +1 for categories, +1 for Shorts, +1 for loading indicator
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesBar() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          final isSelected =
              (index == 0 && _selectedCategoryId == '0') ||
              (index > 0 && _categories[index - 1].id == _selectedCategoryId);

          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (index == 0) {
                    _fetchVideosByCategory('0');
                  } else {
                    _fetchVideosByCategory(_categories[index - 1].id);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    index == 0 ? 'All' : _categories[index - 1].title,
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).scaffoldBackgroundColor
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShortsShelf() {
    if (_shorts.isEmpty && !_isLoadingShorts) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Row(
            children: [
              SvgPicture.string(
                YoutubeIcons.shortsFilled,
                colorFilter: const ColorFilter.mode(
                  Colors.red,
                  BlendMode.srcIn,
                ),
                width: 24.sp,
                height: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Shorts',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: _isLoadingShorts ? 3 : _shorts.length,
            itemBuilder: (context, index) {
              if (_isLoadingShorts) {
                return const ShortCardShimmer();
              }
              final video = _shorts[index];
              return ShortCard(
                title: video.title,
                views: '${(video.views / 1000).toStringAsFixed(1)}K views',
                thumbUrl: video.thumbnailUrl,
              );
            },
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
          ),
        ),
        const Divider(thickness: 4),
      ],
    );
  }
}
