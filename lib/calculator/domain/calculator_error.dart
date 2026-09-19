/// Errors that the calculator can report instead of crashing.
///
/// The reference calculator shows a single `Error` token in the result display;
/// the enum keeps a machine readable reason and a human readable description so
/// the UI can expose the cause through accessibility/tooltips without changing
/// the (faithful) `Error` text.
enum CalculatorError {
  divisionByZero('divide by zero'),
  logarithmDomain('logarithm is only defined for values greater than zero'),
  squareRootDomain('square root is only defined for non-negative values'),
  rootDomain('root is not defined for this combination of values'),
  inverseTrigDomain('inverse trigonometric function is outside -1..1'),
  hyperbolicDomain('inverse hyperbolic function is outside its domain'),
  factorialDomain('factorial is only defined for non-negative integers'),
  factorialOverflow('factorial result is too large'),
  overflow('result is too large to represent'),
  undefinedResult('result is not a real number'),
  malformedExpression('expression could not be evaluated');

  const CalculatorError(this.description);

  /// Human readable description used for accessibility and diagnostics.
  final String description;
}
