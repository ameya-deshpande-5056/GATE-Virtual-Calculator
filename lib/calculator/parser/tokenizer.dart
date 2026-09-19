import '../../core/utils/number_formatter.dart';
import '../domain/angle_mode.dart';
import 'expression.dart';
import 'token.dart';

/// Converts an [Expression] tree into the token stream that the expression
/// display renders.
///
/// The token names/symbols are the ones the reference calculator prints
/// (`fact(8)*5-2`, `cuberoot(125)`, `8yroot4`).
class ExpressionTokenizer {
  const ExpressionTokenizer._();

  static List<ExpressionToken> tokenize(
    Expression expression,
    AngleMode mode,
  ) {
    switch (expression) {
      case NumberExpression():
        return <ExpressionToken>[
          NumberToken(
            expression.sourceText ?? NumberFormatter.format(expression.value),
          ),
        ];
      case ConstantExpression():
        return <ExpressionToken>[SymbolToken(expression.constant.symbol)];
      case UnaryExpression():
        return <ExpressionToken>[
          FunctionNameToken(expression.function.displayName(mode)),
          const ParenthesisToken('('),
          ...tokenize(expression.operand, mode),
          const ParenthesisToken(')'),
        ];
      case BinaryExpression():
        return <ExpressionToken>[
          ...tokenize(expression.left, mode),
          SymbolToken(expression.operation.symbol),
          ...tokenize(expression.right, mode),
        ];
      case ParenthesizedExpression():
        return <ExpressionToken>[
          const ParenthesisToken('('),
          ...tokenize(expression.inner, mode),
          const ParenthesisToken(')'),
        ];
      case NegatedExpression():
        return <ExpressionToken>[
          const SymbolToken('-'),
          ...tokenize(expression.operand, mode),
        ];
    }
  }

  /// Renders the token stream as the single line shown in the expression
  /// display, e.g. `fact(8)*5-2`.
  static String render(Expression expression, AngleMode mode) =>
      tokenize(expression, mode)
          .map((ExpressionToken token) => token.text)
          .join();
}

/// Convenience accessors for display rendering.
extension ExpressionRendering on Expression {
  /// Token stream of this expression.
  List<ExpressionToken> tokens(AngleMode mode) =>
      ExpressionTokenizer.tokenize(this, mode);

  /// Single-line rendering used by the expression display.
  String displayText(AngleMode mode) =>
      ExpressionTokenizer.render(this, mode);
}
