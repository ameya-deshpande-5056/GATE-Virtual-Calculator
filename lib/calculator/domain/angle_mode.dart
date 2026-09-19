import 'dart:math' as math;

/// Angle unit used by the trigonometric functions.
///
/// The reference calculator exposes exactly two radio buttons (`Deg` / `Rad`)
/// and defaults to degrees.  Every degree/radian conversion in the application
/// goes through this type - no conversions are scattered through the widgets.
enum AngleMode {
  degree('Deg'),
  radian('Rad');

  const AngleMode(this.label);

  /// Label shown next to the radio button on the reference calculator.
  final String label;

  /// Converts a value expressed in this mode into radians.
  double toRadians(double value) =>
      this == AngleMode.degree ? value * math.pi / 180.0 : value;

  /// Converts a value expressed in radians into this mode.
  double fromRadians(double value) =>
      this == AngleMode.degree ? value * 180.0 / math.pi : value;

  /// Parses a persisted/encoded name, falling back to [AngleMode.degree].
  static AngleMode fromName(String? name) => AngleMode.values.firstWhere(
        (AngleMode mode) => mode.name == name,
        orElse: () => AngleMode.degree,
      );
}
