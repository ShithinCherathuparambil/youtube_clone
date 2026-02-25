import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/video_model.dart';

abstract class VideoRemoteDataSource {
  Future<List<VideoModel>> getHomeVideos();
}

@LazySingleton(as: VideoRemoteDataSource)
class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  VideoRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<VideoModel>> getHomeVideos() async {
    try {
      // Replace endpoint with your backend URL.
      final response = await _dioClient.dio.get<Map<String, dynamic>>('/videos/home');
      final videos = (response.data?['videos'] as List<dynamic>? ?? <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(VideoModel.fromMap)
          .toList(growable: false);
      return videos;
    } on DioException catch (e) {
      throw ServerException('Failed to fetch videos: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error while fetching videos: $e');
    }
  }
}
