import 'package:meta/meta.dart';

import '../../core/utils/number_formatter.dart';
import '../parser/expression.dart';
import '../parser/tokenizer.dart';
import 'angle_mode.dart';
import 'calculator_error.dart';
import 'calculator_operation.dart';
import 'memory_state.dart';

/// The operand the user is currently building or has just produced.
///
/// Two kinds exist because the reference calculator treats them differently:
///
/// * [TypedOperand] - digits the user is still typing (`1.5`, `5.`).  The
///   result display shows the digits verbatim, including a trailing `.`.
/// * [ValueOperand] - a value produced by a function, a constant, memory
///   recall or a parenthesis group (`sin(25)`, `pi`, `(2+3)`).
sealed class OperandEntry {
  const OperandEntry();

  /// The operand as an expression node.
  Expression toExpression();

  /// Text shown in the result display while this operand is current.
  String resultText(AngleMode mode);

  /// Text contributed to the expression (key sequence) display.
  String expressionText(AngleMode mode);
}

/// Digits currently being typed.
final class TypedOperand extends OperandEntry {
  const TypedOperand({this.digits = '', this.negative = false});

  /// Raw digit buffer exactly as typed, e.g. `0`, `1.5`, `5.`.
  final String digits;

  /// Whether `+/-` has been applied.
  final bool negative;

  /// Typed text including the sign, e.g. `-1.5`.
  String get text => '${negative ? '-' : ''}${digits.isEmpty ? '0' : digits}';

  /// Numerical value of the buffer.
  double get value =>
      (NumberFormatter.tryParseInput(digits) ?? 0) * (negative ? -1 : 1);

  bool get isBlank => digits.isEmpty;

  TypedOperand appendDigit(int digit) => TypedOperand(
        digits: digits == '0' ? '$digit' : '$digits$digit',
        negative: negative,
      );

  TypedOperand appendDecimalPoint() => digits.contains('.')
      ? this
      : TypedOperand(
          digits: digits.isEmpty ? '0.' : '$digits.',
          negative: negative,
        );

  TypedOperand removeLastDigit() => TypedOperand(
        digits: digits.isEmpty ? '' : digits.substring(0, digits.length - 1),
        negative: negative,
      );

  TypedOperand toggleSign() => TypedOperand(digits: digits, negative: !negative);

  @override
  Expression toExpression() => NumberExpression(value, sourceText: text);

  @override
  String resultText(AngleMode mode) => text;

  @override
  String expressionText(AngleMode mode) => text;

  @override
  String toString() => 'TypedOperand($text)';
}

/// A closed value produced by a function, constant, memory or parentheses.
final class ValueOperand extends OperandEntry {
  const ValueOperand(this.expression);

  final Expression expression;

  @override
  Expression toExpression() => expression;

  @override
  String resultText(AngleMode mode) {
    // Rendering must never throw: an expression that cannot be evaluated is
    // displayed as the calculator's error token.
    try {
      return NumberFormatter.format(expression.evaluate(mode));
    } catch (_) {
      return NumberFormatter.errorText;
    }
  }

  @override
  String expressionText(AngleMode mode) => expression.displayText(mode);

  @override
  String toString() => 'ValueOperand($expression)';
}

/// An outer parenthesis frame that is still open.
@immutable
class ExpressionGroup {
  const ExpressionGroup({required this.terms, required this.operations});

  final List<Expression> terms;
  final List<CalculatorOperation> operations;
}

/// Immutable snapshot of the calculator.
///
/// The state keeps the *structure* of the calculation (operands, pending
/// operations, open parenthesis frames) separate from the two displays, so the
/// expression display is never derived from the result display.
@immutable
class CalculatorState {
  const CalculatorState({
    this.angleMode = AngleMode.degree,
    this.memory = MemoryState.empty,
    this.groups = const <ExpressionGroup>[],
    this.terms = const <Expression>[],
    this.operations = const <CalculatorOperation>[],
    this.entry,
    this.lastValue,
    this.completedExpression,
    this.justEvaluated = false,
    this.error,
    this.errorDetail,
  });

  /// Fresh calculator: degrees, empty memory, `0` on the result display.
  static const CalculatorState initial = CalculatorState();

  /// `Deg` / `Rad` radio button.
  final AngleMode angleMode;

  /// Memory register and status.
  final MemoryState memory;

  /// Still-open `(` frames, outermost first.
  final List<ExpressionGroup> groups;

  /// Completed operands of the innermost open frame.
  final List<Expression> terms;

  /// Binary operations connecting [terms].
  final List<CalculatorOperation> operations;

  /// Operand currently being entered, if any.
  final OperandEntry? entry;

  /// Value shown in the result display when no operand is being entered.
  final double? lastValue;

  /// Expression that was evaluated by the last `=`.
  final Expression? completedExpression;

  /// Whether the previous action was `=`.
  final bool justEvaluated;

  /// Explicit error state; never a thrown Dart exception.
  final CalculatorError? error;

  /// Optional detail for diagnostics/tooltips.
  final String? errorDetail;

  /// Whether an operator is waiting for its right hand operand.
  bool get hasPendingOperation =>
      operations.length >= terms.length && operations.isNotEmpty;

  /// Whether the calculator is in an error state.
  bool get isError => error != null;

  /// Short description of the error, used for accessibility and tooltips.
  String? get errorMessage => error?.description;

  /// Expression display line, e.g. `60+35*5` or `fact(8)*5-2`.
  ///
  /// Built from the expression structure (never from the result display).
  String get expressionText {
    final StringBuffer buffer = StringBuffer();
    for (final ExpressionGroup group in groups) {
      buffer
        ..write(_renderTerms(group.terms, group.operations, angleMode))
        ..write('(');
    }
    if (justEvaluated && completedExpression != null) {
      buffer.write(completedExpression!.displayText(angleMode));
      return buffer.toString();
    }
    buffer.write(_renderTerms(terms, operations, angleMode));
    if (entry != null) {
      buffer.write(entry!.expressionText(angleMode));
    }
    return buffer.toString();
  }

  /// Result display line, e.g. `235`, `0.4226182617406994`.
  String get resultText {
    if (error != null) {
      return NumberFormatter.errorText;
    }
    if (entry != null) {
      return entry!.resultText(angleMode);
    }
    return NumberFormatter.format(lastValue ?? 0);
  }

  CalculatorState copyWith({
    AngleMode? angleMode,
    MemoryState? memory,
    List<ExpressionGroup>? groups,
    List<Expression>? terms,
    List<CalculatorOperation>? operations,
    OperandEntry? entry,
    bool clearEntry = false,
    double? lastValue,
    bool clearLastValue = false,
    Expression? completedExpression,
    bool clearCompletedExpression = false,
    bool? justEvaluated,
    CalculatorError? error,
    String? errorDetail,
    bool clearError = false,
  }) {
    return CalculatorState(
      angleMode: angleMode ?? this.angleMode,
      memory: memory ?? this.memory,
      groups: groups ?? this.groups,
      terms: terms ?? this.terms,
      operations: operations ?? this.operations,
      entry: clearEntry ? null : (entry ?? this.entry),
      lastValue: clearLastValue ? null : (lastValue ?? this.lastValue),
      completedExpression: clearCompletedExpression
          ? null
          : (completedExpression ?? this.completedExpression),
      justEvaluated: justEvaluated ?? this.justEvaluated,
      error: clearError ? null : (error ?? this.error),
      errorDetail: clearError ? null : (errorDetail ?? this.errorDetail),
    );
  }

  static String _renderTerms(
    List<Expression> terms,
    List<CalculatorOperation> operations,
    AngleMode mode,
  ) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < terms.length; i++) {
      buffer.write(terms[i].displayText(mode));
      if (i < operations.length) {
        buffer.write(operations[i].symbol);
      }
    }
    return buffer.toString();
  }
}
