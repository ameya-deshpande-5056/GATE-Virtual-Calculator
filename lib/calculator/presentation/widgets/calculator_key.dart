import 'package:flutter/material.dart';

import '../theme/calculator_theme.dart';

/// A single calculator button.
///
/// Keys are dumb: they render [child] and hand [onPressed] up to the keypad,
/// which dispatches a `CalculatorAction`.  The semantic label makes every key
/// accessible without relying on its symbol.
class CalculatorKey extends StatelessWidget {
  const CalculatorKey({
    required this.child,
    required this.semanticLabel,
    required this.onPressed,
    required this.metrics,
    this.style = KeyStyle.normal,
    this.enabled = true,
    super.key,
  });

  final Widget child;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final CalculatorMetrics metrics;
  final KeyStyle style;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color face = switch (style) {
      KeyStyle.danger => CalculatorColors.redKey,
      KeyStyle.primary => CalculatorColors.greenKey,
      KeyStyle.numeric => CalculatorColors.keyFaceNumeric,
      KeyStyle.normal => CalculatorColors.keyFace,
    };
    final Color foreground = switch (style) {
      KeyStyle.danger || KeyStyle.primary => Colors.white,
      _ => CalculatorColors.keyText,
    };

    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Material(
          color: Colors.transparent,
          shape: _KeyBorder(),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            customBorder: _KeyBorder(),
            child: Ink(
              decoration: BoxDecoration(
                color: face,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CalculatorColors.keyBorder),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: metrics.keyFontSize,
                      height: 1.0,
                      color: foreground,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    child: IconTheme(
                      data: IconThemeData(
                        size: metrics.keyFontSize * 1.3,
                        color: foreground,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 1 px grey border with the calculator key corner radius.
class _KeyBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(1);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Rect inset = rect.deflate(0.5);
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(inset, const Radius.circular(8)),
      );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

/// Label helpers for keys whose text contains a superscript or subscript part
/// (`sinh⁻¹`, `x^y`, `log₂x`, `ʸ√x`).
class KeyLabels {
  const KeyLabels._();

  /// `base` with a raised [script] fragment, e.g. `x` + `y` for `x^y`.
  static Widget superscript(String base, String script) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: base),
          WidgetSpan(
            alignment: PlaceholderAlignment.aboveBaseline,
            baseline: TextBaseline.alphabetic,
            child: Text(script, style: const TextStyle(height: 1.0)),
          ),
        ],
      ),
      maxLines: 1,
    );
  }

  /// `base` with a lowered [script] fragment, e.g. `log` + `2` + `x`.
  static Widget subscript(String base, String script, [String? tail]) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: base),
          WidgetSpan(
            alignment: PlaceholderAlignment.belowBaseline,
            baseline: TextBaseline.alphabetic,
            child: Text(script, style: const TextStyle(height: 1.0)),
          ),
          if (tail != null) TextSpan(text: tail),
        ],
      ),
      maxLines: 1,
    );
  }

  /// A radical sign with an optional index and radicand, e.g. `ʸ√x`.
  static Widget radical({String? index, String? radicand}) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          if (index != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.aboveBaseline,
              baseline: TextBaseline.alphabetic,
              child: Text(index, style: const TextStyle(height: 1.0)),
            ),
          const TextSpan(text: '\u221A'),
          if (radicand != null) TextSpan(text: radicand),
        ],
      ),
      maxLines: 1,
    );
  }
}
