import 'package:flutter_test/flutter_test.dart';
import 'package:gate_calculator/calculator/domain/calculator_action.dart';

import '../helpers/calculator_driver.dart';

void main() {
  group('memory', () {
    test('MS stores the displayed number and MR recalls it', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('42')
        ..memory(MemoryOperation.store);

      expect(calculator.state.memory.hasValue, isTrue);
      expect(calculator.state.memory.value, 42);

      // A new calculation keeps the register.
      calculator
        ..numbers('7')
        ..equals()
        ..clear()
        ..memory(MemoryOperation.recall);

      expect(calculator.result, '42');
    });

    test('MR is a no-op before anything has been stored', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('5')
        ..memory(MemoryOperation.recall);

      expect(calculator.result, '5');
      expect(calculator.state.memory.hasValue, isFalse);
    });

    test('MC clears the register', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('42')
        ..memory(MemoryOperation.store)
        ..memory(MemoryOperation.clear);

      expect(calculator.state.memory.hasValue, isFalse);
      expect(calculator.state.memory.value, 0);
    });

    test('M+ adds the displayed number to the register', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('10')
        ..memory(MemoryOperation.store)
        ..clear()
        ..numbers('5')
        ..memory(MemoryOperation.add);

      expect(calculator.state.memory.value, 15);
    });

    test('M- subtracts the displayed number from the register', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('10')
        ..memory(MemoryOperation.store)
        ..clear()
        ..numbers('4')
        ..memory(MemoryOperation.subtract);

      expect(calculator.state.memory.value, 6);
    });

    test('M+ / M- work without a previous MS', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('7')
        ..memory(MemoryOperation.add)
        ..clear()
        ..numbers('3')
        ..memory(MemoryOperation.subtract);

      // 0 + 7 then - 3
      expect(calculator.state.memory.value, 4);
    });

    test('memory keys leave the operand on the display', () {
      // Like most desktop calculators, `MS` does not end number entry, so a
      // following digit extends the displayed number.  `C` starts a fresh one.
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('7')
        ..memory(MemoryOperation.store);

      expect(calculator.result, '7');
      expect(calculator.state.memory.value, 7);
    });

    test('memory can be used inside an expression', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('8')
        ..memory(MemoryOperation.store)
        ..clear()
        ..numbers('3')
        ..multiply()
        ..memory(MemoryOperation.recall)
        ..equals();

      expect(calculator.expression, '3*8');
      expect(calculator.result, '24');
    });

    test('C does not clear the memory register', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('9')
        ..memory(MemoryOperation.store)
        ..clear();

      expect(calculator.state.memory.value, 9);
      expect(calculator.result, '0');
    });

    test('mode changes do not touch the memory register', () {
      final CalculatorDriver calculator = CalculatorDriver()
        ..numbers('9')
        ..memory(MemoryOperation.store);
      calculator.angleMode(calculator.state.angleMode);

      expect(calculator.state.memory.value, 9);
    });
  });
}