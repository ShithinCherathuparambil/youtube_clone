import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/services/background_download_service.dart';
import '../../domain/entities/download_item.dart';
import '../../injection_container.dart';
import '../bloc/download/download_manager_cubit.dart';
import '../bloc/download/download_manager_state.dart';

import 'package:go_router/go_router.dart';
import 'package:youtube_clone/l10n/app_localizations.dart';
import '../../domain/entities/storage_info.dart';
import 'watch_page.dart';

class DownloadsPage extends StatefulWidget {
  static const route = 'downloads';
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  bool _isSelectionMode = false;
  bool _isDecrypting = false;
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDownloads),
        content: Text(l10n.deleteSelectedVideos(_selectedItems.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<DownloadManagerCubit>().deleteDownloads(
                _selectedItems.toList(),
              );
              Navigator.pop(context);
              _toggleSelectionMode();
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<DownloadManagerCubit>().loadCachedDownloads();
    context.read<DownloadManagerCubit>().loadStorageInfo();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<DownloadManagerCubit, DownloadManagerState>(
      builder: (context, state) {
        if (state.isLoading && state.downloads.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final downloads = state.downloads;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: _buildAppBar(state),
              body: Column(
                children: [
                  _buildStorageIndicator(state.storageInfo),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: downloads.isEmpty && !state.isLoading
                          ? _buildEmptyState()
                          : GridView.builder(
                              padding: EdgeInsets.only(top: 16.h, bottom: 80.h),
                              itemCount: downloads.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16.w,
                                    mainAxisSpacing: 16.h,
                                    childAspectRatio: 0.7,
                                  ),
                              itemBuilder: (context, index) {
                                final item = downloads[index];
                                return _buildDownloadGridItem(item: item);
                              },
                            ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: _isSelectionMode
                  ? FloatingActionButton.extended(
                      onPressed: _selectedItems.isEmpty
                          ? null
                          : _deleteSelected,
                      backgroundColor: _selectedItems.isEmpty
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).colorScheme.error,
                      icon: Icon(
                        FontAwesomeIcons.trash,
                        color: Theme.of(context).colorScheme.onError,
                      ),
                      label: Text(
                        '${l10n.delete} (${_selectedItems.length})',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                    )
                  : null,
            ),
            if (_isDecrypting)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(DownloadManagerState state) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).iconTheme.color,
      elevation: 0,
      title: Text(
        l10n.downloads,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      actions: [
        if (state.downloads.isNotEmpty)
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

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.download,
            size: 64.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.noDownloadsYet,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.videosAppearHere,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageIndicator(StorageInfo? info) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.availableStorage,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                l10n.gbFree(info?.freeSpaceGB.toStringAsFixed(1) ?? '0.0'),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: info != null
                  ? (info.totalSpaceGB - info.freeSpaceGB) / info.totalSpaceGB
                  : 0.0,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
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
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                l10n.usedByYoutube,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(width: 16.w),
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                l10n.freeSpace,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadGridItem({required DownloadItem item}) {
    final l10n = AppLocalizations.of(context)!;
    final id = item.videoId;
    final title = item.title;
    final isSelected = _selectedItems.contains(id);
    final status = item.status;
    final progress = item.progress;
    final duration = '--:--'; // Fallback

    return GestureDetector(
      onLongPress: () {
        if (!_isSelectionMode) _toggleSelectionMode();
        _toggleItemSelection(id);
      },
      onTap: () async {
        if (_isSelectionMode) {
          _toggleItemSelection(id);
        } else if (status == DownloadStatus.completed) {
          // Decrypt and play
          final cubit = context.read<DownloadManagerCubit>();
          final item = cubit.state.downloads.firstWhere((e) => e.videoId == id);

          setState(() {
            _isDecrypting = true;
          });

          final file = await cubit.getDecryptedFile(id, item.outputPath);

          if (mounted) {
            setState(() {
              _isDecrypting = false;
            });

            if (file != null) {
              context.push(
                '${WatchPage.route}?videoUrl=${Uri.encodeComponent(file.path)}&title=${Uri.encodeComponent(title)}&id=$id',
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to decrypt video')),
              );
            }
          }
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Theme.of(context).scaffoldBackgroundColor,
              border: _isSelectionMode && isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
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
                        imageUrl: 'https://picsum.photos/seed/$id/400/300',
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
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          duration,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (status == DownloadStatus.downloading)
                  StreamBuilder<DownloadUpdate>(
                    stream: sl<BackgroundDownloadService>().progressStream,
                    builder: (context, snapshot) {
                      double currentProgress = progress;
                      if (snapshot.hasData &&
                          snapshot.data!.taskId == item.taskId) {
                        currentProgress = snapshot.data!.progress;
                      }
                      return LinearProgressIndicator(
                        value: currentProgress,
                        minHeight: 4.h,
                        color: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      );
                    },
                  ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (status == DownloadStatus.downloading ||
                              status == DownloadStatus.queued)
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, size: 16.sp),
                              padding: EdgeInsets.zero,
                              onSelected: (value) {
                                final taskId = item.taskId;
                                if (taskId == null) return;
                                switch (value) {
                                  case 'pause':
                                    sl<BackgroundDownloadService>().pause(
                                      taskId,
                                    );
                                    break;
                                  case 'resume':
                                    sl<BackgroundDownloadService>().resume(
                                      taskId,
                                    );
                                    break;
                                  case 'cancel':
                                    sl<BackgroundDownloadService>().cancel(
                                      taskId,
                                    );
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'pause',
                                  child: Text(l10n.pause),
                                ),
                                PopupMenuItem(
                                  value: 'resume',
                                  child: Text(l10n.resume),
                                ),
                                PopupMenuItem(
                                  value: 'cancel',
                                  child: Text(l10n.cancel),
                                ),
                              ],
                            )
                          else
                            IconButton(
                              icon: Icon(Icons.more_vert, size: 16.sp),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                if (!_isSelectionMode) _toggleSelectionMode();
                                _toggleItemSelection(id);
                              },
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        status == DownloadStatus.completed
                            ? l10n.videoEncrypted
                            : 'Status: ${status.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (status == DownloadStatus.downloading)
                        StreamBuilder<DownloadUpdate>(
                          stream:
                              sl<BackgroundDownloadService>().progressStream,
                          builder: (context, snapshot) {
                            double currentProgress = progress;
                            String statusText = 'downloading';
                            if (snapshot.hasData &&
                                snapshot.data!.taskId == item.taskId) {
                              currentProgress = snapshot.data!.progress;
                              statusText = snapshot.data!.status.name;
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                '${(currentProgress * 100).toStringAsFixed(0)}% $statusText',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            );
                          },
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
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.8),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        FontAwesomeIcons.check,
                        size: 16.sp,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
