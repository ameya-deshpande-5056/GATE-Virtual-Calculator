import 'package:meta/meta.dart';

import 'angle_mode.dart';
import 'calculator_constant.dart';
import 'calculator_function.dart';
import 'calculator_operation.dart';

/// Every button of the reference calculator dispatches exactly one of these.
///
/// The widgets never compute anything: they only build a [CalculatorAction] and
/// hand it to the `CalculatorCubit`.
@immutable
sealed class CalculatorAction {
  const CalculatorAction();

  /// `0` .. `9`.
  const factory CalculatorAction.number(int digit) = NumberAction;

  /// `.`
  const factory CalculatorAction.decimalPoint() = DecimalPointAction;

  /// `+`, `-`, `*`, `/`, `mod`, `Exp`, `x^y`, `y-root`, `log_y x`.
  const factory CalculatorAction.operator(CalculatorOperation operation) =
      OperatorAction;

  /// A unary function applied to the already entered operand (`25 -> sin`).
  const factory CalculatorAction.function(CalculatorFunction function) =
      FunctionAction;

  /// `pi` or `e`.
  const factory CalculatorAction.constant(CalculatorConstant constant) =
      ConstantAction;

  /// `(`
  const factory CalculatorAction.openParenthesis() = OpenParenthesisAction;

  /// `)`
  const factory CalculatorAction.closeParenthesis() = CloseParenthesisAction;

  /// `MC`, `MR`, `MS`, `M+`, `M-`.
  const factory CalculatorAction.memory(MemoryOperation operation) =
      MemoryAction;

  /// `Deg` / `Rad`.
  const factory CalculatorAction.angleMode(AngleMode mode) = AngleModeAction;

  /// `=`
  static const CalculatorAction equals = EqualsAction();

  /// `C`
  static const CalculatorAction clear = ClearAction();

  /// `<-`
  static const CalculatorAction backspace = BackspaceAction();

  /// `+/-`
  static const CalculatorAction signChange = SignChangeAction();

  /// Short human readable form, used by tests and the help sheet.
  String describe();
}

/// `0` .. `9`
final class NumberAction extends CalculatorAction {
  const NumberAction(this.digit);

  final int digit;

  @override
  String describe() => '$digit';
}

/// `.`
final class DecimalPointAction extends CalculatorAction {
  const DecimalPointAction();

  @override
  String describe() => '.';
}

/// A pending binary operation.
final class OperatorAction extends CalculatorAction {
  const OperatorAction(this.operation);

  final CalculatorOperation operation;

  @override
  String describe() => operation.symbol;
}

/// A unary function.
final class FunctionAction extends CalculatorAction {
  const FunctionAction(this.function);

  final CalculatorFunction function;

  @override
  String describe() => function.name;
}

/// `pi` or `e`.
final class ConstantAction extends CalculatorAction {
  const ConstantAction(this.constant);

  final CalculatorConstant constant;

  @override
  String describe() => constant.symbol;
}

/// `(`
final class OpenParenthesisAction extends CalculatorAction {
  const OpenParenthesisAction();

  @override
  String describe() => '(';
}

/// `)`
final class CloseParenthesisAction extends CalculatorAction {
  const CloseParenthesisAction();

  @override
  String describe() => ')';
}

/// `=`
final class EqualsAction extends CalculatorAction {
  const EqualsAction();

  @override
  String describe() => '=';
}

/// `C`
final class ClearAction extends CalculatorAction {
  const ClearAction();

  @override
  String describe() => 'C';
}

/// `<-`
final class BackspaceAction extends CalculatorAction {
  const BackspaceAction();

  @override
  String describe() => 'backspace';
}

/// `+/-`
final class SignChangeAction extends CalculatorAction {
  const SignChangeAction();

  @override
  String describe() => '+/-';
}

/// A memory key.
final class MemoryAction extends CalculatorAction {
  const MemoryAction(this.operation);

  final MemoryOperation operation;

  @override
  String describe() => operation.label;
}

/// `Deg` / `Rad`
final class AngleModeAction extends CalculatorAction {
  const AngleModeAction(this.mode);

  final AngleMode mode;

  @override
  String describe() => mode.label;
}

/// The five memory keys of the reference calculator.
enum MemoryOperation {
  clear('MC'),
  recall('MR'),
  store('MS'),
  add('M+'),
  subtract('M-');

  const MemoryOperation(this.label);

  final String label;
}
