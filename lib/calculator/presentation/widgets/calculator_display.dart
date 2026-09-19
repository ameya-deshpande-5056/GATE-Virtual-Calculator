import 'package:flutter/material.dart';

import '../theme/calculator_theme.dart';

/// The two display areas of the reference calculator.
///
/// They are two separate concepts and are rendered independently:
///
/// * [expression] - the key sequence the user entered (`fact(8)*5-2`).
/// * [result] - the current value or the last result (`201598`).
class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({
    required this.expression,
    required this.result,
    required this.metrics,
    this.errorMessage,
    super.key,
  });

  final String expression;
  final String result;
  final CalculatorMetrics metrics;

  /// Human readable description of the current error, if any.
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: errorMessage == null
          ? 'result $result'
          : 'error: $errorMessage',
      child: Column(
        children: <Widget>[
          _DisplayBox(
            key: const ValueKey<String>('expressionDisplay'),
            text: expression,
            metrics: metrics,
            hint: errorMessage,
          ),
          SizedBox(height: metrics.displayHeight * 0.28),
          _DisplayBox(
            key: const ValueKey<String>('resultDisplay'),
            text: result,
            metrics: metrics,
            hint: errorMessage,
            emphasis: true,
          ),
        ],
      ),
    );
  }
}

class _DisplayBox extends StatelessWidget {
  const _DisplayBox({
    super.key,
    required this.text,
    required this.metrics,
    this.hint,
    this.emphasis = false,
  });

  final String text;
  final CalculatorMetrics metrics;
  final String? hint;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final String value = text;
    return Container(
      height: metrics.displayHeight,
      padding: EdgeInsets.symmetric(horizontal: metrics.gap * 1.5),
      decoration: BoxDecoration(
        color: CalculatorColors.displayBackground,
        border: Border.all(color: CalculatorColors.displayBorder),
      ),
      alignment: Alignment.centerRight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Text(
          value,
          maxLines: 1,
          style: TextStyle(
            fontSize: metrics.displayFontSize,
            height: 1.0,
            color: CalculatorColors.displayText,
            fontWeight: emphasis ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
