import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/download_item.dart';
import '../bloc/download/download_manager_cubit.dart';
import '../bloc/download/download_manager_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  bool _isSelectionMode = false;
  final Set<String> _selectedItems = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedItems.clear();
    });
  }

  void _toggleItemSelection(String id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
      } else {
        _selectedItems.add(id);
      }
    });
  }

  void _deleteSelected() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Delete functionality not yet connected to core model'),
      ),
    );
    _toggleSelectionMode();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadManagerCubit, DownloadManagerState>(
      builder: (context, state) {
        // We'll add some mocked data if state.downloads is empty so we can see the grid UI
        final downloads = state.downloads.isNotEmpty
            ? state.downloads
            : _getMockDownloads();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              _buildStorageIndicator(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: GridView.builder(
                    padding: EdgeInsets.only(top: 16.h, bottom: 80.h),
                    itemCount: downloads.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final item = downloads[index];
                      // Handled mapped types and properties robustly for mock list mixed with cubit's elements
                      String id;
                      String thumb;
                      String title;
                      DownloadStatus status;
                      double progress;
                      String duration;

                      if (item is DownloadItem) {
                        id = item.videoId;
                        thumb =
                            'https://picsum.photos/seed/${item.videoId}/400/300';
                        title = item.title;
                        status = item.status;
                        progress = item.progress;
                        duration = '10:00';
                      } else {
                        final mapItem = item as Map<String, dynamic>;
                        id = mapItem['id'] as String;
                        thumb = mapItem['thumb'] as String;
                        title = mapItem['title'] as String;
                        status = mapItem['status'] as DownloadStatus;
                        progress = mapItem['progress'] as double;
                        duration = mapItem['duration'] as String;
                      }

                      return _buildDownloadGridItem(
                        id: id,
                        thumb: thumb,
                        title: title,
                        status: status,
                        progress: progress,
                        duration: duration,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: _isSelectionMode
              ? FloatingActionButton.extended(
                  onPressed: _selectedItems.isEmpty ? null : _deleteSelected,
                  backgroundColor: _selectedItems.isEmpty
                      ? Colors.grey
                      : Colors.red,
                  icon: const Icon(FontAwesomeIcons.trash, color: Colors.white),
                  label: Text(
                    'Delete (${_selectedItems.length})',
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      title: Text(
        'Downloads',
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSelectionMode
                ? FontAwesomeIcons.xmark
                : FontAwesomeIcons.listCheck,
          ),
          onPressed: _toggleSelectionMode,
        ),
        IconButton(
          icon: const Icon(FontAwesomeIcons.magnifyingGlass),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(FontAwesomeIcons.ellipsisVertical),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildStorageIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Storage',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              Text(
                '45.2 GB Free',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: 0.7, // 70% used
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 8.h,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'Used by YouTube',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
              ),
              SizedBox(width: 16.w),
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'Free Space',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadGridItem({
    required String id,
    required String thumb,
    required String title,
    required DownloadStatus status,
    required double progress,
    required String duration,
  }) {
    final isSelected = _selectedItems.contains(id);

    return GestureDetector(
      onLongPress: () {
        if (!_isSelectionMode) _toggleSelectionMode();
        _toggleItemSelection(id);
      },
      onTap: () {
        if (_isSelectionMode) {
          _toggleItemSelection(id);
        } else {
          // Navigate to player
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.white,
              border: _isSelectionMode && isSelected
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8.r),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: thumb,
                        height: 110.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 4.h,
                      right: 4.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          duration,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (status == DownloadStatus.downloading)
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 4.h,
                    color: Colors.red,
                    backgroundColor: Colors.grey[300],
                  ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Channel Name • 240 MB',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (status == DownloadStatus.downloading)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            '${(progress * 100).toStringAsFixed(0)}% downloading',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isSelectionMode)
            Positioned(
              top: 8.h,
              left: 8.w,
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.blue
                      : Colors.white.withOpacity(0.8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        FontAwesomeIcons.check,
                        size: 16.sp,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  List<dynamic> _getMockDownloads() {
    return [
      {
        'id': 'v1',
        'title': 'Flutter Animation Tutorial',
        'thumb': 'https://picsum.photos/id/1015/400/300',
        'status': DownloadStatus.completed,
        'progress': 1.0,
        'duration': '12:45',
      },
      {
        'id': 'v2',
        'title': 'Build a YouTube Clone with Flutter',
        'thumb': 'https://picsum.photos/id/1025/400/300',
        'status': DownloadStatus.completed,
        'progress': 1.0,
        'duration': '1:24:10',
      },
      {
        'id': 'v3',
        'title': 'Dart 3 Features Explained',
        'thumb': 'https://picsum.photos/id/1035/400/300',
        'status': DownloadStatus.downloading,
        'progress': 0.45,
        'duration': '18:20',
      },
      {
        'id': 'v4',
        'title': 'State Management in 2026',
        'thumb': 'https://picsum.photos/id/1045/400/300',
        'status': DownloadStatus.completed,
        'progress': 1.0,
        'duration': '45:00',
      },
    ];
  }
}
