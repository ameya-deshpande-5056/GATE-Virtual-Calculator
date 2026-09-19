import 'package:flutter_test/flutter_test.dart';
import 'package:gate_calculator/calculator/domain/angle_mode.dart';
import 'package:gate_calculator/calculator/domain/calculator_action.dart';
import 'package:gate_calculator/calculator/domain/calculator_constant.dart';
import 'package:gate_calculator/calculator/domain/calculator_function.dart';
import 'package:gate_calculator/calculator/domain/calculator_operation.dart';

import '../helpers/calculator_driver.dart';

/// Golden test collection transcribed from the reference material.
///
/// Every case documents the angle mode, the exact button sequence, the
/// expression (key-sequence) display and the numerical display.
///
/// `source` records where the expectation comes from:
///
/// * `screenshot` - byte-identical to one of the seven reference screenshots
///   in `reference/screenshots/` (`KEYPAD_LAYOUT.md` lists them).
/// * `specification` - from the task specification / the BYJU'S description.
///   The expected strings were cross-checked against JavaScript's `Math.*`
///   (the reference is a JavaScript implementation) but no screenshot shows
///   that exact display.
/// * `inferred` - behaviour derived from the reference model where no
///   reference text covers the case.
enum ReferenceSource { screenshot, specification, inferred }

class _Case {
  const _Case({
    required this.name,
    required this.mode,
    required this.actions,
    required this.expression,
    required this.result,
    this.source = ReferenceSource.inferred,
  });

  final String name;
  final AngleMode mode;
  final List<CalculatorAction> actions;
  final String expression;
  final String result;
  final ReferenceSource source;
}

Iterable<CalculatorAction> _digits(String literal) sync* {
  for (final int rune in literal.runes) {
    final String character = String.fromCharCode(rune);
    yield character == '.'
        ? const CalculatorAction.decimalPoint()
        : CalculatorAction.number(int.parse(character));
  }
}

/// Builds an action list from a compact sequence description.
///
/// Elements may be a digit string (`'0.509'`), a [CalculatorOperation], a
/// [CalculatorFunction], a [CalculatorConstant], a [MemoryOperation] or an
/// already built [CalculatorAction].
List<CalculatorAction> _steps(List<Object> steps) => <CalculatorAction>[
      for (final Object step in steps)
        if (step is CalculatorAction)
          step
        else if (step is String)
          ..._digits(step)
        else if (step is CalculatorOperation)
          CalculatorAction.operator(step)
        else if (step is CalculatorFunction)
          CalculatorAction.function(step)
        else if (step is CalculatorConstant)
          CalculatorAction.constant(step)
        else if (step is MemoryOperation)
          CalculatorAction.memory(step),
    ];

const CalculatorAction _equals = CalculatorAction.equals;
const CalculatorAction _plusMinus = CalculatorAction.signChange;
const CalculatorAction _open = CalculatorAction.openParenthesis();
const CalculatorAction _close = CalculatorAction.closeParenthesis();

final List<_Case> _cases = <_Case>[
  // CASES_PART_1
  _Case(
    name: '73 x (2 + 3) =',
    mode: AngleMode.degree,
    actions: _steps(<Object>[
      '73', CalculatorOperation.multiply, _open, '2', CalculatorOperation.add, '3', _close, _equals,
    ]),
    expression: '73*(2+3)',
    result: '365',
    source: ReferenceSource.screenshot,
  ),
  _Case(
    name: '15 -> ln -> x -> 2 -> + -> 3 -> =',
    mode: AngleMode.degree,
    actions: _steps(<Object>[
      '15', CalculatorFunction.ln, CalculatorOperation.multiply, '2', CalculatorOperation.add, '3', _equals,
    ]),
    expression: 'ln(15)*2+3',
    result: '8.416100402204421',
    source: ReferenceSource.screenshot,
  ),
  _Case(
    name: '35 -> tan -> x -> 6 -> + -> 2 -> =',
    mode: AngleMode.degree,
    actions: _steps(<Object>[
      '35', CalculatorFunction.tan, CalculatorOperation.multiply, '6', CalculatorOperation.add, '2', _equals,
    ]),
    expression: 'tand(35)*6+2',
    result: '6.201245229258259',
    source: ReferenceSource.screenshot,
  ),
  _Case(
    name: '8 -> y-root -> 4 -> =',
    mode: AngleMode.degree,
    actions: _steps(<Object>['8', CalculatorOperation.yRoot, '4', _equals]),
    expression: '8yroot4',
    result: '1.6817928305074292',
    source: ReferenceSource.screenshot,
  ),
  _Case(
    name: '125 -> cube root',
    mode: AngleMode.degree,
    actions: _steps(<Object>['125', CalculatorFunction.cubeRoot]),
    expression: 'cuberoot(125)',
    result: '5',
    source: ReferenceSource.screenshot,
  ),
  _Case(
    name: '8 -> n! -> x -> 5 -> - -> 2 -> =',
    mode: AngleMode.degree,
    actions: _steps(<Object>[
      '8', CalculatorFunction.factorial, CalculatorOperation.multiply, '5', CalculatorOperation.subtract, '2', _equals,
    ]),
    expression: 'fact(8)*5-2',
    result: '201598',
    source: ReferenceSource.screenshot,
  ),
  _Case(
    name: '18 -> x^y -> 0.509 -> +/- -> =',
    mode: AngleMode.degree,
    actions: _steps(<Object>['18', CalculatorOperation.power, '0.509', _plusMinus, _equals]),
    expression: '18^-0.509',
    result: '0.22964991811628313',
    source: ReferenceSource.screenshot,
  ),
  // CASES_PART_2
  _Case(
    name: '60 + 35 x 5 =',
    mode: AngleMode.degree,
    actions: _steps(<Object>['60', CalculatorOperation.add, '35', CalculatorOperation.multiply, '5', _equals]),
    expression: '60+35*5',
    result: '235',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '75 x 40 - 3 =',
    mode: AngleMode.degree,
    actions: _steps(<Object>['75', CalculatorOperation.multiply, '40', CalculatorOperation.subtract, '3', _equals]),
    expression: '75*40-3',
    result: '2997',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '30 -> log -> x -> 10 -> + -> 2 -> =',
    mode: AngleMode.degree,
    actions: _steps(<Object>['30', CalculatorFunction.log, CalculatorOperation.multiply, '10', CalculatorOperation.add, '2', _equals]),
    expression: 'log(30)*10+2',
    result: '16.771212547196626',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '20 -> log -> x -> 3 -> - -> 7 -> =',
    mode: AngleMode.degree,
    actions: _steps(<Object>['20', CalculatorFunction.log, CalculatorOperation.multiply, '3', CalculatorOperation.subtract, '7', _equals]),
    expression: 'log(20)*3-7',
    result: '-3.096910013008057',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '15 -> ln -> x -> 2 -> + -> 8 -> =',
    mode: AngleMode.degree,
    actions: _steps(<Object>['15', CalculatorFunction.ln, CalculatorOperation.multiply, '2', CalculatorOperation.add, '8', _equals]),
    expression: 'ln(15)*2+8',
    result: '13.416100402204421',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '25 -> sin',
    mode: AngleMode.degree,
    actions: _steps(<Object>['25', CalculatorFunction.sin]),
    expression: 'sind(25)',
    result: '0.42261826174069944',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '25 -> cos',
    mode: AngleMode.degree,
    actions: _steps(<Object>['25', CalculatorFunction.cos]),
    expression: 'cosd(25)',
    result: '0.9063077870366499',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '25 -> tan',
    mode: AngleMode.degree,
    actions: _steps(<Object>['25', CalculatorFunction.tan]),
    expression: 'tand(25)',
    result: '0.4663076581549986',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '35 -> tan -> x -> 6 -> + -> 2 (radian mode)',
    mode: AngleMode.radian,
    actions: _steps(<Object>[
      '35', CalculatorFunction.tan, CalculatorOperation.multiply, '6', CalculatorOperation.add, '2', _equals,
    ]),
    expression: 'tan(35)*6+2',
    result: '4.842888322486706',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '25 -> sin (radian mode)',
    mode: AngleMode.radian,
    actions: _steps(<Object>['25', CalculatorFunction.sin]),
    expression: 'sin(25)',
    result: '-0.13235175009777303',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '5 -> n!',
    mode: AngleMode.degree,
    actions: _steps(<Object>['5', CalculatorFunction.factorial]),
    expression: 'fact(5)',
    result: '120',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '6 -> square root',
    mode: AngleMode.degree,
    actions: _steps(<Object>['6', CalculatorFunction.squareRoot]),
    expression: 'sqrt(6)',
    result: '2.449489742783178',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '5 -> cube root',
    mode: AngleMode.degree,
    actions: _steps(<Object>['5', CalculatorFunction.cubeRoot]),
    expression: 'cuberoot(5)',
    result: '1.709975946676697',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '48 -> x^3 -> x -> 6 -> + -> 9 -> =',
    mode: AngleMode.degree,
    actions: _steps(<Object>[
      '48', CalculatorFunction.cube, CalculatorOperation.multiply, '6', CalculatorOperation.add, '9', _equals,
    ]),
    expression: 'cube(48)*6+9',
    result: '663561',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '20 -> x^y -> 2 -> +/- -> =',
    mode: AngleMode.degree,
    actions: _steps(<Object>['20', CalculatorOperation.power, '2', _plusMinus, _equals]),
    expression: '20^-2',
    result: '0.0025',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '0 -> e^x',
    mode: AngleMode.degree,
    actions: _steps(<Object>['0', CalculatorFunction.exponential]),
    expression: 'exp(0)',
    result: '1',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: '2 -> +/- (operand sign change)',
    mode: AngleMode.degree,
    actions: _steps(<Object>['2', _plusMinus]),
    expression: '-2',
    result: '-2',
    source: ReferenceSource.specification,
  ),
  _Case(
    name: 'pi is inserted as a literal',
    mode: AngleMode.degree,
    actions: _steps(<Object>[CalculatorConstant.pi]),
    expression: 'pi',
    result: '3.141592653589793',
    source: ReferenceSource.inferred,
  ),
];

void main() {
  for (final _Case testCase in _cases) {
    test('${testCase.source.name}: ${testCase.name}', () {
      final CalculatorDriver calculator = CalculatorDriver(mode: testCase.mode)
        ..pressAll(testCase.actions);

      expect(
        calculator.expression,
        testCase.expression,
        reason: 'expression (key sequence) display',
      );
      expect(
        calculator.result,
        testCase.result,
        reason: 'numerical display',
      );
      expect(calculator.hasError, isFalse, reason: 'reference sequences never fail');
    });
  }
}