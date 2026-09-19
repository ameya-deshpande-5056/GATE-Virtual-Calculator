import '../../core/errors/calculator_exception.dart';
import '../parser/expression.dart';
import '../parser/parser.dart';
import 'angle_mode.dart';
import 'calculator_action.dart';
import 'calculator_constant.dart';
import 'calculator_error.dart';
import 'calculator_function.dart';
import 'calculator_operation.dart';
import 'calculator_state.dart';

/// The pure Dart calculation engine.
///
/// Every button dispatches a [CalculatorAction]; the engine answers with a new
/// immutable [CalculatorState].  There is no `eval`, no generated code and no
/// string substitution: the engine maintains an expression *tree*.
///
/// The engine has no Flutter dependency and can be exercised in plain unit
/// tests.
class CalculatorEngine {
  const CalculatorEngine({this.parser = const ExpressionParser()});

  /// Precedence parser used to fold the flat operand/operator sequence.
  final ExpressionParser parser;

  /// Longest digit buffer accepted (guards against unbounded input).
  static const int maxInputLength = 20;

  /// Processes one action and returns the next state.
  CalculatorState process(CalculatorAction action, CalculatorState state) {
    try {
      return _dispatch(action, state);
    } on CalculatorException catch (failure) {
      return state.copyWith(error: failure.error, errorDetail: failure.detail);
    } catch (unexpected) {
      // Defensive: a malformed interaction may never crash the application.
      return state.copyWith(
        error: CalculatorError.undefinedResult,
        errorDetail: unexpected.toString(),
      );
    }
  }

  CalculatorState _dispatch(CalculatorAction action, CalculatorState state) {
    if (state.isError) {
      return _recover(action, state);
    }
    switch (action) {
      case NumberAction():
        return _inputDigit(state, action.digit);
      case DecimalPointAction():
        return _inputDecimalPoint(state);
      case OperatorAction():
        return _applyOperator(state, action.operation);
      case FunctionAction():
        return _applyFunction(state, action.function);
      case ConstantAction():
        return _inputConstant(state, action.constant);
      case OpenParenthesisAction():
        return _openParenthesis(state);
      case CloseParenthesisAction():
        return _closeParenthesis(state);
      case EqualsAction():
        return _evaluate(state);
      case ClearAction():
        return _clear(state);
      case BackspaceAction():
        return _backspace(state);
      case SignChangeAction():
        return _signChange(state);
      case MemoryAction():
        return _memoryAction(state, action.operation);
      case AngleModeAction():
        return _changeAngleMode(state, action.mode);
    }
  }

  // --- number entry ---------------------------------------------------------

  CalculatorState _inputDigit(CalculatorState state, int digit) {
    if (state.justEvaluated) {
      return _fresh(state, TypedOperand(digits: '$digit'));
    }
    final OperandEntry? entry = state.entry;
    if (entry is TypedOperand) {
      if (entry.digits.length >= maxInputLength) {
        return state;
      }
      return state.copyWith(entry: entry.appendDigit(digit));
    }
    if (entry == null) {
      return state.copyWith(entry: TypedOperand(digits: '$digit'));
    }
    // A closed value (function result, constant, parentheses) is not extended
    // by further digits; the key is ignored instead of silently dropping it.
    return state;
  }

  CalculatorState _inputDecimalPoint(CalculatorState state) {
    if (state.justEvaluated) {
      return _fresh(state, const TypedOperand(digits: '0.'));
    }
    final OperandEntry? entry = state.entry;
    if (entry is TypedOperand) {
      return state.copyWith(entry: entry.appendDecimalPoint());
    }
    if (entry == null) {
      return state.copyWith(entry: const TypedOperand(digits: '0.'));
    }
    return state;
  }

  CalculatorState _inputConstant(
    CalculatorState state,
    CalculatorConstant constant,
  ) {
    if (state.entry != null && !state.justEvaluated) {
      // No implicit multiplication and no operand replacement: `5 pi` is not a
      // supported input, exactly like `5 (`.
      return state;
    }
    final Expression expression = ConstantExpression(constant);
    if (state.justEvaluated) {
      return _fresh(state, ValueOperand(expression));
    }
    return state.copyWith(
      entry: ValueOperand(expression),
      lastValue: _tryEvaluate(expression, state.angleMode),
    );
  }

  // --- binary operations ----------------------------------------------------

  CalculatorState _applyOperator(
    CalculatorState state,
    CalculatorOperation operation,
  ) {
    if (state.justEvaluated) {
      // Continue the calculation from the previous result.
      return state.copyWith(
        terms: <Expression>[NumberExpression(state.lastValue ?? 0)],
        operations: <CalculatorOperation>[operation],
        justEvaluated: false,
        clearCompletedExpression: true,
        clearEntry: true,
      );
    }

    final OperandEntry? entry = state.entry;
    if (entry == null) {
      if (state.hasPendingOperation) {
        // Pressing a second operator replaces the pending one.
        final List<CalculatorOperation> operations =
            List<CalculatorOperation>.of(state.operations);
        operations[operations.length - 1] = operation;
        return state.copyWith(operations: operations);
      }
      // Nothing to operate on yet.
      return state;
    }

    final Expression operand = entry.toExpression();
    final double value = operand.evaluate(state.angleMode);
    return state.copyWith(
      terms: <Expression>[...state.terms, operand],
      operations: <CalculatorOperation>[...state.operations, operation],
      clearEntry: true,
      lastValue: value,
    );
  }

  // --- unary functions ------------------------------------------------------

  CalculatorState _applyFunction(
    CalculatorState state,
    CalculatorFunction function,
  ) {
    final OperandEntry? entry = state.entry;
    final Expression operand;
    if (entry != null) {
      operand = entry.toExpression();
    } else if (state.justEvaluated) {
      operand = NumberExpression(state.lastValue ?? 0);
    } else {
      // A function needs an operand; without one the key is ignored.
      return state;
    }

    final Expression applied = UnaryExpression(function, operand);
    try {
      return state.copyWith(
        entry: ValueOperand(applied),
        justEvaluated: false,
        clearCompletedExpression: true,
        lastValue: applied.evaluate(state.angleMode),
      );
    } on CalculatorException catch (failure) {
      return state.copyWith(
        entry: ValueOperand(applied),
        justEvaluated: false,
        clearCompletedExpression: true,
        error: failure.error,
        errorDetail: failure.detail,
      );
    }
  }

  // --- parentheses ----------------------------------------------------------

  CalculatorState _openParenthesis(CalculatorState state) {
    if (state.justEvaluated) {
      return _fresh(state, null).copyWith(
        groups: <ExpressionGroup>[
          const ExpressionGroup(
            terms: <Expression>[],
            operations: <CalculatorOperation>[],
          ),
        ],
      );
    }
    if (state.entry != null) {
      // No implicit multiplication: `2 ( 3 + 4 )` is not supported by the
      // reference calculator.
      return state;
    }
    return state.copyWith(
      groups: <ExpressionGroup>[
        ...state.groups,
        ExpressionGroup(terms: state.terms, operations: state.operations),
      ],
      terms: const <Expression>[],
      operations: const <CalculatorOperation>[],
      clearEntry: true,
    );
  }

  CalculatorState _closeParenthesis(CalculatorState state) {
    final OperandEntry? entry = state.entry;
    if (state.groups.isEmpty || entry == null) {
      return state;
    }

    final Expression inner = parser.parse(
      <Expression>[...state.terms, entry.toExpression()],
      state.operations,
    );
    final Expression grouped = ParenthesizedExpression(inner);
    final ExpressionGroup parent = state.groups.last;

    final CalculatorState closed = state.copyWith(
      groups: state.groups.sublist(0, state.groups.length - 1),
      terms: parent.terms,
      operations: parent.operations,
      entry: ValueOperand(grouped),
      justEvaluated: false,
      clearCompletedExpression: true,
    );

    try {
      return closed.copyWith(lastValue: grouped.evaluate(state.angleMode));
    } on CalculatorException catch (failure) {
      return closed.copyWith(error: failure.error, errorDetail: failure.detail);
    }
  }

  // --- editing --------------------------------------------------------------

  CalculatorState _backspace(CalculatorState state) {
    final OperandEntry? entry = state.entry;

    if (entry is TypedOperand) {
      final TypedOperand trimmed = entry.removeLastDigit();
      if (!trimmed.isBlank) {
        return state.copyWith(entry: trimmed);
      }
      // The whole operand disappeared.
      return state.copyWith(
        clearEntry: true,
        lastValue: _lastTermValue(state),
        clearLastValue: state.terms.isEmpty,
      );
    }

    if (entry is ValueOperand) {
      final Expression expression = entry.expression;
      if (expression is UnaryExpression) {
        // Undo the outermost function application.
        return state.copyWith(
          entry: ValueOperand(expression.operand),
          lastValue: _tryEvaluate(expression.operand, state.angleMode),
        );
      }
      return state;
    }

    if (state.hasPendingOperation) {
      final List<CalculatorOperation> operations =
          List<CalculatorOperation>.of(state.operations)..removeLast();
      return state.copyWith(operations: operations);
    }

    return state;
  }

  CalculatorState _signChange(CalculatorState state) {
    final OperandEntry? entry = state.entry;

    if (entry is TypedOperand) {
      final TypedOperand toggled = entry.toggleSign();
      return state.copyWith(entry: toggled, lastValue: toggled.value);
    }

    if (entry is ValueOperand) {
      final Expression negated = NegatedExpression(entry.expression);
      return state.copyWith(
        entry: ValueOperand(negated),
        lastValue: _tryEvaluate(negated, state.angleMode),
      );
    }

    if (state.justEvaluated) {
      final Expression negated =
          NegatedExpression(NumberExpression(state.lastValue ?? 0));
      return state.copyWith(
        entry: ValueOperand(negated),
        justEvaluated: false,
        clearCompletedExpression: true,
        lastValue: _tryEvaluate(negated, state.angleMode),
      );
    }

    return state;
  }

  CalculatorState _clear(CalculatorState state) => CalculatorState(
        angleMode: state.angleMode,
        memory: state.memory,
      );

  // --- memory ---------------------------------------------------------------

  CalculatorState _memoryAction(
    CalculatorState state,
    MemoryOperation operation,
  ) {
    switch (operation) {
      case MemoryOperation.clear:
        return state.copyWith(memory: state.memory.clear());
      case MemoryOperation.recall:
        if (!state.memory.hasValue) {
          return state;
        }
        final Expression recalled = NumberExpression(state.memory.value);
        return state.copyWith(
          entry: ValueOperand(recalled),
          justEvaluated: false,
          clearCompletedExpression: true,
          lastValue: state.memory.value,
        );
      case MemoryOperation.store:
        return state.copyWith(memory: state.memory.store(_currentValue(state)));
      case MemoryOperation.add:
        return state.copyWith(memory: state.memory.add(_currentValue(state)));
      case MemoryOperation.subtract:
        return state.copyWith(
          memory: state.memory.subtract(_currentValue(state)),
        );
    }
  }

  // --- angle mode -----------------------------------------------------------

  CalculatorState _changeAngleMode(CalculatorState state, AngleMode mode) {
    if (state.angleMode == mode) {
      return state;
    }
    final CalculatorState next = state.copyWith(angleMode: mode);

    // The mode is a global setting, so anything already displayed is
    // re-evaluated to keep both displays consistent.
    final OperandEntry? entry = next.entry;
    if (entry is ValueOperand) {
      final double? value = _tryEvaluate(entry.expression, mode);
      return value == null
          ? next.copyWith(error: CalculatorError.undefinedResult)
          : next.copyWith(lastValue: value);
    }
    if (next.justEvaluated && next.completedExpression != null) {
      final double? value = _tryEvaluate(next.completedExpression!, mode);
      return value == null
          ? next.copyWith(error: CalculatorError.undefinedResult)
          : next.copyWith(lastValue: value);
    }
    return next;
  }

  // --- evaluation -----------------------------------------------------------

  CalculatorState _evaluate(CalculatorState state) {
    final OperandEntry? entry = state.entry;
    if (entry == null && state.terms.isEmpty) {
      // Nothing (new) to evaluate.
      return state;
    }

    final List<Expression> operands = <Expression>[...state.terms];
    final List<CalculatorOperation> operations =
        List<CalculatorOperation>.of(state.operations);

    if (entry != null) {
      operands.add(entry.toExpression());
    } else if (operations.length >= operands.length) {
      // Trailing operator without a right hand operand, e.g. `5 + =`.
      operations.removeLast();
    }

    final Expression tree;
    try {
      tree = parser.parse(operands, operations);
    } on CalculatorException catch (failure) {
      return state.copyWith(error: failure.error, errorDetail: failure.detail);
    }

    try {
      final double result = tree.evaluate(state.angleMode);
      return CalculatorState(
        angleMode: state.angleMode,
        memory: state.memory,
        completedExpression: tree,
        justEvaluated: true,
        lastValue: result,
      );
    } on CalculatorException catch (failure) {
      return CalculatorState(
        angleMode: state.angleMode,
        memory: state.memory,
        entry: ValueOperand(tree),
        error: failure.error,
        errorDetail: failure.detail,
      );
    }
  }

  // --- error recovery -------------------------------------------------------

  /// Only `C`, `<-`, a fresh operand or a mode change leave the error state.
  CalculatorState _recover(CalculatorAction action, CalculatorState state) {
    switch (action) {
      case ClearAction():
      case BackspaceAction():
        return _clear(state);
      case NumberAction():
        return _fresh(state, TypedOperand(digits: '${action.digit}'));
      case DecimalPointAction():
        return _fresh(state, const TypedOperand(digits: '0.'));
      case ConstantAction():
        return _fresh(state, ValueOperand(ConstantExpression(action.constant)));
      case AngleModeAction():
        return state.copyWith(angleMode: action.mode, clearError: true);
      case MemoryAction():
        return action.operation == MemoryOperation.clear
            ? state.copyWith(memory: state.memory.clear(), clearError: true)
            : state;
      case OperatorAction():
      case FunctionAction():
      case OpenParenthesisAction():
      case CloseParenthesisAction():
      case EqualsAction():
      case SignChangeAction():
        return state;
    }
  }

  // --- helpers --------------------------------------------------------------

  /// A brand new calculation that keeps the configuration (mode/memory).
  CalculatorState _fresh(CalculatorState state, OperandEntry? entry) =>
      CalculatorState(
        angleMode: state.angleMode,
        memory: state.memory,
        entry: entry,
      );

  /// Value currently on the result display.
  double _currentValue(CalculatorState state) {
    final OperandEntry? entry = state.entry;
    if (entry != null) {
      return _tryEvaluate(entry.toExpression(), state.angleMode) ??
          state.lastValue ??
          0;
    }
    return state.lastValue ?? 0;
  }

  double? _lastTermValue(CalculatorState state) {
    if (state.terms.isEmpty) {
      return null;
    }
    return _tryEvaluate(state.terms.last, state.angleMode);
  }

  double? _tryEvaluate(Expression expression, AngleMode mode) {
    try {
      return expression.evaluate(mode);
    } on CalculatorException {
      return null;
    }
  }
}