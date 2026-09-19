import 'dart:math' as math;

import '../../core/errors/calculator_exception.dart';
import 'calculator_error.dart';
import 'root_math.dart';

/// Binary operations of the calculator.
///
/// These are the *pending* operations described in the task specification:
/// every one of them needs a right hand operand that the user enters
/// afterwards.  `x^y`, `y-root` and `log_y x` are binary/special functions and
/// are modelled here as pending binary operations, while purely unary
/// functions live in `calculator_function.dart`.
///
/// [symbol] is the text the reference calculator prints in the expression
/// display:
///
/// * `mod`  - from the key label (inferred)
/// * `E`    - `Exp`, scientific-notation entry (inferred; the reference shows
///            a `-` sign inside the exponent area, e.g. `1.5E-3`)
/// * `^`    - verified by the `18^-0.509` screenshot
/// * `yroot`- verified by the `8yroot4` screenshot
/// * `log`  - `log_y x` (inferred)
enum CalculatorOperation {
  add('+', 1),
  subtract('-', 1),
  multiply('*', 2),
  divide('/', 2),
  modulo('mod', 2),
  exponentEntry('E', 3),

  /// `x^y`
  power('^', 4),

  /// `ʸ√x`
  yRoot('yroot', 4),

  /// `log_y x`
  logBase('log', 4);

  const CalculatorOperation(this.symbol, this.precedence);

  /// Text printed in the expression display.
  final String symbol;

  /// Higher binds tighter.  Standard arithmetic precedence, matching the
  /// reference examples (`60 + 35 * 5` evaluates to 235).
  final int precedence;

  /// Applies the operation to two already evaluated operands.
  ///
  /// Throws [CalculatorException] instead of returning `NaN`/`Infinity` so the
  /// engine can report an explicit error.
  double apply(double left, double right) {
    final double result;
    switch (this) {
      case CalculatorOperation.add:
        result = left + right;
      case CalculatorOperation.subtract:
        result = left - right;
      case CalculatorOperation.multiply:
        result = left * right;
      case CalculatorOperation.divide:
        if (right == 0) {
          throw const CalculatorException(CalculatorError.divisionByZero);
        }
        result = left / right;
      case CalculatorOperation.modulo:
        if (right == 0) {
          throw const CalculatorException(CalculatorError.divisionByZero);
        }
        // Truncating remainder, i.e. the C-style `mod` most calculators expose.
        result = left.remainder(right);
      case CalculatorOperation.exponentEntry:
        // `Exp` performs scientific-notation entry: `1.5 Exp 3` == 1500.
        result = left * math.pow(10, right);
      case CalculatorOperation.power:
        result = _power(left, right);
      case CalculatorOperation.yRoot:
        result = _root(left, right);
      case CalculatorOperation.logBase:
        if (left <= 0) {
          throw const CalculatorException(CalculatorError.logarithmDomain);
        }
        if (right <= 0 || right == 1) {
          throw const CalculatorException(CalculatorError.logarithmDomain);
        }
        result = math.log(left) / math.log(right);
    }
    if (result.isNaN) {
      throw const CalculatorException(CalculatorError.undefinedResult);
    }
    if (result.isInfinite) {
      throw const CalculatorException(CalculatorError.overflow);
    }
    return result;
  }

  /// `left ^ right`, supporting negative bases with integral exponents.
  static double _power(double left, double right) {
    if (_isIntegral(right)) {
      return math.pow(left, right).toDouble();
    }
    if (left < 0) {
      throw const CalculatorException(CalculatorError.rootDomain);
    }
    return math.pow(left, right).toDouble();
  }

  /// `right`-th root of `left`, i.e. `left ^ (1 / right)`.
  ///
  /// Verified against the reference: `8 yroot 4` == `1.6817928305074292`.
  static double _root(double left, double right) {
    final double? result = RootMath.nthRoot(left, right);
    if (result == null) {
      throw const CalculatorException(CalculatorError.rootDomain);
    }
    return result;
  }

  static bool _isIntegral(double value) =>
      value.isFinite && value == value.roundToDouble() && value.abs() < 1e15;
}