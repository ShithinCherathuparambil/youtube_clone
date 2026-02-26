import 'package:equatable/equatable.dart';

class Channel extends Equatable {
  const Channel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.subscriberCount,
  });

  final String id;
  final String title;
  final String thumbnailUrl;
  final int subscriberCount;

  @override
  List<Object?> get props => [id, title, thumbnailUrl, subscriberCount];
}
