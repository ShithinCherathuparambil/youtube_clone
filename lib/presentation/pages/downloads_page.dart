import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/download_item.dart';
import '../bloc/download/download_manager_cubit.dart';
import '../bloc/download/download_manager_state.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadManagerCubit, DownloadManagerState>(
      builder: (context, state) {
        if (state.downloads.isEmpty) {
          return const Center(child: Text('No downloads yet'));
        }

        return ListView.builder(
          key: const PageStorageKey('downloads_storage'),
          itemCount: state.downloads.length,
          itemBuilder: (context, index) {
            final item = state.downloads[index];
            return ListTile(
              leading: _statusIcon(item.status),
              title: Text(item.title),
              subtitle: Text(
                item.status == DownloadStatus.failed
                    ? (item.errorMessage ?? 'Failed')
                    : '${(item.progress * 100).toStringAsFixed(0)}% • ${item.status.name}',
              ),
            );
          },
        );
      },
    );
  }

  Widget _statusIcon(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case DownloadStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
      case DownloadStatus.downloading:
      case DownloadStatus.encrypting:
      case DownloadStatus.queued:
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
    }
  }
}
