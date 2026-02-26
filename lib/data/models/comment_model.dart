import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.authorName,
    required super.authorProfileImageUrl,
    required super.textDisplay,
    required super.likeCount,
    required super.publishedAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    final snippet =
        map['snippet']?['topLevelComment']?['snippet']
            as Map<String, dynamic>? ??
        {};

    return CommentModel(
      id: map['id'] as String? ?? '',
      authorName: snippet['authorDisplayName'] as String? ?? 'Unknown',
      authorProfileImageUrl: snippet['authorProfileImageUrl'] as String? ?? '',
      textDisplay: snippet['textDisplay'] as String? ?? '',
      likeCount: snippet['likeCount'] as int? ?? 0,
      publishedAt:
          DateTime.tryParse(snippet['publishedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
