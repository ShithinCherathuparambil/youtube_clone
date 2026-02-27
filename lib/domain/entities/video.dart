import 'package:equatable/equatable.dart';

class Video extends Equatable {
  const Video({
    required this.id,
    required this.title,
    required this.channelName,
    required this.channelId,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    required this.views,
    required this.publishedAt,
    this.likes = 0,
    this.commentCount = 0,
  });

  final String id;
  final String title;
  final String channelName;
  final String channelId;
  final String thumbnailUrl;
  final String videoUrl;
  final Duration duration;
  final int views;
  final DateTime publishedAt;
  final int likes;
  final int commentCount;

  @override
  List<Object?> get props => [
    id,
    title,
    channelName,
    channelId,
    thumbnailUrl,
    videoUrl,
    duration,
    views,
    publishedAt,
    likes,
    commentCount,
  ];
}
