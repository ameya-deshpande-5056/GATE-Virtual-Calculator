import '../domain/angle_mode.dart';
import '../domain/calculator_constant.dart';
import '../domain/calculator_function.dart';
import '../domain/calculator_operation.dart';

/// Immutable expression tree.
///
/// The calculator never evaluates a string.  Every button press either extends
/// this tree (operands, pending binary operations, function application) or
/// evaluates it.  This is what makes `25 -> sin` become `sin(25)` instead of
/// being a text substitution.
sealed class Expression {
  const Expression();

  /// Evaluates the tree.
  ///
  /// Throws a `CalculatorException` when the expression is mathematically
  /// invalid; the engine converts that into an explicit error state.
  double evaluate(AngleMode mode);

  /// Every operand of the tree, in display order.
  List<Expression> get operands => const <Expression>[];
}

/// A literal number.  [sourceText] preserves exactly what the user typed
/// (`5.` stays `5.` in the expression display).
final class NumberExpression extends Expression {
  const NumberExpression(this.value, {this.sourceText});

  final double value;
  final String? sourceText;

  @override
  double evaluate(AngleMode mode) => value;

  @override
  List<Expression> get operands => <Expression>[this];

  @override
  bool operator ==(Object other) =>
      other is NumberExpression && other.value == value && other.sourceText == sourceText;

  @override
  int get hashCode => Object.hash(value, sourceText);

  @override
  String toString() => 'NumberExpression($value)';
}

/// `pi` or `e`.
final class ConstantExpression extends Expression {
  const ConstantExpression(this.constant);

  final CalculatorConstant constant;

  @override
  double evaluate(AngleMode mode) => constant.value;

  @override
  List<Expression> get operands => <Expression>[this];

  @override
  String toString() => 'ConstantExpression(${constant.name})';
}

/// A unary function applied to an operand, e.g. `sin(25)`, `fact(8)`.
final class UnaryExpression extends Expression {
  const UnaryExpression(this.function, this.operand);

  final CalculatorFunction function;
  final Expression operand;

  @override
  double evaluate(AngleMode mode) => function.apply(operand.evaluate(mode), mode);

  @override
  List<Expression> get operands => operand.operands;

  @override
  String toString() => 'UnaryExpression(${function.name}, $operand)';
}

/// A pending binary operation, e.g. `60+35`, `8yroot4`, `20^2`.
final class BinaryExpression extends Expression {
  const BinaryExpression(this.operation, this.left, this.right);

  final CalculatorOperation operation;
  final Expression left;
  final Expression right;

  @override
  double evaluate(AngleMode mode) =>
      operation.apply(left.evaluate(mode), right.evaluate(mode));

  @override
  List<Expression> get operands => <Expression>[...left.operands, ...right.operands];

  @override
  String toString() => 'BinaryExpression(${operation.symbol}, $left, $right)';
}

/// An explicitly parenthesised sub-expression, e.g. `(2+3)`.
final class ParenthesizedExpression extends Expression {
  const ParenthesizedExpression(this.inner);

  final Expression inner;

  @override
  double evaluate(AngleMode mode) => inner.evaluate(mode);

  @override
  List<Expression> get operands => inner.operands;

  @override
  String toString() => 'ParenthesizedExpression($inner)';
}

/// Unary negation produced by the `+/-` key on a computed value.
final class NegatedExpression extends Expression {
  const NegatedExpression(this.operand);

  final Expression operand;

  @override
  double evaluate(AngleMode mode) => -operand.evaluate(mode);

  @override
  List<Expression> get operands => operand.operands;

  @override
  String toString() => 'NegatedExpression($operand)';
}
