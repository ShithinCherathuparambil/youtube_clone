import 'package:equatable/equatable.dart';

import '../../../domain/entities/download_item.dart';

class DownloadManagerState extends Equatable {
  const DownloadManagerState({
    this.downloads = const <DownloadItem>[],
    this.isLoading = false,
    this.error,
  });

  final List<DownloadItem> downloads;
  final bool isLoading;
  final String? error;

  DownloadManagerState copyWith({
    List<DownloadItem>? downloads,
    bool? isLoading,
    String? error,
  }) {
    return DownloadManagerState(
      downloads: downloads ?? this.downloads,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [downloads, isLoading, error];
}
