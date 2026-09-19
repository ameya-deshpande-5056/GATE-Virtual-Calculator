import 'package:flutter_test/flutter_test.dart';
import 'package:gate_calculator/calculator/domain/calculator_action.dart';
import 'package:gate_calculator/calculator/domain/calculator_constant.dart';
import 'package:gate_calculator/calculator/domain/calculator_error.dart';
import 'package:gate_calculator/calculator/domain/calculator_function.dart';

import '../helpers/calculator_driver.dart';

void main() {
  group('constants', () {
    test('pi is inserted as a literal', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..constant(CalculatorConstant.pi);

      expect(calculator.expression, 'pi');
      expect(calculator.result, '3.141592653589793');
    });

    test('e is inserted as a literal', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..constant(CalculatorConstant.e);

      expect(calculator.expression, 'e');
      expect(calculator.result, '2.718281828459045');
    });

    test('pi participates in arithmetic', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..constant(CalculatorConstant.pi)
        ..multiply()
        ..numbers('2')
        ..equals();

      expect(calculator.expression, 'pi*2');
      expect(calculator.result, '6.283185307179586');
    });

    test('constants can be used as an operator operand', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('2')
        ..power()
        ..constant(CalculatorConstant.e)
        ..equals();

      expect(calculator.expression, '2^e');
      expect(calculator.result, '6.5808859910179205');
    });

    test('digits after a constant are ignored (no implicit product)', () {
      // `5` followed by `pi` is not implicit multiplication (the reference has
      // none), so the `pi` key is ignored; `pi` followed by `5` cannot extend
      // a closed value either.
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('5')
        ..constant(CalculatorConstant.pi);

      expect(calculator.expression, '5');
    });

    test('a constant after = starts a fresh calculation', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('3')
        ..add()
        ..numbers('4')
        ..equals()
        ..constant(CalculatorConstant.pi);

      expect(calculator.expression, 'pi');
      expect(calculator.result, '3.141592653589793');
      expect(calculator.state.completedExpression, isNull);
    });

    test('constants are stored in memory like any value', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..constant(CalculatorConstant.pi)
        ..memory(MemoryOperation.store);

      expect(calculator.state.memory.value, closeTo(3.141592653589793, 1e-15));
    });
  });

  group('error handling', () {
    test('division by zero', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('1')
        ..divide()
        ..numbers('0')
        ..equals();

      expect(calculator.error, CalculatorError.divisionByZero);
      expect(calculator.result, 'Error');
      expect(calculator.expression, '1/0');
    });

    test('inverse trigonometric domain', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('2')
        ..function(CalculatorFunction.asin);

      expect(calculator.error, CalculatorError.inverseTrigDomain);
      expect(calculator.result, 'Error');
    });

    test('root of a negative number', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('2')
        ..signChange()
        ..power()
        ..numbers('0.5')
        ..equals();

      expect(calculator.error, CalculatorError.rootDomain);
    });

    test('the error message is available for accessibility', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('1')
        ..divide()
        ..numbers('0')
        ..equals();

      expect(calculator.state.errorMessage, isNotNull);
      expect(calculator.state.errorMessage, isNotEmpty);
    });

    test('an error survives unrelated keys', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('1')
        ..divide()
        ..numbers('0')
        ..equals()
        ..add()
        ..equals();

      expect(calculator.hasError, isTrue);
      expect(calculator.result, 'Error');
    });

    test('typing a new number recovers from an error', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('1')
        ..divide()
        ..numbers('0')
        ..equals()
        ..numbers('7');

      expect(calculator.hasError, isFalse);
      expect(calculator.result, '7');
    });

    test('backspace recovers from an error', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('1')
        ..divide()
        ..numbers('0')
        ..equals()
        ..backspace();

      expect(calculator.hasError, isFalse);
      expect(calculator.result, '0');
    });

    test('an error inside a parenthesis frame is reported', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..open()
        ..numbers('5')
        ..divide()
        ..numbers('0')
        ..close();

      expect(calculator.hasError, isTrue);
      expect(calculator.error, CalculatorError.divisionByZero);
    });

    test('overflow produces an error, not infinity', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('1000')
        ..function(CalculatorFunction.tenPow);

      expect(calculator.hasError, isTrue);
      expect(calculator.error, CalculatorError.overflow);
    });
  });
}