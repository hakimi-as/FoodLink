import 'package:flutter/material.dart';

// --- SCALER WIDGET ---
class HoverScaler extends StatefulWidget {
  final Widget child;
  final double scaleFactor;
  final VoidCallback? onTap;

  const HoverScaler({
    super.key,
    required this.child,
    this.scaleFactor = 1.05,
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
        // Using AnimatedContainer with diagonal3Values fixes the Matrix4.scale deprecation
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.diagonal3Values(
            _isHovered ? widget.scaleFactor : 1.0,
            _isHovered ? widget.scaleFactor : 1.0,
            1.0,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// --- GRADIENT BUTTON WIDGET ---
class HoverGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final double? width;
  final double height;
  final Color colorStart;
  final Color colorEnd;

  const HoverGradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.width,
    this.height = 55,
    this.colorStart = const Color(0xFFEA580C),
    this.colorEnd = const Color(0xFFF97316),
  });

  @override
  State<HoverGradientButton> createState() => _HoverGradientButtonState();
}

class _HoverGradientButtonState extends State<HoverGradientButton> {
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
          width: widget.width ?? double.infinity,
          height: widget.height,
          // Moves button UP by 3 pixels when hovered
          transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.colorStart, widget.colorEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                // Uses .withValues to fix the 'withOpacity' deprecation warning
                color: widget.colorStart.withValues(alpha: _isHovered ? 0.6 : 0.3),
                blurRadius: _isHovered ? 16 : 8,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}