import 'package:flutter_test/flutter_test.dart';
import 'package:gate_calculator/calculator/domain/calculator_function.dart';

import '../helpers/calculator_driver.dart';

void main() {
  group('powers', () {
    test('48 -> x^3 -> * -> 6 -> + -> 9 -> =', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('48')
        ..function(CalculatorFunction.cube)
        ..multiply()
        ..numbers('6')
        ..add()
        ..numbers('9')
        ..equals();

      expect(calculator.expression, 'cube(48)*6+9');
      expect(calculator.result, '663561');
    });

    test('20 -> x^y -> 2 -> +/- -> =', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('20')
        ..power()
        ..numbers('2')
        ..signChange()
        ..equals();

      expect(calculator.expression, '20^-2');
      expect(calculator.result, '0.0025');
    });

    test('18 -> x^y -> 0.509 -> +/- -> = (reference screenshot)', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('18')
        ..power()
        ..numbers('0.509')
        ..signChange()
        ..equals();

      expect(calculator.expression, '18^-0.509');
      expect(calculator.result, '0.22964991811628313');
    });

    test('sign change applies to the exponent operand only', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('20')
        ..power()
        ..numbers('2')
        ..signChange();

      expect(calculator.expression, '20^-2');
      expect(calculator.result, '-2');
    });

    test('4 -> x^2', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('4')
        ..function(CalculatorFunction.square);

      expect(calculator.expression, 'square(4)');
      expect(calculator.result, '16');
    });

    test('0 -> e^x', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('0')
        ..function(CalculatorFunction.exponential);

      expect(calculator.expression, 'exp(0)');
      expect(calculator.result, '1');
    });

    test('1 -> e^x', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('1')
        ..function(CalculatorFunction.exponential);

      expect(calculator.result, '2.718281828459045');
    });

    test('2 -> 10^x', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('2')
        ..function(CalculatorFunction.tenPow);

      expect(calculator.expression, '10pow(2)');
      expect(calculator.result, '100');
    });

    test('8 -> 1/x', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('8')
        ..function(CalculatorFunction.reciprocal);

      expect(calculator.expression, 'reciprocal(8)');
      expect(calculator.result, '0.125');
    });

    test('0 -> 1/x is an error', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('0')
        ..function(CalculatorFunction.reciprocal);

      expect(calculator.hasError, isTrue);
      expect(calculator.result, 'Error');
    });

    test('absolute value of a negative operand', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('5')
        ..signChange()
        ..function(CalculatorFunction.absolute);

      expect(calculator.expression, 'abs(-5)');
      expect(calculator.result, '5');
    });

    test('% divides the operand by 100', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('200')
        ..multiply()
        ..numbers('15')
        ..function(CalculatorFunction.percent)
        ..equals();

      expect(calculator.expression, '200*percent(15)');
      expect(calculator.result, '30');
    });

    test('Exp enters scientific notation', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('1.5')
        ..expKey()
        ..numbers('3')
        ..equals();

      expect(calculator.expression, '1.5E3');
      expect(calculator.result, '1500');
    });

    test('x^y with a fractional exponent', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('2')
        ..power()
        ..numbers('0.5')
        ..equals();

      expect(calculator.result, '1.4142135623730951');
    });

    test('negative base with a fractional exponent is an error', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('2')
        ..signChange()
        ..power()
        ..numbers('0.5')
        ..equals();

      expect(calculator.hasError, isTrue);
      expect(calculator.result, 'Error');
    });

    test('overflow is reported instead of infinity', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('99999999999')
        ..power()
        ..numbers('99999999999')
        ..equals();

      expect(calculator.hasError, isTrue);
      expect(calculator.result, 'Error');
    });
  });
}