import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/calculator_action.dart';
import '../domain/calculator_engine.dart';
import '../domain/calculator_state.dart';

/// Application layer: turns dispatched [CalculatorAction]s into state changes.
///
/// The cubit contains **no** mathematical logic - it only delegates to
/// [CalculatorEngine], which is pure Dart and can be tested without Flutter.
class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit({CalculatorEngine engine = const CalculatorEngine()})
      : _engine = engine,
        super(CalculatorState.initial);

  final CalculatorEngine _engine;

  /// Applies one calculator action.
  CalculatorState dispatch(CalculatorAction action) {
    final CalculatorState next = _engine.process(action, state);
    emit(next);
    return next;
  }

  /// Applies a sequence of actions (used by tests and the keyboard handler).
  void dispatchAll(Iterable<CalculatorAction> actions) {
    for (final CalculatorAction action in actions) {
      dispatch(action);
    }
  }
}
