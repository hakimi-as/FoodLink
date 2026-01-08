import 'package:flutter/material.dart';

class HoverScaler extends StatefulWidget {
  final Widget child;
  final double scaleFactor;
  final VoidCallback? onTap;

  const HoverScaler({
    super.key,
    required this.child,
    this.scaleFactor = 1.05, // Default zoom is 5%
    this.onTap,
  });

  @override
  State<HoverScaler> createState() => _HoverScalerState();
}

class _HoverScalerState extends State<HoverScaler> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic, // Makes the movement feel "physics-based"
          transform: Matrix4.identity()
            ..scale(_isHovered ? widget.scaleFactor : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3), // Orange glow
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [], // No shadow when not hovered
          ),
          child: widget.child,
        ),
      ),
    );
  }
}