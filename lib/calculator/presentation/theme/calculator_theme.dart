import 'package:flutter/material.dart';

/// Colours sampled from the reference screenshots
/// (`reference/KEYPAD_LAYOUT.md` documents the measurement).
abstract final class CalculatorColors {
  static const Color titleBar = Color(0xFF4286F3);
  static const Color helpButton = Color(0xFF56C0F4);
  static const Color body = Color(0xFFDADADA);
  static const Color displayBackground = Colors.white;
  static const Color displayBorder = Color(0xFFC1C1C1);
  static const Color displayText = Colors.black;

  static const Color keyFace = Color(0xFFF1F1F1);
  static const Color keyFaceNumeric = Color(0xFFE9E9E9);
  static const Color keyBorder = Color(0xFFAAAAAA);
  static const Color keyHighlight = Color(0x33FFFFFF);
  static const Color keyShadow = Color(0x33000000);
  static const Color keyText = Color(0xFF333333);

  static const Color redKey = Color(0xFFE84C3D);
  static const Color greenKey = Color(0xFF2DCC70);

  static const Color radioSelected = Color(0xFF1E88E5);
  static const Color radioIdle = Color(0xFF9E9E9E);
}

/// Visual variants of a key.
enum KeyStyle {
  /// Light grey function key.
  normal,

  /// Slightly darker numeric key.
  numeric,

  /// Red `←`, `C` and `+/-` keys.
  danger,

  /// Green `=` key.
  primary,
}

/// Layout metrics derived from the available width so that the keypad keeps
/// the reference proportions on wide screens and stays usable on phones.
@immutable
class CalculatorMetrics {
  const CalculatorMetrics({
    required this.pitch,
    required this.rowHeight,
    required this.keyFontSize,
    required this.displayHeight,
    required this.displayFontSize,
    required this.modeRowHeight,
  });

  /// The reference window is 706 px wide with 11 button columns.
  static const double referenceWindowWidth = 706;

  /// Column pitch in the reference (60 px, 52 px buttons + 8 px gap).
  static const double referencePitch = 60;

  /// Button row height in the reference (33 px).
  static const double referenceRowHeight = 33;

  /// Display box height in the reference (45 px).
  static const double referenceDisplayHeight = 45;

  /// The keypad always uses 11 columns.
  static const int columns = 11;

  factory CalculatorMetrics.fromWidth(double width) {
    final double pitch = width / columns;
    final double scale = pitch / referencePitch;
    return CalculatorMetrics(
      pitch: pitch,
      rowHeight: _clamp(pitch * (referenceRowHeight / referencePitch), 36, 40),
      keyFontSize: _clamp(15.5 * scale, 9.5, 16),
      displayHeight: _clamp(45 * scale, 32, 46),
      displayFontSize: _clamp(30 * scale, 17, 30),
      modeRowHeight: _clamp(pitch * (referenceRowHeight / referencePitch), 34, 38),
    );
  }

  static double _clamp(double value, double min, double max) =>
      value < min ? min : (value > max ? max : value);

  /// Horizontal distance between two button columns.
  final double pitch;

  /// Height of a keypad row.
  final double rowHeight;

  /// Height of the mode / memory row.
  final double modeRowHeight;

  /// Font size used for key labels.
  final double keyFontSize;

  /// Height of one display box.
  final double displayHeight;

  /// Font size used in the displays.
  final double displayFontSize;

  /// Gap between two buttons.
  double get gap => pitch * (8 / referencePitch);

  /// Width of a single-column button.
  double get keyWidth => pitch - gap;

  /// Vertical padding around the keypad.
  double get padding => pitch * (24 / referencePitch);

  /// Looks up the metrics provided by [CalculatorMetricsScope].
  static CalculatorMetrics of(BuildContext context) =>
      CalculatorMetricsScope.of(context);
}

/// Provides the metrics of the current calculator layout to the key widgets.
class CalculatorMetricsScope extends InheritedWidget {
  const CalculatorMetricsScope({
    required this.metrics,
    required super.child,
    super.key,
  });

  final CalculatorMetrics metrics;

  static CalculatorMetrics of(BuildContext context) {
    final CalculatorMetricsScope? scope =
        context.dependOnInheritedWidgetOfExactType<CalculatorMetricsScope>();
    assert(scope != null, 'CalculatorMetricsScope is missing from the tree');
    return scope!.metrics;
  }

  @override
  bool updateShouldNotify(CalculatorMetricsScope oldWidget) =>
      oldWidget.metrics != metrics;
}
