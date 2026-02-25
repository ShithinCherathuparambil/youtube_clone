import 'dart:io';

import 'package:injectable/injectable.dart';

import '../datasources/download_remote_data_source.dart';

/// Small orchestration layer for queued/background-friendly downloads.
///
/// You can swap this with `workmanager`/native foreground service later
/// without changing repository contracts.
@lazySingleton
class BackgroundDownloadService {
  BackgroundDownloadService(this._remoteDataSource);

  final DownloadRemoteDataSource _remoteDataSource;

  Future<File> startDownload({
    required String sourceUrl,
    required String fileName,
    required void Function(double progress) onProgress,
  }) {
    return _remoteDataSource.downloadToTemp(
      sourceUrl,
      fileName: fileName,
      onProgress: onProgress,
    );
  }
}
