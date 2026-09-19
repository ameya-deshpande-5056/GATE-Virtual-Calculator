import 'dart:math' as math;

/// Root helpers shared by the square/cube/y-root keys.
///
/// `dart:math` provides `sqrt` but neither `cbrt` nor `nthRoot`, and the naive
/// `pow(x, 1 / n)` is one ULP low for exact roots:
///
/// * `pow(125, 1 / 3) == 4.999999999999999`, while the reference prints `5`
///   for `cuberoot(125)`.
/// * `pow(8, 0.25) == 1.681792830507429`, while the reference prints
///   `1.6817928305074292` for `8 yroot 4`.
///
/// Both reference behaviours are reproduced here:
///
/// * cube roots get one Newton refinement step, which lands exactly on `5`;
/// * even root indices are computed by repeated square roots, which is what the
///   reference value for `8 yroot 4` corresponds to (`sqrt(sqrt(8))`).
class RootMath {
  const RootMath._();

  /// Real cube root of [value] (negative values are supported).
  static double cubeRoot(double value) {
    if (value == 0) {
      return 0;
    }
    final double magnitude = value.abs();
    final double estimate = math.pow(magnitude, 1 / 3).toDouble();
    if (estimate == 0 || !estimate.isFinite) {
      return value < 0 ? -estimate : estimate;
    }
    final double root = (2 * estimate + magnitude / (estimate * estimate)) / 3;
    return value < 0 ? -root : root;
  }

  /// Real [index]-th root of [value] where one exists.
  ///
  /// Returns `null` when no real root exists, so callers decide which
  /// calculator error to report.
  static double? nthRoot(double value, double index) {
    if (index == 0 || index.isNaN) {
      return null;
    }
    if (value == 0) {
      return index > 0 ? 0 : null;
    }
    if (!_isIntegral(index)) {
      return value < 0 ? null : math.pow(value, 1 / index).toDouble();
    }
    final int exponent = index.toInt();
    if (value < 0) {
      if (exponent.isEven) {
        return null;
      }
      return -_positiveRoot(-value, exponent.abs());
    }
    if (exponent < 0) {
      final double positive = _positiveRoot(value, -exponent);
      return positive == 0 ? null : 1 / positive;
    }
    return _positiveRoot(value, exponent);
  }

  static double _positiveRoot(double value, int index) {
    if (index == 1) {
      return value;
    }
    if (index == 2) {
      return math.sqrt(value);
    }
    if (index == 3) {
      return cubeRoot(value);
    }
    if (index.isEven) {
      // Repeated square roots, matching the reference's `8 yroot 4` result.
      return math.sqrt(_positiveRoot(value, index ~/ 2));
    }
    return math.pow(value, 1 / index).toDouble();
  }

  static bool _isIntegral(double value) =>
      value.isFinite && value == value.roundToDouble();
}