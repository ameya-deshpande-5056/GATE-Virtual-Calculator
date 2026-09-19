import 'package:flutter_test/flutter_test.dart';
import 'package:gate_calculator/calculator/domain/calculator_function.dart';

import '../helpers/calculator_driver.dart';

void main() {
  group('logarithms', () {
    test('30 -> log -> * -> 10 -> + -> 2 -> =', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('30')
        ..function(CalculatorFunction.log)
        ..multiply()
        ..numbers('10')
        ..add()
        ..numbers('2')
        ..equals();

      expect(calculator.expression, 'log(30)*10+2');
      expect(calculator.result, '16.771212547196626');
    });

    test('30 -> log applies immediately (no = needed)', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('30')
        ..function(CalculatorFunction.log);

      expect(calculator.expression, 'log(30)');
      expect(calculator.result, '1.4771212547196624');
      expect(calculator.state.entry, isNotNull);
    });

    test('20 -> log -> * -> 3 -> - -> 7 -> =', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('20')
        ..function(CalculatorFunction.log)
        ..multiply()
        ..numbers('3')
        ..subtract()
        ..numbers('7')
        ..equals();

      expect(calculator.expression, 'log(20)*3-7');
      expect(calculator.result, '-3.096910013008057');
    });

    test('15 -> ln -> * -> 2 -> + -> 8 -> =', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('15')
        ..function(CalculatorFunction.ln)
        ..multiply()
        ..numbers('2')
        ..add()
        ..numbers('8')
        ..equals();

      expect(calculator.expression, 'ln(15)*2+8');
      expect(calculator.result, '13.416100402204421');
    });

    test('15 -> ln -> * -> 2 -> + -> 3 -> = (reference screenshot)', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('15')
        ..function(CalculatorFunction.ln)
        ..multiply()
        ..numbers('2')
        ..add()
        ..numbers('3')
        ..equals();

      expect(calculator.expression, 'ln(15)*2+3');
      expect(calculator.result, '8.416100402204421');
    });

    test('log(1000) is 3 only up to one ULP', () {
      // `ln(x) / ln(10)` is one ULP below 3.  The reference is a JavaScript
      // calculator using the same formulation, and JavaScript's
      // `Math.log(1000)/Math.LN10` is also 2.9999999999999996, so the printed
      // string is expected to match (see `KNOWN_DIFFERENCES.md`).
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('1000')
        ..function(CalculatorFunction.log);

      expect(calculator.expression, 'log(1000)');
      expect(calculator.result, '2.9999999999999996');
    });

    test('log2x is base 2', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('8')
        ..function(CalculatorFunction.log2);

      expect(calculator.expression, 'log2(8)');
      expect(calculator.result, '3');
    });

    test('log_y x is an explicit binary operation', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('8')
        ..logBase()
        ..numbers('2')
        ..equals();

      expect(calculator.expression, '8log2');
      expect(calculator.result, '3');
    });

    test('invalid logarithm arguments produce an explicit error', () {
      final CalculatorDriver logZero = CalculatorDriver()
        ..numbers('0')
        ..function(CalculatorFunction.log);
      expect(logZero.hasError, isTrue);
      expect(logZero.result, 'Error');

      final CalculatorDriver logNegative = CalculatorDriver()
        ..numbers('5')
        ..signChange()
        ..function(CalculatorFunction.log);
      expect(logNegative.hasError, isTrue);
      expect(logNegative.result, 'Error');

      final CalculatorDriver lnZero = CalculatorDriver()
        ..numbers('0')
        ..function(CalculatorFunction.ln);
      expect(lnZero.hasError, isTrue);
      expect(lnZero.result, 'Error');
    });
  });
}