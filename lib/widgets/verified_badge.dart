import 'package:flutter/material.dart';

/// Small blue checkmark badge shown next to verified donors' names.
class VerifiedBadge extends StatelessWidget {
  final double size;

  const VerifiedBadge({super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF2563EB),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check, color: Colors.white, size: size * 0.7),
    );
  }
}
