import '../../calculator/domain/calculator_error.dart';

/// Internal exception thrown while evaluating an expression.
///
/// The calculator engine catches every [CalculatorException] and turns it into
/// an explicit [CalculatorError] on the state.  Dart exceptions must never
/// reach the user interface.
class CalculatorException implements Exception {
  const CalculatorException(this.error, [this.detail]);

  final CalculatorError error;
  final String? detail;

  @override
  String toString() =>
      detail == null ? 'CalculatorException(${error.name})' : 'CalculatorException(${error.name}: $detail)';
}
