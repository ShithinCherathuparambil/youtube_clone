import 'package:equatable/equatable.dart';

import '../../../domain/entities/download_item.dart';
import '../../../domain/entities/storage_info.dart';

class DownloadManagerState extends Equatable {
  const DownloadManagerState({
    this.downloads = const [],
    this.isLoading = false,
    this.error,
    this.storageInfo,
  });

  final List<DownloadItem> downloads;
  final bool isLoading;
  final String? error;
  final StorageInfo? storageInfo;

  DownloadManagerState copyWith({
    List<DownloadItem>? downloads,
    bool? isLoading,
    String? error,
    StorageInfo? storageInfo,
  }) {
    return DownloadManagerState(
      downloads: downloads ?? this.downloads,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      storageInfo: storageInfo ?? this.storageInfo,
    );
  }

  @override
  List<Object?> get props => [downloads, isLoading, error, storageInfo];
}
