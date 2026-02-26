import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/download_item.dart';
import '../../../domain/usecases/get_cached_downloads.dart';
import '../../../domain/usecases/start_encrypted_download.dart';
import 'download_manager_state.dart';

@injectable
class DownloadManagerCubit extends Cubit<DownloadManagerState> {
  DownloadManagerCubit(this._startEncryptedDownload, this._getCachedDownloads)
    : super(const DownloadManagerState());

  final StartEncryptedDownload _startEncryptedDownload;
  final GetCachedDownloads _getCachedDownloads;

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
