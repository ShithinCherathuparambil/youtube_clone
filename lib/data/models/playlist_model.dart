import 'package:equatable/equatable.dart';

class PlaylistModel extends Equatable {
  const PlaylistModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.itemCount,
    required this.channelTitle,
  });

  factory PlaylistModel.fromMap(Map<String, dynamic> map) {
    final snippet = map['snippet'] as Map<String, dynamic>?;
    final contentDetails = map['contentDetails'] as Map<String, dynamic>?;
    final thumbnails = snippet?['thumbnails'] as Map<String, dynamic>?;

    // Get the best available thumbnail
    String thumb = '';
    if (thumbnails != null) {
      if (thumbnails['maxres'] != null) {
        thumb = thumbnails['maxres']['url'] as String? ?? '';
      } else if (thumbnails['high'] != null) {
        thumb = thumbnails['high']['url'] as String? ?? '';
      } else if (thumbnails['medium'] != null) {
        thumb = thumbnails['medium']['url'] as String? ?? '';
      } else if (thumbnails['default'] != null) {
        thumb = thumbnails['default']['url'] as String? ?? '';
      }
    }

    return PlaylistModel(
      id: map['id'] as String? ?? '',
      title: snippet?['title'] as String? ?? '',
      description: snippet?['description'] as String? ?? '',
      thumbnailUrl: thumb,
      itemCount: contentDetails?['itemCount'] as int? ?? 0,
      channelTitle: snippet?['channelTitle'] as String? ?? '',
    );
  }

  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int itemCount;
  final String channelTitle;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    thumbnailUrl,
    itemCount,
    channelTitle,
  ];
}
