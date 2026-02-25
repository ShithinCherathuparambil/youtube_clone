import 'package:equatable/equatable.dart';

enum DownloadStatus { queued, downloading, encrypting, completed, failed }

class DownloadItem extends Equatable {
  const DownloadItem({
    required this.videoId,
    required this.title,
    required this.sourceUrl,
    required this.outputPath,
    required this.status,
    required this.progress,
    this.errorMessage,
  });

  final String videoId;
  final String title;
  final String sourceUrl;
  final String outputPath;
  final DownloadStatus status;
  final double progress;
  final String? errorMessage;

  DownloadItem copyWith({
    DownloadStatus? status,
    double? progress,
    String? outputPath,
    String? errorMessage,
  }) {
    return DownloadItem(
      videoId: videoId,
      title: title,
      sourceUrl: sourceUrl,
      outputPath: outputPath ?? this.outputPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        videoId,
        title,
        sourceUrl,
        outputPath,
        status,
        progress,
        errorMessage,
      ];
}
