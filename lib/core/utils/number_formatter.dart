/// Display formatting for the GATE virtual calculator.
///
/// Numerical evaluation and display formatting are deliberately separate: the
/// engine always keeps full `double` precision and only [NumberFormatter]
/// decides how a value is written into the result display.
///
/// Every result in the reference screenshots is byte-identical to JavaScript's
/// `Number.prototype.toString()` applied to the same double:
///
/// | keys                        | reference result        |
/// |-----------------------------|-------------------------|
/// | `73 * (2 + 3) =`            | `365`                   |
/// | `48 x^3 * 6 + 9 =`          | `663561`                |
/// | `ln(15) * 2 + 3 =`          | `8.416100402204421`     |
/// | `tand(35) * 6 + 2 =`        | `6.201245229258259`     |
/// | `18 ^ 0.509 +/- =`          | `0.22964991811628313`   |
/// | `cuberoot(125)`             | `5`                     |
/// | `8 yroot 4 =`               | `1.6817928305074292`    |
/// | `fact(8) * 5 - 2 =`         | `201598`                |
///
/// In particular `0.22964991811628313` has 17 significant digits and
/// `1.6817928305074292` is one ULP above the correctly rounded fourth root of
/// eight, so the display is *not* a fixed-precision decimal rendering.
///
/// Dart's `double.toString()` uses the same shortest-round-trip algorithm with
/// the same exponent-notation thresholds (`< 1e-6`, `>= 1e21`), so the value is
/// printed verbatim, with the single difference that Dart appends `.0` to
/// integral doubles whereas JavaScript does not.
class NumberFormatter {
  const NumberFormatter._();

  /// Text shown when a calculation fails.
  static const String errorText = 'Error';

  /// Renders [value] exactly the way the calculator's result display should.
  ///
  /// `NaN` and infinities are reported as [errorText]; the engine normally
  /// converts those into an explicit calculator error before formatting.
  static String format(double value) {
    if (value.isNaN || value.isInfinite) {
      return errorText;
    }
    if (value == 0) {
      // Collapses `-0.0` onto `0`.
      return '0';
    }
    final String text = value.toString();
    return text.endsWith('.0')
        ? text.substring(0, text.length - 2)
        : text;
  }

  /// Parses the digits the user typed into a value.
  ///
  /// Returns `null` for buffers that are not (yet) a number, e.g. an empty
  /// buffer or a lone `.`.
  static double? tryParseInput(String digits) {
    if (digits.isEmpty) {
      return null;
    }
    return double.tryParse(digits);
  }
}
