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

  /// Width of the calculator card. The reference window is 1109 px wide, so
  /// the desktop layout keeps exactly that size while smaller screens shrink
  /// the card to the available width.
  static const double referenceWindowWidth = 1109;

  /// Horizontal side padding of the reference window (24 px at full size).
  static const double sidePadding = 25;

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
double keypadWidthFor(double cardWidth) =>
    cardWidth -
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
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _TitleBar(metrics: metrics),
          SizedBox(height: metrics.gap * 1.5),
          Padding(
            padding:
                displayPadding + EdgeInsets.only(bottom: metrics.gap * 1.5),
            child: CalculatorDisplay(
              expression: state.expressionText,
              result: state.resultText,
              metrics: metrics,
              errorMessage: state.errorMessage,
            ),
          ),
          CalculatorKeypad(
            width: keypadWidth,
            angleMode: state.angleMode,
            onAction: onAction,
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
    (
      'Functions apply after the number',
      'Type 25 first, then press sin. This calculator applies functions in postfix order.',
    ),
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
      'Enter the base, press xʸ (or the y-root key), enter the exponent, then press =.',
    ),
    ('+⁄−', 'Changes the sign of the current operand, including an exponent.'),
    (
      'Memory',
      'MS stores the displayed value, MR recalls it, M+ and M− add or subtract, and MC clears it.',
    ),
    (
      'C and ←',
      'C restarts the calculation. The backspace arrow deletes the last digit.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 600),
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
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: <Widget>[
                  Text(
                    'Enter values, choose an operation, and read the result in the lower display.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (final (String title, String body) in _facts) ...<Widget>[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            body,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.35),
                          ),
                        ],
                      ),
                    ),
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
