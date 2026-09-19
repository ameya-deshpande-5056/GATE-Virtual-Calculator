import 'package:meta/meta.dart';

/// Memory register of the calculator.
///
/// Memory is session state only - the reference calculator does not persist it
/// between launches, so it is never written to disk.
@immutable
class MemoryState {
  const MemoryState({this.value = 0, this.hasValue = false});

  /// Cleared memory: nothing stored, `MR` is a no-op.
  static const MemoryState empty = MemoryState();

  /// Stored number.
  final double value;

  /// Whether something has been stored.  The reference calculator has no `M`
  /// indicator on screen, but the flag is kept so `MR` can be a no-op before
  /// the first `MS`/`M+`/`M-` (see `KNOWN_DIFFERENCES.md`).
  final bool hasValue;

  MemoryState store(double newValue) =>
      MemoryState(value: newValue, hasValue: true);

  MemoryState add(double operand) =>
      MemoryState(value: value + operand, hasValue: true);

  MemoryState subtract(double operand) =>
      MemoryState(value: value - operand, hasValue: true);

  MemoryState clear() => MemoryState.empty;

  @override
  bool operator ==(Object other) =>
      other is MemoryState && other.value == value && other.hasValue == hasValue;

  @override
  int get hashCode => Object.hash(value, hasValue);

  @override
  String toString() => 'MemoryState(value: $value, hasValue: $hasValue)';
}
