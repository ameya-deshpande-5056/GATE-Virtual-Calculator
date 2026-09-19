import 'package:flutter_test/flutter_test.dart';
import 'package:gate_calculator/calculator/domain/calculator_function.dart';

import '../helpers/calculator_driver.dart';

void main() {
  group('roots', () {
    test('8 -> y-root -> 4 -> = (reference: 8yroot4)', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('8')
        ..yRoot()
        ..numbers('4')
        ..equals();

      expect(calculator.expression, '8yroot4');
      // Byte-identical to the reference screenshot, including the fact that the
      // printed value is one ULP above the correctly rounded fourth root.
      expect(calculator.result, '1.6817928305074292');
    });

    test('8 -> y-root -> 4 shows the right hand operand while typing', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('8')
        ..yRoot()
        ..numbers('4');

      expect(calculator.expression, '8yroot4');
      expect(calculator.result, '4');
    });

    test('5 -> cube root', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('5')
        ..function(CalculatorFunction.cubeRoot);

      expect(calculator.expression, 'cuberoot(5)');
      expect(calculator.result, '1.709975946676697');
    });

    test('125 -> cube root (reference screenshot)', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('125')
        ..function(CalculatorFunction.cubeRoot);

      expect(calculator.expression, 'cuberoot(125)');
      expect(calculator.result, '5');
    });

    test('exact cubes come back exact', () {
      for (final int value in <int>[1, 8, 27, 64, 1000]) {
        final CalculatorDriver calculator = CalculatorDriver()
          ..numbers('$value')
          ..function(CalculatorFunction.cubeRoot);
        expect(
          calculator.result,
          '${_integerCubeRoot(value)}',
          reason: 'cuberoot($value)',
        );
      }
    });

    test('6 -> square root', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('6')
        ..function(CalculatorFunction.squareRoot);

      expect(calculator.expression, 'sqrt(6)');
      expect(calculator.result, '2.449489742783178');
    });

    test('square root of 2 and of 9', () {
      expect(
        (CalculatorDriver()..numbers('2')..function(CalculatorFunction.squareRoot)).result,
        '1.4142135623730951',
      );
      expect(
        (CalculatorDriver()..numbers('9')..function(CalculatorFunction.squareRoot)).result,
        '3',
      );
    });

    test('cube root of a negative number is real', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('8')
        ..signChange()
        ..function(CalculatorFunction.cubeRoot);

      expect(calculator.result, '-2');
    });

    test('3rd root of -8 is real', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('8')
        ..signChange()
        ..yRoot()
        ..numbers('3')
        ..equals();

      expect(calculator.result, '-2');
    });

    test('nested roots round-trip', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('16')
        ..yRoot()
        ..numbers('4')
        ..equals();

      expect(calculator.result, '2');
    });

    test('square root of a negative number is an error', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('4')
        ..signChange()
        ..function(CalculatorFunction.squareRoot);

      expect(calculator.hasError, isTrue);
      expect(calculator.result, 'Error');
    });

    test('even root of a negative number is an error', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('16')
        ..signChange()
        ..yRoot()
        ..numbers('2')
        ..equals();

      expect(calculator.hasError, isTrue);
      expect(calculator.result, 'Error');
    });

    test('zero index root is an error', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('8')
        ..yRoot()
        ..numbers('0')
        ..equals();

      expect(calculator.hasError, isTrue);
      expect(calculator.result, 'Error');
    });
  });
}

int _integerCubeRoot(int value) {
  int result = 0;
  while (result * result * result < value) {
    result++;
  }
  return result;
}