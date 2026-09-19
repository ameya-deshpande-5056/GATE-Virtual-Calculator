import '../../core/errors/calculator_exception.dart';
import '../domain/calculator_error.dart';
import '../domain/calculator_operation.dart';
import 'expression.dart';

/// Builds an [Expression] tree from the calculator's flat operand/operator
/// sequence, honouring operator precedence and left associativity.
///
/// The engine collects keys as:
///
/// ```text
/// operands   : [60, 35, 5]
/// operations : [+ , * ]
/// ```
///
/// and the parser turns that into `60 + (35 * 5)`, matching the reference
/// example `60 + 35 x 5` (the GATE calculator uses standard precedence, not
/// left-to-right evaluation).
class ExpressionParser {
  const ExpressionParser();

  Expression parse(
    List<Expression> operands,
    List<CalculatorOperation> operations,
  ) {
    if (operands.isEmpty) {
      throw const CalculatorException(CalculatorError.malformedExpression);
    }

    final List<Expression> operandStack = <Expression>[operands.first];
    final List<CalculatorOperation> operatorStack = <CalculatorOperation>[];

    for (int i = 0; i < operations.length && i + 1 < operands.length; i++) {
      final CalculatorOperation operation = operations[i];
      while (operatorStack.isNotEmpty &&
          operatorStack.last.precedence >= operation.precedence) {
        _reduce(operandStack, operatorStack);
      }
      operatorStack.add(operation);
      operandStack.add(operands[i + 1]);
    }

    while (operatorStack.isNotEmpty) {
      _reduce(operandStack, operatorStack);
    }

    if (operandStack.length != 1) {
      throw const CalculatorException(
        CalculatorError.malformedExpression,
        'unbalanced operands and operators',
      );
    }
    return operandStack.single;
  }

  void _reduce(
    List<Expression> operandStack,
    List<CalculatorOperation> operatorStack,
  ) {
    if (operandStack.length < 2 || operatorStack.isEmpty) {
      throw const CalculatorException(
        CalculatorError.malformedExpression,
        'operator without an operand',
      );
    }
    final Expression right = operandStack.removeLast();
    final Expression left = operandStack.removeLast();
    final CalculatorOperation operation = operatorStack.removeLast();
    operandStack.add(BinaryExpression(operation, left, right));
  }
}
