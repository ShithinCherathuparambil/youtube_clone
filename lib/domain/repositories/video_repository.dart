import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/channel.dart';
import '../entities/comment.dart';
import '../entities/paginated_videos.dart';
import '../entities/playlist.dart';
import '../entities/video_category.dart';

abstract class VideoRepository {
  Future<Either<Failure, PaginatedVideos>> getHomeVideos({
    String? pageToken,
    String? categoryId,
  });
  Future<Either<Failure, PaginatedVideos>> getShorts({String? pageToken});
  Future<Either<Failure, List<Comment>>> getComments(String videoId);
  Future<Either<Failure, List<Channel>>> getPopularChannels();
  Future<Either<Failure, PaginatedVideos>> searchVideos(
    String query, {
    String? pageToken,
  });
  Future<Either<Failure, List<VideoCategory>>> getVideoCategories();
  Future<Either<Failure, List<Playlist>>> getPlaylists(String channelId);
  Future<Either<Failure, Channel>> getChannelDetails(String channelId);
}
