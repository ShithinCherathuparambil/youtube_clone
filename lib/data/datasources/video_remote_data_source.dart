import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/youtube_api_keys.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/channel_model.dart';
import '../models/comment_model.dart';
import '../models/paginated_videos_model.dart';
import '../models/playlist_model.dart';
import '../models/video_category_model.dart';
import '../models/video_model.dart';

abstract class VideoRemoteDataSource {
  Future<PaginatedVideosModel> getHomeVideos({
    String? pageToken,
    String? categoryId,
  });
  Future<PaginatedVideosModel> getShorts({String? pageToken});
  Future<List<CommentModel>> getComments(String videoId);
  Future<List<ChannelModel>> getPopularChannels();
  Future<PaginatedVideosModel> searchVideos(String query, {String? pageToken});
  Future<List<VideoCategoryModel>> getVideoCategories();
  Future<List<PlaylistModel>> getPlaylists(String channelId);
  Future<ChannelModel> getChannelDetails(String channelId);
}

@LazySingleton(as: VideoRemoteDataSource)
class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  VideoRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<PaginatedVideosModel> getHomeVideos({
    String? pageToken,
    String? categoryId,
  }) async {
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

      if (categoryId != null && categoryId != '0') {
        queryParams['videoCategoryId'] = categoryId;
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

      final searchResponse = await _dioClient.dio.get<Map<String, dynamic>>(
        'https://www.googleapis.com/youtube/v3/search',
        queryParameters: queryParams,
      );

      final searchData = searchResponse.data ?? {};
      final items = searchData['items'] as List<dynamic>? ?? <dynamic>[];

      if (items.isEmpty) {
        return PaginatedVideosModel.fromMap(searchData);
      }

      final videoIds = items
          .map((item) {
            if (item is Map<String, dynamic>) {
              final id = item['id'];
              if (id is Map<String, dynamic>) {
                return id['videoId'] as String?;
              }
            }
            return null;
          })
          .whereType<String>()
          .join(',');

      final videosResponse = await _dioClient.dio.get<Map<String, dynamic>>(
        'https://www.googleapis.com/youtube/v3/videos',
        queryParameters: {
          'part': 'snippet,contentDetails,statistics',
          'id': videoIds,
          'key': YouTubeApiKeys.apiKey,
        },
      );

      final videosData = videosResponse.data ?? {};
      videosData['nextPageToken'] = searchData['nextPageToken'];

      return PaginatedVideosModel.fromMap(videosData);
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
      // 1. Fetch popular videos to get popular channel IDs
      final videosResponse = await _dioClient.dio.get<Map<String, dynamic>>(
        'https://www.googleapis.com/youtube/v3/videos',
        queryParameters: {
          'part': 'snippet',
          'chart': 'mostPopular',
          'maxResults': 15,
          'regionCode': 'US',
          'key': YouTubeApiKeys.apiKey,
        },
      );

      final videoItems = videosResponse.data?['items'] as List<dynamic>? ?? [];
      final channelIds = videoItems
          .map((item) => item['snippet']['channelId'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet()
          .toList();

      if (channelIds.isEmpty) return [];

      // 2. Fetch channel details for those IDs
      final channelsResponse = await _dioClient.dio.get<Map<String, dynamic>>(
        'https://www.googleapis.com/youtube/v3/channels',
        queryParameters: {
          'part': 'snippet,statistics',
          'id': channelIds.take(10).join(','),
          'key': YouTubeApiKeys.apiKey,
        },
      );

      final channelItems =
          channelsResponse.data?['items'] as List<dynamic>? ?? <dynamic>[];
      final channels = channelItems
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

  @override
  Future<List<VideoCategoryModel>> getVideoCategories() async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        'https://www.googleapis.com/youtube/v3/videoCategories',
        queryParameters: {
          'part': 'snippet',
          'regionCode': 'US',
          'key': YouTubeApiKeys.apiKey,
        },
      );

      final items = response.data?['items'] as List<dynamic>? ?? <dynamic>[];
      final categories = items
          .cast<Map<String, dynamic>>()
          .map(VideoCategoryModel.fromMap)
          .where((category) => category.assignable)
          .toList();
      return categories;
    } on DioException catch (e) {
      throw ServerException('Failed to fetch video categories: ${e.message}');
    } catch (e) {
      throw ServerException(
        'Unexpected error while fetching video categories: $e',
      );
    }
  }

  @override
  Future<List<PlaylistModel>> getPlaylists(String channelId) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        'https://www.googleapis.com/youtube/v3/playlists',
        queryParameters: {
          'part': 'snippet,contentDetails',
          'channelId': channelId,
          'maxResults': 20,
          'key': YouTubeApiKeys.apiKey,
        },
      );

      final items = response.data?['items'] as List<dynamic>? ?? <dynamic>[];
      final playlists = items
          .cast<Map<String, dynamic>>()
          .map(PlaylistModel.fromMap)
          .toList();
      return playlists;
    } on DioException catch (e) {
      throw ServerException('Failed to fetch playlists: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error while fetching playlists: $e');
    }
  }

  @override
  Future<ChannelModel> getChannelDetails(String channelId) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        'https://www.googleapis.com/youtube/v3/channels',
        queryParameters: {
          'part': 'snippet,statistics,brandingSettings',
          'id': channelId,
          'key': YouTubeApiKeys.apiKey,
        },
      );

      final items = response.data?['items'] as List<dynamic>? ?? <dynamic>[];
      if (items.isEmpty) {
        throw ServerException('Channel not found');
      }

      return ChannelModel.fromMap(items.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException('Failed to fetch channel details: ${e.message}');
    } catch (e) {
      throw ServerException(
        'Unexpected error while fetching channel details: $e',
      );
    }
  }
}
