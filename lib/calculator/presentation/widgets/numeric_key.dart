import 'package:flutter/material.dart';

import '../../domain/calculator_action.dart';
import 'calculator_key.dart';
import '../theme/calculator_theme.dart';

/// A digit key (`0` .. `9`).
class NumericKey extends StatelessWidget {
  const NumericKey({required this.digit, required this.onAction, super.key})
      : assert(digit >= 0 && digit <= 9);

  final int digit;
  final void Function(CalculatorAction action) onAction;

  static const List<String> _names = <String>[
    'zero', 'one', 'two', 'three', 'four',
    'five', 'six', 'seven', 'eight', 'nine',
  ];

  @override
  Widget build(BuildContext context) {
    final CalculatorMetrics metrics = CalculatorMetrics.of(context);
    return CalculatorKey(
      metrics: metrics,
      style: KeyStyle.numeric,
      semanticLabel: '${_names[digit]} key',
      onPressed: () => onAction(CalculatorAction.number(digit)),
      child: Text('$digit'),
    );
  }
}
