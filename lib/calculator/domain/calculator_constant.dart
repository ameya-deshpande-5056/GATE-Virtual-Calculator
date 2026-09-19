/// Mathematical constants that are present on the reference keypad.
///
/// The reference calculator only exposes `pi` and `e` (no `phi`, `tau`, ...).
/// The `text` is what the expression display prints when a constant is used.
enum CalculatorConstant {
  pi('pi', '3.14159265358979323846'),
  e('e', '2.71828182845904523536');

  const CalculatorConstant(this.symbol, this.literal);

  /// Text printed in the expression display.
  final String symbol;

  /// Decimal literal of the constant, used as the double value.
  final String literal;

  /// The constant as a [double].
  double get value => double.parse(literal);

  static CalculatorConstant? fromName(String? name) {
    for (final CalculatorConstant constant in CalculatorConstant.values) {
      if (constant.name == name) {
        return constant;
      }
    }
    return null;
  }
}