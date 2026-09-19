import 'package:flutter_test/flutter_test.dart';
import 'package:gate_calculator/core/utils/number_formatter.dart';

void main() {
  group('NumberFormatter', () {
    test('integral values have no trailing `.0`', () {
      expect(NumberFormatter.format(0), '0');
      expect(NumberFormatter.format(365), '365');
      expect(NumberFormatter.format(100), '100');
      expect(NumberFormatter.format(-201598), '-201598');
      expect(NumberFormatter.format(663561), '663561');
    });

    test('negative zero is printed as `0`', () {
      expect(NumberFormatter.format(-0.0), '0');
      expect(NumberFormatter.format(-0), '0');
    });

    test('shortest round-trip decimals', () {
      expect(NumberFormatter.format(2.5), '2.5');
      expect(NumberFormatter.format(0.0025), '0.0025');
      // 0.1 + 0.2 is not exactly 0.3; like JavaScript the display shows the
      // double as-is instead of hiding the artefact.
      expect(NumberFormatter.format(0.1 + 0.2), '0.30000000000000004');
      expect(NumberFormatter.format(1 / 3), '0.3333333333333333');
      expect(NumberFormatter.format(0.22964991811628313), '0.22964991811628313');
      expect(NumberFormatter.format(1.6817928305074292), '1.6817928305074292');
    });

    test('values below the display range switch to exponent notation', () {
      expect(NumberFormatter.format(1e-7), '1e-7');
      expect(NumberFormatter.format(1e-20), '1e-20');
    });

    test('very large values switch to exponent notation', () {
      // JavaScript/Dart keep plain digits below 1e21.
      expect(NumberFormatter.format(1.23456789e19), '12345678900000000000');
      expect(NumberFormatter.format(1e21), '1e+21');
      expect(NumberFormatter.format(1.5e21), '1.5e+21');
    });

    test('NaN and infinities are errors', () {
      expect(NumberFormatter.format(double.nan), 'Error');
      expect(NumberFormatter.format(double.infinity), 'Error');
      expect(NumberFormatter.format(double.negativeInfinity), 'Error');
    });

    test('typed buffers are parsed verbatim', () {
      expect(NumberFormatter.tryParseInput('0'), 0);
      expect(NumberFormatter.tryParseInput('0.5'), 0.5);
      expect(NumberFormatter.tryParseInput('5.'), 5);
      expect(NumberFormatter.tryParseInput('.5'), 0.5);
      expect(NumberFormatter.tryParseInput(''), isNull);
    });
  });
}