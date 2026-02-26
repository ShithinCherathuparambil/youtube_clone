import '../../domain/entities/channel.dart';

class ChannelModel extends Channel {
  const ChannelModel({
    required super.id,
    required super.title,
    required super.thumbnailUrl,
    required super.subscriberCount,
  });

  factory ChannelModel.fromMap(Map<String, dynamic> map) {
    final snippet = map['snippet'] as Map<String, dynamic>? ?? {};
    final statistics = map['statistics'] as Map<String, dynamic>? ?? {};
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
    final defaultThumbnail =
        thumbnails['default'] as Map<String, dynamic>? ?? {};

    return ChannelModel(
      id: map['id'] as String? ?? '',
      title: snippet['title'] as String? ?? 'Unknown Channel',
      thumbnailUrl: defaultThumbnail['url'] as String? ?? '',
      subscriberCount:
          int.tryParse(statistics['subscriberCount']?.toString() ?? '0') ?? 0,
    );
  }
}
