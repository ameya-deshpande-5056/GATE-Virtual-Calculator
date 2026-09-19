import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gate_calculator/app.dart';
import 'package:gate_calculator/calculator/domain/calculator_action.dart';
import 'package:gate_calculator/calculator/domain/calculator_operation.dart';
import 'package:gate_calculator/calculator/presentation/widgets/calculator_key.dart';

/// Finds a keypad key by the semantic label it exposes for accessibility.
Finder keyWithLabel(String label) => find.byWidgetPredicate(
      (widget) => widget is CalculatorKey && widget.semanticLabel == label,
      description: 'key "$label"',
    );

/// Text shown inside the named display box (`expressionDisplay` / `resultDisplay`).
Finder displayText(String boxKey, String text) => find.descendant(
      of: find.byKey(ValueKey<String>(boxKey)),
      matching: find.text(text),
    );

void main() {
  testWidgets('calculator launches with empty expression and zero result',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GateCalculatorApp());

    expect(find.text('Scientific Calculator'), findsOneWidget);
    expect(displayText('expressionDisplay', ''), findsOneWidget);
    expect(displayText('resultDisplay', '0'), findsOneWidget);
  });

  testWidgets('typing 7 then 3 updates the displays',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GateCalculatorApp());

    await tester.tap(keyWithLabel('seven key'));
    await tester.pump();
    expect(displayText('expressionDisplay', '7'), findsOneWidget);
    expect(displayText('resultDisplay', '7'), findsOneWidget);

    // `*` commits the pending operand, so the lower display keeps the
    // value while the upper display shows the key sequence.
    await tester.tap(keyWithLabel('multiply'));
    await tester.pump();
    await tester.tap(keyWithLabel('three key'));
    await tester.pump();
    expect(displayText('expressionDisplay', '7*3'), findsOneWidget);
    expect(displayText('resultDisplay', '3'), findsOneWidget);
  });

  testWidgets('7 * 3 = shows 21 in the result display',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GateCalculatorApp());

    await tester.tap(keyWithLabel('seven key'));
    await tester.pump();
    await tester.tap(keyWithLabel('multiply'));
    await tester.pump();
    await tester.tap(keyWithLabel('three key'));
    await tester.pump();
    await tester.tap(keyWithLabel('equals'));
    await tester.pump();
    expect(displayText('expressionDisplay', '7*3'), findsOneWidget);
    expect(displayText('resultDisplay', '21'), findsOneWidget);
  });

  testWidgets('keypad exposes the postfix sine key of the GATE model',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GateCalculatorApp());
    // The GATE interaction model applies functions after the operand
    // (`25 -> sin`); the engine tests cover the behaviour, here we just
    // verify the key exists alongside the digit keys.
    expect(keyWithLabel('sine'), findsOneWidget);
    expect(keyWithLabel('seven key'), findsOneWidget);
    expect(
      CalculatorAction.operator(CalculatorOperation.power).describe(),
      '^',
    );
  });
}
