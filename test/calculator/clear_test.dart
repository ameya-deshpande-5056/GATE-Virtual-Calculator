import 'package:flutter_test/flutter_test.dart';
import 'package:gate_calculator/calculator/domain/angle_mode.dart';
import 'package:gate_calculator/calculator/domain/calculator_action.dart';
import 'package:gate_calculator/calculator/domain/calculator_function.dart';

import '../helpers/calculator_driver.dart';

void main() {
  group('C during normal input', () {
    test('resets the display and the expression', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('123')
        ..clear();

      expect(calculator.expression, '');
      expect(calculator.result, '0');
      expect(calculator.state.entry, isNull);
      expect(calculator.state.terms, isEmpty);
      expect(calculator.state.justEvaluated, isFalse);
    });

    test('keeps the angle mode and the memory register', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..angleMode(AngleMode.radian)
        ..numbers('9')
        ..memory(MemoryOperation.store)
        ..clear();

      expect(calculator.state.angleMode, AngleMode.radian);
      expect(calculator.state.memory.value, 9);
    });
  });

  group('C during operator input', () {
    test('clears the pending operation as well', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('60')
        ..add()
        ..clear();

      expect(calculator.expression, '');
      expect(calculator.state.hasPendingOperation, isFalse);
      expect(calculator.result, '0');
    });

    test('clears inside a parenthesis frame', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('73')
        ..multiply()
        ..open()
        ..numbers('2')
        ..clear();

      // The reference starts a brand new calculation on `C`; open frames are
      // dropped with it.
      expect(calculator.expression, '');
      expect(calculator.state.groups, isEmpty);
      expect(calculator.result, '0');
    });
  });

  group('C during function input', () {
    test('clears an applied function', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('25')
        ..function(CalculatorFunction.sin)
        ..clear();

      expect(calculator.expression, '');
      expect(calculator.result, '0');
    });

    test('clears a function error state', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('0')
        ..function(CalculatorFunction.log)
        ..clear();

      expect(calculator.hasError, isFalse);
      expect(calculator.result, '0');
    });
  });

  group('C after a completed calculation', () {
    test('starts a fresh calculation', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('25')
        ..add()
        ..numbers('5')
        ..equals()
        ..clear();

      expect(calculator.expression, '');
      expect(calculator.result, '0');
      expect(calculator.state.completedExpression, isNull);

      // ... and the next operand starts from scratch.
      calculator
        ..numbers('4')
        ..equals();
      expect(calculator.result, '4');
    });
  });

  group('C after an error', () {
    test('recovers to a fresh calculator', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('1')
        ..divide()
        ..numbers('0')
        ..equals()
        ..clear();

      expect(calculator.hasError, isFalse);
      expect(calculator.result, '0');
    });
  });

  group('C as the first key', () {
    test('is harmless', () {
      final CalculatorDriver calculator = CalculatorDriver()..clear();

      expect(calculator.result, '0');
      expect(calculator.expression, '');
    });
  });
}