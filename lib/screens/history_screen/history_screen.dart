import 'package:flutter/material.dart';

class CalculationHistory extends StatelessWidget {
  const CalculationHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text("History"),
      ),
      appBar: AppBar(
        title: const Text("History"),
      ),
    );
  }
}
