import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../application/calculator_cubit.dart';
import '../domain/calculator_action.dart';
import '../domain/calculator_state.dart';
import 'keyboard/calculator_keyboard.dart';
import 'theme/calculator_theme.dart';
import 'widgets/calculator_display.dart';
import 'widgets/calculator_keypad.dart';
import '../../../core/constants/app_constants.dart';

/// The calculator window: title bar, the two displays and the keypad.
class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  /// Width of the calculator card.  The reference window is 706 px wide, so
  /// the desktop layout keeps exactly that size while smaller screens shrink
  /// the card to the available width.
  static const double referenceWindowWidth = 706;

  /// Horizontal side padding of the reference window (24 px at full size).
  static const double sidePadding = 24;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (BuildContext context, CalculatorState state) {
        return Scaffold(
          backgroundColor: CalculatorColors.body,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double cardWidth = _cardWidth(constraints.maxWidth);
                return Center(
                  child: SingleChildScrollView(
                    child: CalculatorKeyboard(
                      onAction: context.read<CalculatorCubit>().dispatch,
                      child: _Window(
                        width: cardWidth,
                        state: state,
                        onAction: context.read<CalculatorCubit>().dispatch,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  double _cardWidth(double availableWidth) {
    final double width = availableWidth - 16;
    return width > referenceWindowWidth ? referenceWindowWidth : width;
  }
}

/// Width available to the keypad inside a card of [cardWidth].
double keypadWidthFor(double cardWidth) => cardWidth -
    2 *
        CalculatorPage.sidePadding *
        (cardWidth / CalculatorPage.referenceWindowWidth);

/// The calculator card: title bar, displays and keypad.
class _Window extends StatelessWidget {
  const _Window({
    required this.width,
    required this.state,
    required this.onAction,
  });

  final double width;
  final CalculatorState state;
  final void Function(CalculatorAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final double keypadWidth = keypadWidthFor(width);
    final CalculatorMetrics metrics = CalculatorMetrics.fromWidth(keypadWidth);
    final EdgeInsets displayPadding = EdgeInsets.symmetric(
      horizontal: metrics.pitch * 0.3,
    );

    return Container(
      width: width,
      margin: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: CalculatorColors.body,
        boxShadow: <BoxShadow>[
          BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _TitleBar(metrics: metrics),
          Padding(
            padding: displayPadding + EdgeInsets.only(bottom: metrics.gap * 1.5),
            child: CalculatorDisplay(
              expression: state.expressionText,
              result: state.resultText,
              metrics: metrics,
              errorMessage: state.errorMessage,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: metrics.pitch * 0.4),
            child: CalculatorKeypad(width: keypadWidth, onAction: onAction),
          ),
          SizedBox(height: metrics.gap * 1.5),
        ],
      ),
    );
  }
}

/// Blue title bar of the reference window with the `Help` button.
class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.metrics});

  final CalculatorMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: metrics.displayHeight * 1.05,
      color: CalculatorColors.titleBar,
      padding: EdgeInsets.symmetric(horizontal: metrics.pitch * 0.3),
      child: Row(
        children: <Widget>[
          Text(
            AppConstants.windowTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: metrics.keyFontSize * 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Semantics(
            button: true,
            label: 'help',
            child: InkWell(
              onTap: () => _showHelp(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: metrics.keyFontSize,
                  vertical: metrics.keyFontSize * 0.4,
                ),
                decoration: BoxDecoration(
                  color: CalculatorColors.helpButton,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'Help',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: metrics.keyFontSize * 0.95,
                  ),
                ),
              ),
            ),
          ),
          // Decorative window controls from the reference screenshot; they
          // have no function in a full-screen application.
          SizedBox(width: metrics.pitch * 0.3),
          Semantics(
            excludeSemantics: true,
            child: Icon(
              Icons.horizontal_rule,
              size: metrics.keyFontSize * 1.2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: metrics.pitch * 0.2),
          Semantics(
            excludeSemantics: true,
            child: Icon(
              Icons.close,
              size: metrics.keyFontSize * 1.3,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => const _HelpDialog(),
    );
  }
}

/// Offline help describing the GATE interaction model.
class _HelpDialog extends StatelessWidget {
  const _HelpDialog();

  static const List<(String, String)> _facts = <(String, String)>[
    ('Functions apply after the number',
        'Type 25 first, then press `sin` - the GATE calculator works postfix.'),
    (
      'Two displays',
      'The upper line shows the key sequence you entered, the lower line shows the value.',
    ),
    (
      'Deg / Rad',
      'The angle mode applies to sin, cos, tan and their inverses. Degrees is the default.',
    ),
    (
      'x^y and y-root',
      'Enter the base, press `x^y` (or the y-root key), then enter the exponent and press `=`.',
    ),
    ('+/-', 'Sign change works on the current operand, also inside an exponent.'),
    (
      'Memory',
      '`MS` stores the displayed value, `MR` recalls it, `M+`/`M-` add or subtract, `MC` clears.',
    ),
    ('C and <-', '`C` restarts the whole calculation, `<-` deletes the last digit.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: <Widget>[
                  Text(
                    'How this calculator works',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Scrollable middle
            Flexible(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: <Widget>[
                  for (final (String title, String body) in _facts) ...<Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(body, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}