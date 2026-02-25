import 'package:equatable/equatable.dart';

class Video extends Equatable {
  const Video({
    required this.id,
    required this.title,
    required this.channelName,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    required this.views,
    required this.publishedAt,
  });

  final String id;
  final String title;
  final String channelName;
  final String thumbnailUrl;
  final String videoUrl;
  final Duration duration;
  final int views;
  final DateTime publishedAt;

  @override
  List<Object?> get props => [
        id,
        title,
        channelName,
        thumbnailUrl,
        videoUrl,
        duration,
        views,
        publishedAt,
      ];
}
