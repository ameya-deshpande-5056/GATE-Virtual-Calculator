import 'package:flutter/material.dart';

import '../../domain/angle_mode.dart';
import '../../domain/calculator_action.dart';
import '../../domain/calculator_constant.dart';
import '../../domain/calculator_function.dart';
import '../../domain/calculator_operation.dart';
import '../theme/calculator_theme.dart';
import 'calculator_key.dart';
import 'function_key.dart';
import 'memory_key.dart';
import 'numeric_key.dart';
import 'operator_key.dart';

/// The 11 column keypad of the reference calculator.
///
/// The grid reproduces the reference layout exactly (see
/// `reference/KEYPAD_LAYOUT.md`):
///
/// * a mode/memory row with `mod`, the `Deg`/`Rad` radios and `MC`-`M-`,
/// * five key rows where `<-` spans two columns, `=` spans two rows and `0`
///   spans two columns.
///
/// Every key dispatches a [CalculatorAction]; no calculation happens here.
class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({required this.width, required this.onAction, super.key});

  /// Width available to the keypad; the grid scales proportionally with it.
  final double width;

  final void Function(CalculatorAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final CalculatorMetrics metrics = CalculatorMetrics.fromWidth(width);
    return CalculatorMetricsScope(
      metrics: metrics,
      child: SizedBox(
        width: width,
        height: _totalHeight(metrics),
        child: Stack(
          children: <Widget>[
            for (final _Cell cell in _cells)
              Positioned(
                left: _left(cell, metrics),
                top: _top(cell, metrics),
                width: _width(cell, metrics),
                height: _heightOf(cell, metrics),
                child: cell.builder(context, onAction, metrics),
              ),
          ],
        ),
      ),
    );
  }

  double _totalHeight(CalculatorMetrics metrics) =>
      metrics.modeRowHeight + 5 * (metrics.rowHeight + metrics.gap);

  double _left(_Cell cell, CalculatorMetrics metrics) =>
      metrics.gap / 2 + cell.column * metrics.pitch;

  double _width(_Cell cell, CalculatorMetrics metrics) =>
      cell.columnSpan * metrics.pitch - metrics.gap;

  double _top(_Cell cell, CalculatorMetrics metrics) => cell.row == 0
      ? 0
      : metrics.modeRowHeight +
          (cell.row - 1) * (metrics.rowHeight + metrics.gap);

  double _heightOf(_Cell cell, CalculatorMetrics metrics) => cell.row == 0
      ? metrics.modeRowHeight
      : cell.rowSpan * metrics.rowHeight + (cell.rowSpan - 1) * metrics.gap;
}

typedef _KeyBuilder = Widget Function(
  BuildContext context,
  void Function(CalculatorAction action) dispatch,
  CalculatorMetrics metrics,
);

class _Cell {
  const _Cell({
    required this.column,
    required this.row,
    required this.builder,
    this.columnSpan = 1,
    this.rowSpan = 1,
  });

  final int column;
  final int row;
  final int columnSpan;
  final int rowSpan;
  final _KeyBuilder builder;
}

/// Generic key for the actions that have no dedicated widget (`C`, `<-`,
/// `+/-`, `=`, `.`, `mod`, `Exp`, parentheses).
_KeyBuilder _actionKey({
  required Widget label,
  required String semanticLabel,
  required CalculatorAction action,
  KeyStyle style = KeyStyle.normal,
}) =>
    (
      BuildContext context,
      void Function(CalculatorAction action) dispatch,
      CalculatorMetrics metrics,
    ) {
      return CalculatorKey(
        metrics: metrics,
        style: style,
        semanticLabel: semanticLabel,
        onPressed: () => dispatch(action),
        child: label,
      );
    };

_KeyBuilder _functionKey(
  CalculatorFunction function,
  Widget label,
  String semanticLabel,
) =>
    (
      BuildContext context,
      void Function(CalculatorAction action) dispatch,
      CalculatorMetrics metrics,
    ) {
      return FunctionKey(
        function: function,
        label: label,
        semanticLabel: semanticLabel,
        onAction: dispatch,
      );
    };

_KeyBuilder _operatorKey(
  CalculatorOperation operation,
  String semanticLabel, [
  Widget? label,
]) =>
    (
      BuildContext context,
      void Function(CalculatorAction action) dispatch,
      CalculatorMetrics metrics,
    ) {
      return OperatorKey(
        operation: operation,
        label: label,
        semanticLabel: semanticLabel,
        onAction: dispatch,
      );
    };

_KeyBuilder _memoryKey(MemoryOperation operation, String semanticLabel) =>
    (
      BuildContext context,
      void Function(CalculatorAction action) dispatch,
      CalculatorMetrics metrics,
    ) {
      return MemoryKey(
        operation: operation,
        semanticLabel: semanticLabel,
        onAction: dispatch,
      );
    };

_KeyBuilder _numericKey(int digit) =>
    (
      BuildContext context,
      void Function(CalculatorAction action) dispatch,
      CalculatorMetrics metrics,
    ) {
      return NumericKey(digit: digit, onAction: dispatch);
    };

/// The angle mode radio buttons (`Deg` / `Rad`).
_KeyBuilder _angleModeSelector(AngleMode mode) =>
    (
      BuildContext context,
      void Function(CalculatorAction action) dispatch,
      CalculatorMetrics metrics,
    ) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final AngleMode candidate in AngleMode.values) ...<Widget>[
            if (candidate != AngleMode.values.first)
              SizedBox(width: metrics.keyFontSize * 1.4),
            _ModeRadio(
              mode: candidate,
              selected: candidate == mode,
              metrics: metrics,
              onSelected: () => dispatch(CalculatorAction.angleMode(candidate)),
            ),
          ],
        ],
      );
    };

class _ModeRadio extends StatelessWidget {
  const _ModeRadio({
    required this.mode,
    required this.selected,
    required this.metrics,
    required this.onSelected,
  });

  final AngleMode mode;
  final bool selected;
  final CalculatorMetrics metrics;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final double size = metrics.keyFontSize * 1.05;
    return Semantics(
      button: true,
      checked: selected,
      label: '${mode == AngleMode.degree ? 'degree' : 'radian'} mode',
      child: InkWell(
        onTap: onSelected,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: selected
                        ? CalculatorColors.radioSelected
                        : CalculatorColors.radioIdle,
                    width: 2,
                  ),
                ),
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: CalculatorColors.radioSelected,
                          ),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: metrics.keyFontSize * 0.35),
              Text(
                mode.label,
                style: TextStyle(
                  fontSize: metrics.keyFontSize,
                  color: CalculatorColors.keyText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid layout of the reference calculator (0-based column/row).
///
/// Row 0 is the mode/memory row; rows 1-5 are the function and numeric keys.
final List<_Cell> _cells = <_Cell>[
  // Row 0: mod | Deg/Rad radios | MC MR MS M+ M-
  _Cell(
    column: 0,
    row: 0,
    builder: _operatorKey(
      CalculatorOperation.modulo,
      'modulo',
      const Text('mod'),
    ),
  ),
  _Cell(
    column: 1,
    row: 0,
    columnSpan: 5,
    builder: _angleModeSelector(AngleMode.degree),
  ),
  _Cell(column: 6, row: 0, builder: _memoryKey(MemoryOperation.clear, 'memory clear')),
  _Cell(column: 7, row: 0, builder: _memoryKey(MemoryOperation.recall, 'memory recall')),
  _Cell(column: 8, row: 0, builder: _memoryKey(MemoryOperation.store, 'memory store')),
  _Cell(column: 9, row: 0, builder: _memoryKey(MemoryOperation.add, 'memory add')),
  _Cell(column: 10, row: 0, builder: _memoryKey(MemoryOperation.subtract, 'memory subtract')),

  // Row 1: sinh cosh tanh Exp ( ) | <- (spans 2) C +/- sqrt
  _Cell(column: 0, row: 1, builder: _functionKey(CalculatorFunction.sinh, const Text('sinh'), 'hyperbolic sine')),
  _Cell(column: 1, row: 1, builder: _functionKey(CalculatorFunction.cosh, const Text('cosh'), 'hyperbolic cosine')),
  _Cell(column: 2, row: 1, builder: _functionKey(CalculatorFunction.tanh, const Text('tanh'), 'hyperbolic tangent')),
  _Cell(
    column: 3,
    row: 1,
    builder: _actionKey(
      label: const Text('Exp'),
      semanticLabel: 'scientific notation exponent',
      action: CalculatorAction.operator(CalculatorOperation.exponentEntry),
    ),
  ),
  _Cell(
    column: 4,
    row: 1,
    builder: _actionKey(
      label: const Text('('),
      semanticLabel: 'open parenthesis',
      action: const CalculatorAction.openParenthesis(),
    ),
  ),
  _Cell(
    column: 5,
    row: 1,
    builder: _actionKey(
      label: const Text(')'),
      semanticLabel: 'close parenthesis',
      action: const CalculatorAction.closeParenthesis(),
    ),
  ),
  _Cell(
    column: 6,
    row: 1,
    columnSpan: 2,
    builder: _actionKey(
      label: const Icon(Icons.west),
      semanticLabel: 'backspace',
      action: CalculatorAction.backspace,
      style: KeyStyle.danger,
    ),
  ),
  _Cell(
    column: 8,
    row: 1,
    builder: _actionKey(
      label: const Text('C'),
      semanticLabel: 'clear',
      action: CalculatorAction.clear,
      style: KeyStyle.danger,
    ),
  ),
  _Cell(
    column: 9,
    row: 1,
    builder: _actionKey(
      label: const Text('+/-'),
      semanticLabel: 'sign change',
      action: CalculatorAction.signChange,
      style: KeyStyle.danger,
    ),
  ),
  _Cell(
    column: 10,
    row: 1,
    builder: _functionKey(
      CalculatorFunction.squareRoot,
      KeyLabels.radical(radicand: 'x'),
      'square root',
    ),
  ),

  // Row 2: sinh^-1 cosh^-1 tanh^-1 log2x ln log | 7 8 9 / %
  _Cell(column: 0, row: 2, builder: _functionKey(CalculatorFunction.asinh, KeyLabels.superscript('sinh', '-1'), 'inverse hyperbolic sine')),
  _Cell(column: 1, row: 2, builder: _functionKey(CalculatorFunction.acosh, KeyLabels.superscript('cosh', '-1'), 'inverse hyperbolic cosine')),
  _Cell(column: 2, row: 2, builder: _functionKey(CalculatorFunction.atanh, KeyLabels.superscript('tanh', '-1'), 'inverse hyperbolic tangent')),
  _Cell(column: 3, row: 2, builder: _functionKey(CalculatorFunction.log2, KeyLabels.subscript('log', '2', 'x'), 'base two logarithm')),
  _Cell(column: 4, row: 2, builder: _functionKey(CalculatorFunction.ln, const Text('ln'), 'natural logarithm')),
  _Cell(column: 5, row: 2, builder: _functionKey(CalculatorFunction.log, const Text('log'), 'common logarithm')),
  _Cell(column: 6, row: 2, builder: _numericKey(7)),
  _Cell(column: 7, row: 2, builder: _numericKey(8)),
  _Cell(column: 8, row: 2, builder: _numericKey(9)),
  _Cell(column: 9, row: 2, builder: _operatorKey(CalculatorOperation.divide, 'divide')),
  _Cell(column: 10, row: 2, builder: _functionKey(CalculatorFunction.percent, const Text('%'), 'percent')),

  // Row 3: pi e n! log_y x e^x 10^x | 4 5 6 * 1/x
  _Cell(column: 0, row: 3, builder: _constantKey(CalculatorConstant.pi, const Text('\u03C0'), 'pi constant')),
  _Cell(column: 1, row: 3, builder: _constantKey(CalculatorConstant.e, const Text('e'), 'euler number constant')),
  _Cell(column: 2, row: 3, builder: _functionKey(CalculatorFunction.factorial, const Text('n!'), 'factorial')),
  _Cell(column: 3, row: 3, builder: _operatorKey(CalculatorOperation.logBase, 'logarithm with base y', KeyLabels.subscript('log', 'y', ' x'))),
  _Cell(column: 4, row: 3, builder: _functionKey(CalculatorFunction.exponential, KeyLabels.superscript('e', 'x'), 'exponential function')),
  _Cell(column: 5, row: 3, builder: _functionKey(CalculatorFunction.tenPow, KeyLabels.superscript('10', 'x'), 'power of ten')),
  _Cell(column: 6, row: 3, builder: _numericKey(4)),
  _Cell(column: 7, row: 3, builder: _numericKey(5)),
  _Cell(column: 8, row: 3, builder: _numericKey(6)),
  _Cell(column: 9, row: 3, builder: _operatorKey(CalculatorOperation.multiply, 'multiply')),
  _Cell(column: 10, row: 3, builder: _functionKey(CalculatorFunction.reciprocal, const Text('1/x'), 'reciprocal')),

  // Row 4: sin cos tan x^y x^3 x^2 | 1 2 3 -   ( = spans rows 4-5 )
  _Cell(column: 0, row: 4, builder: _functionKey(CalculatorFunction.sin, const Text('sin'), 'sine')),
  _Cell(column: 1, row: 4, builder: _functionKey(CalculatorFunction.cos, const Text('cos'), 'cosine')),
  _Cell(column: 2, row: 4, builder: _functionKey(CalculatorFunction.tan, const Text('tan'), 'tangent')),
  _Cell(column: 3, row: 4, builder: _operatorKey(CalculatorOperation.power, 'power x to the y', KeyLabels.superscript('x', 'y'))),
  _Cell(column: 4, row: 4, builder: _functionKey(CalculatorFunction.cube, KeyLabels.superscript('x', '3'), 'cube')),
  _Cell(column: 5, row: 4, builder: _functionKey(CalculatorFunction.square, KeyLabels.superscript('x', '2'), 'square')),
  _Cell(column: 6, row: 4, builder: _numericKey(1)),
  _Cell(column: 7, row: 4, builder: _numericKey(2)),
  _Cell(column: 8, row: 4, builder: _numericKey(3)),
  _Cell(column: 9, row: 4, builder: _operatorKey(CalculatorOperation.subtract, 'minus')),
  _Cell(
    column: 10,
    row: 4,
    rowSpan: 2,
    builder: _actionKey(
      label: const Text('='),
      semanticLabel: 'equals',
      action: CalculatorAction.equals,
      style: KeyStyle.primary,
    ),
  ),

  // Row 5: sin^-1 cos^-1 tan^-1 y-root cube-root |x| | 0 (spans 2) . +
  _Cell(column: 0, row: 5, builder: _functionKey(CalculatorFunction.asin, KeyLabels.superscript('sin', '-1'), 'inverse sine')),
  _Cell(column: 1, row: 5, builder: _functionKey(CalculatorFunction.acos, KeyLabels.superscript('cos', '-1'), 'inverse cosine')),
  _Cell(column: 2, row: 5, builder: _functionKey(CalculatorFunction.atan, KeyLabels.superscript('tan', '-1'), 'inverse tangent')),
  _Cell(
    column: 3,
    row: 5,
    builder: _operatorKey(
      CalculatorOperation.yRoot,
      'y-th root of x',
      KeyLabels.radical(index: 'y', radicand: 'x'),
    ),
  ),
  _Cell(
    column: 4,
    row: 5,
    builder: _functionKey(
      CalculatorFunction.cubeRoot,
      KeyLabels.radical(index: '3'),
      'cube root',
    ),
  ),
  _Cell(
    column: 5,
    row: 5,
    builder: _functionKey(CalculatorFunction.absolute, const Text('|x|'), 'absolute value'),
  ),
  _Cell(column: 6, row: 5, columnSpan: 2, builder: _numericKey(0)),
  _Cell(
    column: 8,
    row: 5,
    builder: _actionKey(
      label: const Text('.'),
      semanticLabel: 'decimal point',
      action: const CalculatorAction.decimalPoint(),
    ),
  ),
  _Cell(column: 9, row: 5, builder: _operatorKey(CalculatorOperation.add, 'plus')),
];

_KeyBuilder _constantKey(
  CalculatorConstant constant,
  Widget label,
  String semanticLabel,
) =>
    (
      BuildContext context,
      void Function(CalculatorAction action) dispatch,
      CalculatorMetrics metrics,
    ) {
      return CalculatorKey(
        metrics: metrics,
        semanticLabel: semanticLabel,
        onPressed: () => dispatch(CalculatorAction.constant(constant)),
        child: label,
      );
    };