import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/download_item.dart';
import '../../../domain/usecases/get_cached_downloads.dart';
import '../../../domain/usecases/start_encrypted_download.dart';
import '../../../core/services/storage_service.dart';
import '../../../domain/usecases/delete_download.dart';
import '../../../domain/usecases/get_decrypted_file.dart';
import 'download_manager_state.dart';

@injectable
class DownloadManagerCubit extends Cubit<DownloadManagerState> {
  DownloadManagerCubit(
    this._startEncryptedDownload,
    this._getCachedDownloads,
    this._deleteDownload,
    this._getDecryptedFile,
    this._storageService,
  ) : super(const DownloadManagerState());

  final StartEncryptedDownload _startEncryptedDownload;
  final GetCachedDownloads _getCachedDownloads;
  final DeleteDownload _deleteDownload;
  final GetDecryptedFile _getDecryptedFile;
  final StorageService _storageService;

  Future<void> loadStorageInfo() async {
    final info = await _storageService.getStorageInfo();
    emit(state.copyWith(storageInfo: info));
  }

  Future<void> deleteDownloads(List<String> videoIds) async {
    final result = await _deleteDownload(
      DeleteDownloadParams(videoIds: videoIds),
    );
    result.fold((failure) => emit(state.copyWith(error: failure.message)), (_) {
      final newList = state.downloads
          .where((item) => !videoIds.contains(item.videoId))
          .toList();
      emit(state.copyWith(downloads: newList));
      loadStorageInfo();
    });
  }

  Future<void> loadCachedDownloads() async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _getCachedDownloads(const NoParams());
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (downloads) => emit(
        state.copyWith(isLoading: false, downloads: downloads, error: null),
      ),
    );
  }

  Future<void> queueDownload({
    required String videoId,
    required String title,
    required String sourceUrl,
  }) async {
    final queued = DownloadItem(
      videoId: videoId,
      title: title,
      sourceUrl: sourceUrl,
      outputPath: '',
      status: DownloadStatus.queued,
      progress: 0,
      taskId: null,
    );
    _upsert(queued);

    final downloading = queued.copyWith(
      status: DownloadStatus.downloading,
      progress: 0,
    );
    _upsert(downloading);

    final result = await _startEncryptedDownload(
      StartEncryptedDownloadParams(
        item: downloading,
        onProgress: (progress) {
          _upsert(
            downloading.copyWith(
              status: DownloadStatus.downloading,
              progress: progress,
            ),
          );
        },
      ),
    );

    result.fold((failure) {
      _upsert(
        downloading.copyWith(
          status: DownloadStatus.failed,
          errorMessage: failure.message,
        ),
      );
      emit(state.copyWith(error: failure.message));
    }, (completed) => _upsert(completed));
  }

  Future<File?> getDecryptedFile(String videoId, String encryptedPath) async {
    final result = await _getDecryptedFile(
      GetDecryptedFileParams(videoId: videoId, encryptedPath: encryptedPath),
    );
    return result.fold((failure) {
      emit(state.copyWith(error: failure.message));
      return null;
    }, (file) => file);
  }

  void _upsert(DownloadItem item) {
    final list = [...state.downloads];
    final index = list.indexWhere((element) => element.videoId == item.videoId);
    if (index >= 0) {
      list[index] = item;
    } else {
      list.insert(0, item);
    }
    emit(state.copyWith(downloads: list, error: null));
  }
}
