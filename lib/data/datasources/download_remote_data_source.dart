import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';

abstract class DownloadRemoteDataSource {
  Future<File> downloadToTemp(
    String url, {
    required String fileName,
    required void Function(double progress) onProgress,
  });
}

@LazySingleton(as: DownloadRemoteDataSource)
class DownloadRemoteDataSourceImpl implements DownloadRemoteDataSource {
  DownloadRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<File> downloadToTemp(
    String url, {
    required String fileName,
    required void Function(double progress) onProgress,
  }) async {
    try {
      final tempDir = Directory.systemTemp;
      final path = '${tempDir.path}/$fileName';
      await _dioClient.dio.download(
        url,
        path,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress(received / total);
          }
        },
      );
      return File(path);
    } on DioException catch (e) {
      throw ServerException('Download failed: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected download error: $e');
    }
  }
}
