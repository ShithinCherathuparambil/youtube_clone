import 'package:equatable/equatable.dart';

class Playlist extends Equatable {
  const Playlist({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.itemCount,
    required this.channelTitle,
  });

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
