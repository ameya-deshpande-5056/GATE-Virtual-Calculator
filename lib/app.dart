import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'calculator/application/calculator_cubit.dart';
import 'calculator/presentation/calculator_page.dart';
import 'core/constants/app_constants.dart';

/// Root widget of the GATE virtual calculator.
///
/// The single [CalculatorCubit] owns all calculator state; the whole widget
/// tree below it is stateless.
class GateCalculatorApp extends StatelessWidget {
  const GateCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4286F3)),
        // The reference uses a plain sans-serif UI with tight controls.
        visualDensity: VisualDensity.compact,
      ),
      home: BlocProvider<CalculatorCubit>(
        create: (_) => CalculatorCubit(),
        child: const CalculatorPage(),
      ),
    );
  }
}