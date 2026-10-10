

/// Một quy tắc mã giảm giá. Dữ liệu thay cho chuỗi if-else lặp theo từng mã.
class PromoRule {
  final String code;
  final double minSubtotal;
  final double discountRate;

  const PromoRule({
    required this.code,
    required this.minSubtotal,
    required this.discountRate,
  });

  bool isApplicable(double subtotal) => subtotal >= minSubtotal;

  double discountFor(double subtotal) => subtotal * discountRate;
}

const List<PromoRule> defaultPromoRules = [
  PromoRule(code: 'MOVIE10', minSubtotal: 100000, discountRate: 0.10),
  PromoRule(code: 'WELCOME', minSubtotal: 50000, discountRate: 0.15),
];
