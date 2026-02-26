import '../../core/utils/duration_parser.dart';
import '../../domain/entities/video.dart';

class VideoModel extends Video {
  const VideoModel({
    required super.id,
    required super.title,
    required super.channelName,
    required super.thumbnailUrl,
    required super.videoUrl,
    required super.duration,
    required super.views,
    required super.publishedAt,
  });

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    final snippet = map['snippet'] as Map<String, dynamic>? ?? {};
    final contentDetails = map['contentDetails'] as Map<String, dynamic>? ?? {};
    final statistics = map['statistics'] as Map<String, dynamic>? ?? {};
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
    final highThumbnail = thumbnails['high'] as Map<String, dynamic>? ?? {};

    String videoId = '';
    if (map['id'] is String) {
      videoId = map['id'] as String;
    } else if (map['id'] is Map<String, dynamic>) {
      videoId = (map['id'] as Map<String, dynamic>)['videoId'] as String? ?? '';
    }

    return VideoModel(
      id: videoId,
      title: snippet['title'] as String? ?? 'Unknown Title',
      channelName: snippet['channelTitle'] as String? ?? 'Unknown Channel',
      thumbnailUrl: highThumbnail['url'] as String? ?? '',
      videoUrl: 'https://www.youtube.com/watch?v=$videoId',
      duration: DurationParser.parseDuration(
        contentDetails['duration'] as String? ?? '',
      ),
      views: int.tryParse(statistics['viewCount']?.toString() ?? '0') ?? 0,
      publishedAt:
          DateTime.tryParse(snippet['publishedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'channelName': channelName,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'durationSeconds': duration.inSeconds,
      'views': views,
      'publishedAt': publishedAt.toIso8601String(),
    };
  }
}
