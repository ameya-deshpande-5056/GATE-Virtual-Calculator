import 'package:flutter/material.dart';

import '../../domain/calculator_action.dart';
import 'calculator_key.dart';
import '../theme/calculator_theme.dart';

/// One of the five memory keys of the reference calculator.
class MemoryKey extends StatelessWidget {
  const MemoryKey({
    required this.operation,
    required this.semanticLabel,
    required this.onAction,
    super.key,
  });

  final MemoryOperation operation;
  final String semanticLabel;
  final void Function(CalculatorAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final CalculatorMetrics metrics = CalculatorMetrics.of(context);
    return CalculatorKey(
      metrics: metrics,
      style: KeyStyle.numeric,
      semanticLabel: semanticLabel,
      onPressed: () => onAction(CalculatorAction.memory(operation)),
      child: Text(operation.label),
    );
  }
}
