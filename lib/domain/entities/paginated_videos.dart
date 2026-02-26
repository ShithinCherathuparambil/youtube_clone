import 'package:equatable/equatable.dart';

import 'video.dart';

class PaginatedVideos extends Equatable {
  const PaginatedVideos({required this.videos, this.nextPageToken});

  final List<Vido> videos;
  final String? nextPageToken;

  @override
  List<Object?> get props => [videos, nextPageToken];
}
