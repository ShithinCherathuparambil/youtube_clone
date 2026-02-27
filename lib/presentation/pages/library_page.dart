import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/usecases/get_playlists.dart';
import '../../injection_container.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool _isLoading = true;
  String? _error;
  List<Playlist> _playlists = [];

  @override
  void initState() {
    super.initState();
    _fetchPlaylists();
  }

  Future<void> _fetchPlaylists() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final getPlaylists = sl<GetPlaylists>();
    // Using Google Developers channel ID as a placeholder for user playlists
    final result = await getPlaylists('UC_x5XG1OV2P6uZZ5FSM9Ttw');

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _error = failure.message;
        });
      },
      (playlists) {
        setState(() {
          _isLoading = false;
          _playlists = playlists;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Library',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
            Text(_error!, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _fetchPlaylists,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        _buildQuickActions(),
        const Divider(),
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Playlists',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: 'Recently added',
                items: ['Recently added', 'A-Z']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (_) {},
                underline: const SizedBox(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _buildPlaylistsList(),
        _buildAddPlaylistButton(),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionTile(FontAwesomeIcons.clockRotateLeft, 'History'),
        _buildActionTile(FontAwesomeIcons.circlePlay, 'Your videos'),
        _buildActionTile(FontAwesomeIcons.download, 'Downloads'),
        _buildActionTile(FontAwesomeIcons.film, 'Your movies'),
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, size: 20.sp, color: Colors.black87),
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),
      ),
      onTap: () {},
    );
  }

  Widget _buildPlaylistsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _playlists.length,
      itemBuilder: (context, index) {
        final playlist = _playlists[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: CachedNetworkImage(
              imageUrl: playlist.thumbnailUrl,
              width: 50.w,
              height: 50.w,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    playlist.title.contains('Movies')
                        ? FontAwesomeIcons.film
                        : FontAwesomeIcons.play,
                    size: 20.sp,
                    color: Theme.of(
                      context,
                    ).iconTheme.color?.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            playlist.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${playlist.itemCount} videos',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
          ),
          onTap: () {},
        );
      },
    );
  }

  Widget _buildAddPlaylistButton() {
    return ListTile(
      leading: Icon(Icons.add, color: Colors.blue, size: 24.sp),
      title: Text(
        'New playlist',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {},
    );
  }
}
