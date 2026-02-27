import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../domain/entities/video.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({super.key, required this.video});

  final Video video;

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
        context.push('/watch', extra: video);
      },
      child: Column(
        children: [
          Stack(
            children: [
              Material(
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
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.youtube,
                            color: Colors.red,
                            size: 40.sp,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Preview not available',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
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

class VideoCardShimmer extends StatelessWidget {
  const VideoCardShimmer({super.key});

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
