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
    this.videoHash,
    this.isEncrypted = false,
  });

  final String videoId;
  final String title;
  final String sourceUrl;
  final String outputPath;
  final DownloadStatus status;
  final double progress;
  final String? taskId;
  final String? errorMessage;
  final String? videoHash;
  final bool isEncrypted;

  DownloadItem copyWith({
    DownloadStatus? status,
    double? progress,
    String? outputPath,
    String? taskId,
    String? errorMessage,
    String? videoHash,
    bool? isEncrypted,
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
      videoHash: videoHash ?? this.videoHash,
      isEncrypted: isEncrypted ?? this.isEncrypted,
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
    videoHash,
    isEncrypted,
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
      'videoHash': videoHash,
      'isEncrypted': isEncrypted,
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
      videoHash: map['videoHash'] as String?,
      isEncrypted: map['isEncrypted'] as bool? ?? false,
    );
  }
}
