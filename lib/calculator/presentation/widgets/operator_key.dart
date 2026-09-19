import 'package:flutter/material.dart';

import '../../domain/calculator_action.dart';
import '../../domain/calculator_operation.dart';
import 'calculator_key.dart';
import '../theme/calculator_theme.dart';

/// A key that starts (or replaces) a pending binary operation.
class OperatorKey extends StatelessWidget {
  const OperatorKey({
    required this.operation,
    required this.semanticLabel,
    required this.onAction,
    this.label,
    super.key,
  });

  final CalculatorOperation operation;

  /// Optional custom widget (e.g. `x^y`); falls back to [operation]'s symbol.
  final Widget? label;

  final String semanticLabel;
  final void Function(CalculatorAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final CalculatorMetrics metrics = CalculatorMetrics.of(context);
    return CalculatorKey(
      metrics: metrics,
      semanticLabel: semanticLabel,
      onPressed: () => onAction(CalculatorAction.operator(operation)),
      child: label ?? Text(operation.symbol),
    );
  }
}