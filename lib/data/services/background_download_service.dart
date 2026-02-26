import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@lazySingleton
class BackgroundDownloadService {
  BackgroundDownloadService() {
    _bindBackgroundIsolate();
  }

  static const String _portName = 'downloader_send_port';
  final ReceivePort _port = ReceivePort();
  final _progressController = StreamController<DownloadUpdate>.broadcast();

  Stream<DownloadUpdate> get progressStream => _progressController.stream;

  void _bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      _portName,
    );
    if (!isSuccess) {
      IsolateNameServer.removePortNameMapping(_portName);
      IsolateNameServer.registerPortWithName(_port.sendPort, _portName);
    }
    _port.listen((dynamic data) {
      final String id = data[0] as String;
      final int status = data[1] as int;
      final int progress = data[2] as int;
      _progressController.add(
        DownloadUpdate(
          taskId: id,
          status: DownloadTaskStatus.values[status],
          progress: progress.toDouble() / 100,
        ),
      );
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName(_portName);
    send?.send([id, status, progress]);
  }

  Future<String?> enqueue({
    required String url,
    required String fileName,
  }) async {
    final directory = await getTemporaryDirectory();
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: directory.path,
      fileName: fileName,
      showNotification: true,
      openFileFromNotification: false,
      saveInPublicStorage: false,
    );
    return taskId;
  }

  Future<void> pause(String taskId) => FlutterDownloader.pause(taskId: taskId);
  Future<void> resume(String taskId) =>
      FlutterDownloader.resume(taskId: taskId);
  Future<void> cancel(String taskId) =>
      FlutterDownloader.cancel(taskId: taskId);
  Future<void> remove(String taskId) =>
      FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: true);

  void dispose() {
    IsolateNameServer.removePortNameMapping(_portName);
    _progressController.close();
  }
}

class DownloadUpdate {
  final String taskId;
  final DownloadTaskStatus status;
  final double progress;

  DownloadUpdate({
    required this.taskId,
    required this.status,
    required this.progress,
  });
}
