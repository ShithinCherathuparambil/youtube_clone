import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class VideoCardShimmer extends StatelessWidget {
  const VideoCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 200, color: Colors.white),
            const SizedBox(height: 10),
            Container(height: 16, width: 220, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 14, width: 160, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
