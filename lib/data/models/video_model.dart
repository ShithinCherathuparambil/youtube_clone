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
    return VideoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      channelName: map['channelName'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String,
      videoUrl: map['videoUrl'] as String,
      duration: Duration(seconds: (map['durationSeconds'] as num).toInt()),
      views: (map['views'] as num).toInt(),
      publishedAt: DateTime.parse(map['publishedAt'] as String),
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
