import 'package:flutter_test/flutter_test.dart';
import 'package:gate_calculator/calculator/domain/angle_mode.dart';
import 'package:gate_calculator/calculator/domain/calculator_function.dart';

import '../helpers/calculator_driver.dart';

void main() {
  group('trigonometry in degree mode', () {
    test('25 -> sin', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('25')
        ..function(CalculatorFunction.sin);

      // Degree-mode trig is printed with the `d` suffix (`tand` is confirmed by
      // the reference screenshot; `sind`/`cosd` follow the same library fixup).
      expect(calculator.expression, 'sind(25)');
      expect(calculator.result, '0.42261826174069944');
    });

    test('25 -> cos', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('25')
        ..function(CalculatorFunction.cos);

      expect(calculator.expression, 'cosd(25)');
      expect(calculator.result, '0.9063077870366499');
    });

    test('25 -> tan', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('25')
        ..function(CalculatorFunction.tan);

      expect(calculator.expression, 'tand(25)');
      expect(calculator.result, '0.4663076581549986');
    });

    test('35 -> tan -> * -> 6 -> + -> 2 -> = (reference screenshot)', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('35')
        ..function(CalculatorFunction.tan)
        ..multiply()
        ..numbers('6')
        ..add()
        ..numbers('2')
        ..equals();

      expect(calculator.expression, 'tand(35)*6+2');
      expect(calculator.result, '6.201245229258259');
    });

    test('inverse functions return degrees', () {
      final CalculatorDriver arcsine = CalculatorDriver()
        ..numbers('0.5')
        ..function(CalculatorFunction.asin);
      expect(arcsine.expression, 'asin(0.5)');
      // Degrees conversion is a double operation: 30 comes back as
      // 30.000000000000004 (identical to JavaScript's `Math.asin(0.5)*180/Math.PI`).
      expect(arcsine.result, '30.000000000000004');

      final CalculatorDriver arccosine = CalculatorDriver()
        ..numbers('0.5')
        ..function(CalculatorFunction.acos);
      expect(arccosine.result, '60.00000000000001');

      final CalculatorDriver arctangent = CalculatorDriver()
        ..numbers('1')
        ..function(CalculatorFunction.atan);
      expect(arctangent.result, '45');
    });

    test('sin(30) is 0.5 up to one ULP', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('30')
        ..function(CalculatorFunction.sin);

      expect(double.parse(calculator.result), closeTo(0.5, 1e-15));
    });
  });

  group('trigonometry in radian mode', () {
    test('25 -> sin is interpreted as radians and printed as `sin`', () {
      final CalculatorDriver calculator = CalculatorDriver(mode: AngleMode.radian)
        ..numbers('25')
        ..function(CalculatorFunction.sin);

      expect(calculator.expression, 'sin(25)');
      expect(calculator.result, '-0.13235175009777303');
    });

    test('inverse functions return radians', () {
      final CalculatorDriver calculator = CalculatorDriver(mode: AngleMode.radian)
        ..numbers('0.5')
        ..function(CalculatorFunction.asin);

      expect(calculator.result, '0.5235987755982989');
    });

    test('switching the mode re-evaluates what is already displayed', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('25')
        ..function(CalculatorFunction.sin)
        ..angleMode(AngleMode.radian);

      expect(calculator.expression, 'sin(25)');
      expect(calculator.result, '-0.13235175009777303');
      expect(calculator.state.memory.value, 0);
    });

    test('switching the mode affects a completed calculation too', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('25')
        ..function(CalculatorFunction.sin)
        ..equals()
        ..angleMode(AngleMode.radian);

      expect(calculator.result, '-0.13235175009777303');
      expect(calculator.expression, 'sin(25)');
    });
  });

  group('hyperbolic functions', () {
    test('sinh / cosh / tanh', () {
      expect(
        (CalculatorDriver()..numbers('1')..function(CalculatorFunction.sinh)).result,
        '1.1752011936438014',
      );
      expect(
        (CalculatorDriver()..numbers('0')..function(CalculatorFunction.cosh)).result,
        '1',
      );
      expect(
        (CalculatorDriver()..numbers('1')..function(CalculatorFunction.tanh)).result,
        '0.7615941559557649',
      );
    });

    test('inverse hyperbolic functions', () {
      expect(
        (CalculatorDriver()..numbers('1')..function(CalculatorFunction.asinh)).result,
        '0.8813735870195429',
      );
      expect(
        (CalculatorDriver()..numbers('1')..function(CalculatorFunction.acosh)).result,
        '0',
      );
      expect(
        (CalculatorDriver()..numbers('0.5')..function(CalculatorFunction.atanh)).result,
        '0.5493061443340549',
      );
    });

    test('out of domain inputs are reported as errors', () {
      final CalculatorDriver asin = CalculatorDriver()
        ..numbers('2')
        ..function(CalculatorFunction.asin);
      expect(asin.hasError, isTrue);

      final CalculatorDriver acosh = CalculatorDriver()
        ..numbers('0.5')
        ..function(CalculatorFunction.acosh);
      expect(acosh.hasError, isTrue);

      final CalculatorDriver atanh = CalculatorDriver()
        ..numbers('1')
        ..function(CalculatorFunction.atanh);
      expect(atanh.hasError, isTrue);
    });
  });
}