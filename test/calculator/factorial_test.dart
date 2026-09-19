import 'package:flutter_test/flutter_test.dart';
import 'package:gate_calculator/calculator/domain/calculator_error.dart';
import 'package:gate_calculator/calculator/domain/calculator_function.dart';

import '../helpers/calculator_driver.dart';

void main() {
  group('factorial', () {
    test('5 -> n!', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('5')
        ..function(CalculatorFunction.factorial);

      expect(calculator.expression, 'fact(5)');
      expect(calculator.result, '120');
    });

    test('8 -> n! -> * -> 5 -> - -> 2 -> = (reference screenshot)', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('8')
        ..function(CalculatorFunction.factorial)
        ..multiply()
        ..numbers('5')
        ..subtract()
        ..numbers('2')
        ..equals();

      expect(calculator.expression, 'fact(8)*5-2');
      expect(calculator.result, '201598');
    });

    test('0! == 1', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('0')
        ..function(CalculatorFunction.factorial);

      expect(calculator.result, '1');
    });

    test('large but representable factorials', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('20')
        ..function(CalculatorFunction.factorial);

      expect(calculator.result, '2432902008176640000');
    });

    test('negative factorials are an explicit error', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('5')
        ..signChange()
        ..function(CalculatorFunction.factorial);

      expect(calculator.hasError, isTrue);
      expect(calculator.error, CalculatorError.factorialDomain);
      expect(calculator.result, 'Error');
    });

    test('non-integer factorials are an explicit error', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('2.5')
        ..function(CalculatorFunction.factorial);

      expect(calculator.hasError, isTrue);
      expect(calculator.error, CalculatorError.factorialDomain);
    });

    test('overflowing factorials are an explicit error', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('171')
        ..function(CalculatorFunction.factorial);

      expect(calculator.hasError, isTrue);
      expect(calculator.error, CalculatorError.factorialOverflow);
    });
  });
}