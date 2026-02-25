import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/download/download_manager_cubit.dart';
import '../widgets/video_card_shimmer.dart';
import 'watch_page.dart';

class HomeFeedPage extends StatelessWidget {
  const HomeFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    // Demo list; replace with API-backed list from BLoC.
    final demoVideos = <Map<String, String>>[
      {
        'id': 'a1',
        'title': 'Flutter Clean Architecture in Practice',
        'channel': 'DevLab',
        'thumb': 'https://picsum.photos/id/12/800/450',
        'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      },
      {
        'id': 'a2',
        'title': 'Build YouTube Feed UI with BLoC',
        'channel': 'CodeStream',
        'thumb': 'https://picsum.photos/id/42/800/450',
        'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      },
      {
        'id': 'a3',
        'title': 'Secure Offline Playback with AES',
        'channel': 'Mobile Shield',
        'thumb': 'https://picsum.photos/id/102/800/450',
        'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 700;
        final cardHeight = isTablet ? 260.0 : mediaQuery.size.width * 0.56;

        return ListView.builder(
          key: const PageStorageKey('home_feed_storage'),
          padding: const EdgeInsets.all(12),
          itemCount: demoVideos.length,
          itemBuilder: (context, index) {
            final video = demoVideos[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WatchPage(
                            videoUrl: video['url']!,
                            title: video['title']!,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: video['thumb']!,
                        height: cardHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const VideoCardShimmer(),
                        errorWidget: (_, _, __) => Container(
                          color: Colors.black12,
                          height: cardHeight,
                          alignment: Alignment.center,
                          child: const Text('Thumbnail unavailable'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(video['title']!, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${video['channel']} • ${NumberFormat.compact().format(120000 + index * 20000)} views',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Download encrypted video',
                        onPressed: () {
                          context.read<DownloadManagerCubit>().queueDownload(
                                videoId: video['id']!,
                                title: video['title']!,
                                sourceUrl: video['url']!,
                              );
                        },
                        icon: const Icon(Icons.download),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
