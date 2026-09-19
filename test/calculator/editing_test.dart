import 'package:flutter_test/flutter_test.dart';
import 'package:gate_calculator/calculator/domain/calculator_function.dart';

import '../helpers/calculator_driver.dart';

void main() {
  group('editing', () {
    test('123 -> backspace becomes 12', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('123')
        ..backspace();

      expect(calculator.result, '12');
      expect(calculator.expression, '12');
    });

    test('1.23 -> backspace becomes 1.2', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('1.23')
        ..backspace();

      expect(calculator.result, '1.2');
    });

    test('backspace over a decimal point', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('1.2')
        ..backspace()
        ..backspace();

      expect(calculator.result, '1');
    });

    test('backspace on a negative number keeps the sign', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('123')
        ..signChange()
        ..backspace();

      expect(calculator.result, '-12');
    });

    test('backspace removing the last digit returns to the previous term', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('60')
        ..add()
        ..numbers('35')
        ..backspace()
        ..backspace();

      expect(calculator.expression, '60+');
      expect(calculator.result, '60');
    });

    test('backspace then removes the pending operator', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('60')
        ..add()
        ..numbers('35')
        ..backspace()
        ..backspace()
        ..backspace();

      expect(calculator.expression, '60');
      expect(calculator.state.hasPendingOperation, isFalse);
      expect(calculator.result, '60');
    });

    test('backspace during operator input removes the pending operator', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('60')
        ..add()
        ..backspace();

      expect(calculator.expression, '60');
      expect(calculator.state.hasPendingOperation, isFalse);
    });

    test('backspace undoes the outermost function application', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('25')
        ..function(CalculatorFunction.sin)
        ..backspace();

      expect(calculator.expression, '25');
      expect(calculator.result, '25');
    });

    test('backspace cannot remove the argument of a function', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('25')
        ..function(CalculatorFunction.sin)
        ..backspace()
        ..backspace();

      expect(calculator.expression, '25');
    });

    test('backspace after = is ignored (the expression is complete)', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('25')
        ..add()
        ..numbers('5')
        ..equals()
        ..backspace();

      expect(calculator.expression, '25+5');
      expect(calculator.result, '30');
    });

    test('backspace on an empty calculator does nothing', () {
      final CalculatorDriver calculator = CalculatorDriver()..backspace();

      expect(calculator.result, '0');
      expect(calculator.expression, '');
    });

    test('double decimal points are ignored', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('1.2.3');

      expect(calculator.result, '1.23');
    });

    test('leading decimal point becomes 0.', () {
      final CalculatorDriver calculator = CalculatorDriver()..decimal();

      expect(calculator.result, '0.');
    });
  });

  group('decimal entry', () {
    test('leading zero is not duplicated', () {
      final CalculatorDriver calculator = CalculatorDriver()..numbers('007');

      expect(calculator.result, '7');
    });

    test('decimal after an operator starts 0.', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('5')
        ..add()
        ..decimal();

      expect(calculator.result, '0.');
      expect(calculator.expression, '5+0.');
    });

    test('decimal in the exponent operand', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('2')
        ..power()
        ..numbers('0.5');

      expect(calculator.expression, '2^0.5');
      expect(calculator.result, '0.5');
    });
  });
}