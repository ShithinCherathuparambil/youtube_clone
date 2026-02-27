import '../../domain/entities/video.dart';

class WatchHistoryModel extends Video {
  final DateTime watchedAt;

  WatchHistoryModel({
    required super.id,
    required super.title,
    required super.channelName,
    required super.channelId,
    required super.thumbnailUrl,
    required super.videoUrl,
    required super.duration,
    required super.views,
    required super.publishedAt,
    super.likes,
    super.commentCount,
    required this.watchedAt,
  });

  factory WatchHistoryModel.fromVideo(Video video, DateTime watchedAt) {
    return WatchHistoryModel(
      id: video.id,
      title: video.title,
      channelName: video.channelName,
      channelId: video.channelId,
      thumbnailUrl: video.thumbnailUrl,
      videoUrl: video.videoUrl,
      duration: video.duration,
      views: video.views,
      publishedAt: video.publishedAt,
      likes: video.likes,
      commentCount: video.commentCount,
      watchedAt: watchedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'channelName': channelName,
      'channelId': channelId,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'duration': duration.inSeconds,
      'views': views,
      'publishedAt': publishedAt.toIso8601String(),
      'likes': likes,
      'commentCount': commentCount,
      'watchedAt': watchedAt.toIso8601String(),
    };
  }

  factory WatchHistoryModel.fromMap(Map<String, dynamic> map) {
    return WatchHistoryModel(
      id: map['id'] as String,
      title: map['title'] as String,
      channelName: map['channelName'] as String,
      channelId: map['channelId'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String,
      videoUrl: map['videoUrl'] as String,
      duration: Duration(seconds: map['duration'] as int),
      views: map['views'] as int,
      publishedAt: DateTime.parse(map['publishedAt'] as String),
      likes: map['likes'] as int? ?? 0,
      commentCount: map['commentCount'] as int? ?? 0,
      watchedAt: DateTime.parse(map['watchedAt'] as String),
    );
  }
}
