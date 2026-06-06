import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../models/feed_filter.dart';

class FilterSheet extends StatefulWidget {
  final FeedFilter initialFilter;
  final ValueChanged<FeedFilter> onApply;

  const FilterSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required FeedFilter initialFilter,
    required ValueChanged<FeedFilter> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        initialFilter: initialFilter,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late bool _halal;
  late int? _maxExpiry;
  late int _minQty;

  @override
  void initState() {
    super.initState();
    _halal = widget.initialFilter.halalOnly;
    _maxExpiry = widget.initialFilter.maxExpiryHours;
    _minQty = widget.initialFilter.minQuantity;
  }

  FeedFilter get _current => FeedFilter(
        halalOnly: _halal,
        maxExpiryHours: _maxExpiry,
        minQuantity: _minQty,
      );

  void _apply() {
    widget.onApply(_current);
    Navigator.pop(context);
  }

  void _clear() {
    setState(() {
      _halal = false;
      _maxExpiry = null;
      _minQty = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: c.isDark ? Border.all(color: c.border) : null,
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: c.border, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters',
                  style: GoogleFonts.sora(
                      fontSize: 20, fontWeight: FontWeight.w700, color: c.text)),
              TextButton(
                onPressed: _clear,
                child: Text('Clear All',
                    style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Halal Only
          _SectionLabel('Dietary'),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _halal = !_halal);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _halal ? AppColors.primaryLight : c.elevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _halal ? AppColors.primary : c.border,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Text('🕌', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Halal Only',
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: c.text)),
                        Text('Show only halal-certified food',
                            style: GoogleFonts.dmSans(
                                fontSize: 11.5, color: c.muted)),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _halal ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _halal ? AppColors.primary : c.border,
                        width: 2,
                      ),
                    ),
                    child: _halal
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Expiry Window
          _SectionLabel('Expiry Window'),
          const SizedBox(height: 10),
          Row(
            children: [
              _ExpiryChip(label: 'Any', value: null, selected: _maxExpiry == null,
                  onTap: () => setState(() => _maxExpiry = null)),
              const SizedBox(width: 8),
              _ExpiryChip(label: '1h', value: 1, selected: _maxExpiry == 1,
                  onTap: () => setState(() => _maxExpiry = 1)),
              const SizedBox(width: 8),
              _ExpiryChip(label: '2h', value: 2, selected: _maxExpiry == 2,
                  onTap: () => setState(() => _maxExpiry = 2)),
              const SizedBox(width: 8),
              _ExpiryChip(label: '4h', value: 4, selected: _maxExpiry == 4,
                  onTap: () => setState(() => _maxExpiry = 4)),
            ],
          ),
          const SizedBox(height: 24),
          // Min Quantity
          _SectionLabel('Minimum Portions'),
          const SizedBox(height: 10),
          Row(
            children: [
              _QtyChip(label: '1+', value: 1, selected: _minQty == 1,
                  onTap: () => setState(() => _minQty = 1)),
              const SizedBox(width: 8),
              _QtyChip(label: '2+', value: 2, selected: _minQty == 2,
                  onTap: () => setState(() => _minQty = 2)),
              const SizedBox(width: 8),
              _QtyChip(label: '5+', value: 5, selected: _minQty == 5,
                  onTap: () => setState(() => _minQty = 5)),
            ],
          ),
          const SizedBox(height: 28),
          // Apply button
          GestureDetector(
            onTap: _apply,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              alignment: Alignment.center,
              child: Text('Apply Filters',
                  style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Text(label.toUpperCase(),
        style: GoogleFonts.dmSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: c.muted,
            letterSpacing: 0.8));
  }
}

class _ExpiryChip extends StatelessWidget {
  final String label;
  final int? value;
  final bool selected;
  final VoidCallback onTap;
  const _ExpiryChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 42,
          decoration: BoxDecoration(
            color: selected ? c.text : c.elevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? c.text : c.border, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : c.muted)),
        ),
      ),
    );
  }
}

class _QtyChip extends StatelessWidget {
  final String label;
  final int value;
  final bool selected;
  final VoidCallback onTap;
  const _QtyChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 42,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : c.elevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? AppColors.primary : c.border, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : c.muted)),
        ),
      ),
    );
  }
}
