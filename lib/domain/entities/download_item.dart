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
    this.taskId,
    this.errorMessage,
  });

  final String videoId;
  final String title;
  final String sourceUrl;
  final String outputPath;
  final DownloadStatus status;
  final double progress;
  final String? taskId;
  final String? errorMessage;

  DownloadItem copyWith({
    DownloadStatus? status,
    double? progress,
    String? outputPath,
    String? taskId,
    String? errorMessage,
  }) {
    return DownloadItem(
      videoId: videoId,
      title: title,
      sourceUrl: sourceUrl,
      outputPath: outputPath ?? this.outputPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      taskId: taskId ?? this.taskId,
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

  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'title': title,
      'sourceUrl': sourceUrl,
      'outputPath': outputPath,
      'status': status.index,
      'progress': progress,
      'taskId': taskId,
      'errorMessage': errorMessage,
    };
  }

  factory DownloadItem.fromMap(Map<String, dynamic> map) {
    return DownloadItem(
      videoId: map['videoId'] as String,
      title: map['title'] as String,
      sourceUrl: map['sourceUrl'] as String,
      outputPath: map['outputPath'] as String,
      status: DownloadStatus.values[map['status'] as int],
      progress: (map['progress'] as num).toDouble(),
      taskId: map['taskId'] as String?,
      errorMessage: map['errorMessage'] as String?,
    );
  }
}
