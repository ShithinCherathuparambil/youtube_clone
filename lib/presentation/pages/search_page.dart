import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/video.dart';
import '../../domain/usecases/search_videos.dart';
import '../../injection_container.dart';
import 'home_feed_page.dart';

class SearchPage extends StatefulWidget {
  static const route = '/search';
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isFetchingNextPage = false;
  String? _error;
  String? _nextPageToken;
  List<Video> _videos = [];
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchNextPage();
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _currentQuery = query.trim();
      _isLoading = true;
      _error = null;
      _videos.clear();
      _nextPageToken = null;
    });

    final searchVideos = sl<SearchVideos>();
    final result = await searchVideos(SearchVideosParams(query: _currentQuery));

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isLoading = false;
        _error = failure.message;
      }),
      (paginated) => setState(() {
        _isLoading = false;
        _videos = paginated.videos;
        _nextPageToken = paginated.nextPageToken;
      }),
    );
  }

  Future<void> _fetchNextPage() async {
    if (_isFetchingNextPage ||
        _nextPageToken == null ||
        _isLoading ||
        _error != null ||
        _currentQuery.isEmpty) {
      return;
    }

    setState(() => _isFetchingNextPage = true);

    final searchVideos = sl<SearchVideos>();
    final result = await searchVideos(
      SearchVideosParams(query: _currentQuery, pageToken: _nextPageToken),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isFetchingNextPage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more results: ${failure.message}'),
          ),
        );
      },
      (paginated) => setState(() {
        _isFetchingNextPage = false;
        _videos.addAll(paginated.videos);
        _nextPageToken = paginated.nextPageToken;
      }),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search YouTube',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.black),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _videos.clear();
                  _currentQuery = '';
                });
              },
            ),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(_error!, style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => _performSearch(_currentQuery),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_videos.isEmpty && _currentQuery.isNotEmpty && !_isLoading) {
      return Center(
        child: Text(
          'No results found for "$_currentQuery"',
          style: TextStyle(color: Colors.grey[700]),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _videos.length + (_isFetchingNextPage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _videos.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator(color: Colors.red)),
          );
        }
        return VideoCard(video: _videos[index]);
      },
    );
  }
}
