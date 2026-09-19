/// Lexical pieces of an expression display.
///
/// The expression display of the reference calculator is a rendering of the
/// parsed key sequence (it is *not* derived from the result display), so the
/// expression tree is tokenised and the tokens are concatenated to build the
/// top display line.
sealed class ExpressionToken {
  const ExpressionToken();

  /// Text contributed to the expression display.
  String get text;
}

/// A literal operand, e.g. `25`, `1.5`, `pi`.
final class NumberToken extends ExpressionToken {
  const NumberToken(this.text);

  @override
  final String text;
}

/// A binary operator or constant symbol, e.g. `+`, `*`, `yroot`, `pi`.
final class SymbolToken extends ExpressionToken {
  const SymbolToken(this.text);

  @override
  final String text;
}

/// The name of a function, e.g. `sin`, `fact`, `cuberoot`.
final class FunctionNameToken extends ExpressionToken {
  const FunctionNameToken(this.text);

  @override
  final String text;
}

/// `(` or `)`.
final class ParenthesisToken extends ExpressionToken {
  const ParenthesisToken(this.text);

  @override
  final String text;
}
