import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.authorName,
    required this.authorProfileImageUrl,
    required this.textDisplay,
    required this.likeCount,
    required this.publishedAt,
  });

  final String id;
  final String authorName;
  final String authorProfileImageUrl;
  final String textDisplay;
  final int likeCount;
  final DateTime publishedAt;

  @override
  List<Object?> get props => [
    id,
    authorName,
    authorProfileImageUrl,
    textDisplay,
    likeCount,
    publishedAt,
  ];
}
