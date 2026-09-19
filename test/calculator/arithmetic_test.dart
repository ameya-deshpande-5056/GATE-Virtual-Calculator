import 'package:flutter_test/flutter_test.dart';

import '../helpers/calculator_driver.dart';

void main() {
  group('arithmetic', () {
    test('60 + 35 x 5 uses standard precedence', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('60')
        ..add()
        ..numbers('35')
        ..multiply()
        ..numbers('5')
        ..equals();

      expect(calculator.expression, '60+35*5');
      expect(calculator.result, '235');
      expect(calculator.value, 235);
    });

    test('75 x 40 - 3', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('75')
        ..multiply()
        ..numbers('40')
        ..subtract()
        ..numbers('3')
        ..equals();

      expect(calculator.expression, '75*40-3');
      expect(calculator.result, '2997');
    });

    test('73 x (2 + 3)', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('73')
        ..multiply()
        ..open()
        ..numbers('2')
        ..add()
        ..numbers('3')
        ..close()
        ..equals();

      expect(calculator.expression, '73*(2+3)');
      expect(calculator.result, '365');
    });

    test('(2 + 3) x 4', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..open()
        ..numbers('2')
        ..add()
        ..numbers('3')
        ..close()
        ..multiply()
        ..numbers('4')
        ..equals();

      expect(calculator.expression, '(2+3)*4');
      expect(calculator.result, '20');
    });

    test('nested parentheses', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..open()
        ..open()
        ..numbers('2')
        ..add()
        ..numbers('3')
        ..close()
        ..multiply()
        ..numbers('4')
        ..close()
        ..equals();

      expect(calculator.expression, '((2+3)*4)');
      expect(calculator.result, '20');
    });

    test('division and subtraction are left associative', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('100')
        ..subtract()
        ..numbers('30')
        ..subtract()
        ..numbers('20')
        ..equals();

      expect(calculator.result, '50');
    });

    test('division by zero reports an explicit error', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('1')
        ..divide()
        ..numbers('0')
        ..equals();

      expect(calculator.hasError, isTrue);
      expect(calculator.result, 'Error');
      expect(calculator.expression, '1/0');
    });

    test('decimal arithmetic', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('45.25')
        ..add()
        ..numbers('32.75')
        ..equals();

      expect(calculator.result, '78');
    });

    test('modulo', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('10')
        ..modulo()
        ..numbers('3')
        ..equals();

      expect(calculator.expression, '10mod3');
      expect(calculator.result, '1');
    });

    test('pressing two operators in a row replaces the pending one', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('6')
        ..add()
        ..multiply()
        ..numbers('7')
        ..equals();

      expect(calculator.expression, '6*7');
      expect(calculator.result, '42');
    });
  });
}