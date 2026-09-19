import 'package:flutter/material.dart';

import '../../domain/calculator_action.dart';
import '../../domain/calculator_function.dart';
import 'calculator_key.dart';
import '../theme/calculator_theme.dart';

/// A key that applies a unary function to the operand the user has already
/// entered (`25 -> sin`), reproducing the GATE interaction model.
class FunctionKey extends StatelessWidget {
  const FunctionKey({
    required this.function,
    required this.label,
    required this.semanticLabel,
    required this.onAction,
    this.style = KeyStyle.normal,
    super.key,
  });

  final CalculatorFunction function;
  final Widget label;
  final String semanticLabel;
  final void Function(CalculatorAction action) onAction;
  final KeyStyle style;

  @override
  Widget build(BuildContext context) {
    final CalculatorMetrics metrics = CalculatorMetrics.of(context);
    return CalculatorKey(
      metrics: metrics,
      style: style,
      semanticLabel: semanticLabel,
      onPressed: () => onAction(CalculatorAction.function(function)),
      child: label,
    );
  }
}
