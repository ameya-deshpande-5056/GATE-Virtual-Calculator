import 'dart:math' as math;

import '../../core/errors/calculator_exception.dart';
import 'angle_mode.dart';
import 'calculator_error.dart';
import 'root_math.dart';

/// Unary functions of the calculator.
///
/// Every one of these is applied to the operand the user has *already* entered
/// (`25 -> sin`), never the other way around.
///
/// [displayName] is the text the expression display prints.  Verified against
/// the reference screenshots: `tand(35)*6+2`, `ln(15)*2+3`, `fact(8)*5-2`,
/// `cuberoot(125)`.  The remaining names follow the same library style and are
/// documented as *inferred* in `KNOWN_DIFFERENCES.md`.
enum CalculatorFunction {
  // Trigonometric (angle-mode dependent: printed as `tand` in Deg mode).
  sin('sin', degreeName: 'sind', radianName: 'sin'),
  cos('cos', degreeName: 'cosd', radianName: 'cos'),
  tan('tan', degreeName: 'tand', radianName: 'tan'),
  asin('asin'),
  acos('acos'),
  atan('atan'),

  // Hyperbolic (never angle-mode dependent).
  sinh('sinh'),
  cosh('cosh'),
  tanh('tanh'),
  asinh('asinh'),
  acosh('acosh'),
  atanh('atanh'),

  // Logarithms.
  log('log'),
  ln('ln'),
  log2('log2'),

  // Roots, powers and powers-of-ten.
  squareRoot('sqrt'),
  cubeRoot('cuberoot'),
  square('square'),
  cube('cube'),
  exponential('exp'),
  tenPow('10pow'),
  reciprocal('reciprocal'),

  // Miscellaneous.
  factorial('fact'),
  percent('percent'),
  absolute('abs');

  const CalculatorFunction(this.name, {String? degreeName, String? radianName})
      : _degreeName = degreeName ?? name,
        _radianName = radianName ?? name;

  /// Default display name.
  final String name;

  final String _degreeName;
  final String _radianName;

  /// Text printed in the expression display, e.g. `fact(8)`.
  String displayName(AngleMode mode) =>
      mode == AngleMode.degree ? _degreeName : _radianName;

  /// Largest input accepted by [CalculatorFunction.factorial].
  static const int maxFactorialInput = 170;

  /// Applies the function to [value] using the current [mode] for the
  /// trigonometric functions.
  ///
  /// Throws a [CalculatorException] for every mathematically invalid input so
  /// the engine can surface an explicit error state.
  double apply(double value, AngleMode mode) {
    final double result;
    switch (this) {
      case CalculatorFunction.sin:
        result = math.sin(mode.toRadians(value));
      case CalculatorFunction.cos:
        result = math.cos(mode.toRadians(value));
      case CalculatorFunction.tan:
        result = math.tan(mode.toRadians(value));
      case CalculatorFunction.asin:
        _requireUnitInterval(value);
        result = mode.fromRadians(math.asin(value));
      case CalculatorFunction.acos:
        _requireUnitInterval(value);
        result = mode.fromRadians(math.acos(value));
      case CalculatorFunction.atan:
        result = mode.fromRadians(math.atan(value));
      case CalculatorFunction.sinh:
        result = _finite((math.exp(value) - math.exp(-value)) / 2);
      case CalculatorFunction.cosh:
        result = _finite((math.exp(value) + math.exp(-value)) / 2);
      case CalculatorFunction.tanh:
        result = _tanh(value);
      case CalculatorFunction.asinh:
        result = _finite(math.log(value + math.sqrt(value * value + 1)));
      case CalculatorFunction.acosh:
        if (value < 1) {
          throw const CalculatorException(
            CalculatorError.hyperbolicDomain,
            'acosh requires a value >= 1',
          );
        }
        result = _finite(math.log(value + math.sqrt(value * value - 1)));
      case CalculatorFunction.atanh:
        if (value.abs() >= 1) {
          throw const CalculatorException(
            CalculatorError.hyperbolicDomain,
            'atanh requires a value strictly between -1 and 1',
          );
        }
        result = math.log((1 + value) / (1 - value)) / 2;
      case CalculatorFunction.log:
        result = _logarithm(value, 10);
      case CalculatorFunction.ln:
        result = _logarithm(value, math.e);
      case CalculatorFunction.log2:
        result = _logarithm(value, 2);
      case CalculatorFunction.squareRoot:
        if (value < 0) {
          throw const CalculatorException(CalculatorError.squareRootDomain);
        }
        result = math.sqrt(value);
      case CalculatorFunction.cubeRoot:
        result = RootMath.cubeRoot(value);
      case CalculatorFunction.square:
        result = _finite(value * value);
      case CalculatorFunction.cube:
        result = _finite(value * value * value);
      case CalculatorFunction.exponential:
        result = _finite(math.exp(value));
      case CalculatorFunction.tenPow:
        result = _finite(math.pow(10, value).toDouble());
      case CalculatorFunction.reciprocal:
        if (value == 0) {
          throw const CalculatorException(CalculatorError.divisionByZero);
        }
        result = 1 / value;
      case CalculatorFunction.factorial:
        result = _factorial(value);
      case CalculatorFunction.percent:
        result = value / 100;
      case CalculatorFunction.absolute:
        result = value.abs();
    }
    if (result.isNaN) {
      throw const CalculatorException(CalculatorError.undefinedResult);
    }
    if (result.isInfinite) {
      throw const CalculatorException(CalculatorError.overflow);
    }
    return result;
  }

  static void _requireUnitInterval(double value) {
    if (value < -1 || value > 1) {
      throw const CalculatorException(CalculatorError.inverseTrigDomain);
    }
  }

  static double _logarithm(double value, double base) {
    if (value <= 0) {
      throw const CalculatorException(CalculatorError.logarithmDomain);
    }
    return math.log(value) / math.log(base);
  }

  /// Factorial of a non-negative integer, with an explicit error for every
  /// other input (the reference calculator has no gamma extension).
  static double _factorial(double value) {
    if (value < 0 || !_isIntegral(value)) {
      throw const CalculatorException(
        CalculatorError.factorialDomain,
        'factorial requires a non-negative integer',
      );
    }
    if (value > maxFactorialInput) {
      throw const CalculatorException(CalculatorError.factorialOverflow);
    }
    double result = 1;
    for (int i = 2; i <= value.toInt(); i++) {
      result *= i;
    }
    return result;
  }

  /// Rejects results that overflowed to `NaN`/infinity.
  static double _finite(double value) {
    if (value.isInfinite || value.isNaN) {
      throw const CalculatorException(CalculatorError.overflow);
    }
    return value;
  }

  static double _tanh(double value) {
    if (value > 20) {
      return 1;
    }
    if (value < -20) {
      return -1;
    }
    final double squared = math.exp(2 * value);
    return (squared - 1) / (squared + 1);
  }

  static bool _isIntegral(double value) =>
      value.isFinite && value == value.roundToDouble();
}