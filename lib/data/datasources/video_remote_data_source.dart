import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/youtube_api_keys.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/channel_model.dart';
import '../models/comment_model.dart';
import '../models/paginated_videos_model.dart';
import '../models/video_model.dart';

abstract class VideoRemoteDataSource {
  Future<PaginatedVideosModel> getHomeVideos({String? pageToken});
  Future<PaginatedVideosModel> getShorts({String? pageToken});
  Future<List<CommentModel>> getComments(String videoId);
  Future<List<ChannelModel>> getPopularChannels();
  Future<PaginatedVideosModel> searchVideos(String query, {String? pageToken});
}

@LazySingleton(as: VideoRemoteDataSource)
class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  VideoRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<PaginatedVideosModel> getHomeVideos({String? pageToken}) async {
    try {
      final queryParams = {
        'part': 'snippet,contentDetails,statistics',
        'chart': 'mostPopular',
        'regionCode': 'US',
        'maxResults': 20,
        'key': YouTubeApiKeys.apiKey,
      };

      if (pageToken != null && pageToken.isNotEmpty) {
        queryParams['pageToken'] = pageToken;
      }

      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        'https://www.googleapis.com/youtube/v3/videos',
        queryParameters: queryParams,
      );

      final data = response.data ?? {};
      return PaginatedVideosModel.fromMap(data);
    } on DioException catch (e) {
      throw ServerException('Failed to fetch videos: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error while fetching videos: $e');
    }
  }

  @override
  Future<PaginatedVideosModel> getShorts({String? pageToken}) async {
    try {
      final queryParams = {
        'part': 'snippet',
        'type': 'video',
        'videoDuration': 'short',
        'q': '#shorts',
        'maxResults': 20,
        'key': YouTubeApiKeys.apiKey,
      };

      if (pageToken != null && pageToken.isNotEmpty) {
        queryParams['pageToken'] = pageToken;
      }

      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        'https://www.googleapis.com/youtube/v3/search',
        queryParameters: queryParams,
      );

      final data = response.data ?? {};
      return PaginatedVideosModel.fromMap(data);
    } on DioException catch (e) {
      throw ServerException('Failed to fetch shorts: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error while fetching shorts: $e');
    }
  }

  @override
  Future<List<CommentModel>> getComments(String videoId) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        'https://www.googleapis.com/youtube/v3/commentThreads',
        queryParameters: {
          'part': 'snippet',
          'videoId': videoId,
          'maxResults': 20,
          'key': YouTubeApiKeys.apiKey,
        },
      );

      final items = response.data?['items'] as List<dynamic>? ?? <dynamic>[];
      final comments = items
          .cast<Map<String, dynamic>>()
          .map(CommentModel.fromMap)
          .toList();
      return comments;
    } on DioException catch (e) {
      throw ServerException('Failed to fetch comments: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error while fetching comments: $e');
    }
  }

  @override
  Future<List<ChannelModel>> getPopularChannels() async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        'https://www.googleapis.com/youtube/v3/channels',
        queryParameters: {
          'part': 'snippet,statistics',
          'chart': 'mostPopular',
          'maxResults': 10,
          'regionCode': 'US',
          'key': YouTubeApiKeys.apiKey,
        },
      );

      final items = response.data?['items'] as List<dynamic>? ?? <dynamic>[];
      final channels = items
          .cast<Map<String, dynamic>>()
          .map(ChannelModel.fromMap)
          .toList();
      return channels;
    } on DioException catch (e) {
      throw ServerException('Failed to fetch channels: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error while fetching channels: $e');
    }
  }

  @override
  Future<PaginatedVideosModel> searchVideos(
    String query, {
    String? pageToken,
  }) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        'https://www.googleapis.com/youtube/v3/search',
        queryParameters: {
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'maxResults': 15,
          'key': YouTubeApiKeys.apiKey,
          if (pageToken != null) 'pageToken': pageToken,
        },
      );

      final items = response.data?['items'] as List<dynamic>? ?? <dynamic>[];
      final videos = items
          .cast<Map<String, dynamic>>()
          .map(VideoModel.fromMap)
          .toList();

      return PaginatedVideosModel(
        videos: videos,
        nextPageToken: response.data?['nextPageToken'] as String?,
      );
    } on DioException catch (e) {
      throw ServerException('Failed to search videos: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error while searching videos: $e');
    }
  }
}
