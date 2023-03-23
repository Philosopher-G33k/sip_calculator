import 'package:flutter/material.dart';
import '../history_screen/history_screen.dart';
import './sip_form.dart';

class MonthlySipScreen extends StatefulWidget {
  const MonthlySipScreen({super.key});

  @override
  State<MonthlySipScreen> createState() => _MonthlySipScreenState();
}

class _MonthlySipScreenState extends State<MonthlySipScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sip Calculator"),
      ),
      body: Center(
        child: Column(
          children: [
            const SipForm(),
            TextButton(
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalculationHistory()),
                ),
              },
              child: const Text("History"),
            )
          ],
        ),
      ),
    );
  }
}
