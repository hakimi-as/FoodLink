class FeedFilter {
  final bool halalOnly;
  final int? maxExpiryHours; // null = any
  final int minQuantity;

  const FeedFilter({
    this.halalOnly = false,
    this.maxExpiryHours,
    this.minQuantity = 1,
  });

  bool get isDefault =>
      !halalOnly && maxExpiryHours == null && minQuantity == 1;

  int get activeCount =>
      (halalOnly ? 1 : 0) +
      (maxExpiryHours != null ? 1 : 0) +
      (minQuantity > 1 ? 1 : 0);

  FeedFilter copyWith({
    bool? halalOnly,
    Object? maxExpiryHours = _sentinel,
    int? minQuantity,
  }) =>
      FeedFilter(
        halalOnly: halalOnly ?? this.halalOnly,
        maxExpiryHours: maxExpiryHours == _sentinel
            ? this.maxExpiryHours
            : maxExpiryHours as int?,
        minQuantity: minQuantity ?? this.minQuantity,
      );
}

const _sentinel = Object();
