import '../../domain/entities/paginated_videos.dart';
import 'video_model.dart';

class PaginatedVideosModel extends PaginatedVideos {
  const PaginatedVideosModel({required super.videos, super.nextPageToken});

  factory PaginatedVideosModel.fromMap(Map<String, dynamic> map) {
    final items = map['items'] as List<dynamic>? ?? <dynamic>[];
    final videos = items
        .cast<Map<String, dynamic>>()
        .map(VideoModel.fromMap)
        .toList();

    return PaginatedVideosModel(
      videos: videos,
      nextPageToken: map['nextPageToken'] as String?,
    );
  }
}
