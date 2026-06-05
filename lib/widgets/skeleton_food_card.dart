import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonFoodCard extends StatelessWidget {
  const SkeletonFoodCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlight = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: base,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(width: 90, height: 10),
                  const SizedBox(height: 8),
                  _box(width: 180, height: 14),
                  const SizedBox(height: 10),
                  _box(width: 130, height: 10),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _box(width: 80, height: 10),
                      _box(width: 90, height: 36, radius: 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box({required double width, required double height, double radius = 8}) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
