// ignore: implementation_imports
import 'package:flutter/material.dart';
import 'package:sip_calculator/screens/emi_calculator_screen/emi_calculator_screen.dart';
import 'package:sip_calculator/screens/lumpsum_sip_screen/lumpsum_sip_screen.dart';
import 'package:sip_calculator/screens/monthly_sip_screen/monthly_sip_screen.dart';
import 'package:sip_calculator/screens/target_sip_screen/target_sip_screen.dart';
// ignore: implementation_imports

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finance Calculator"),
      ),
      body: Column(children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                CalculatorOptionCell(
                  title: "Monthly SIP",
                  tapHandler: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MonthlySipScreen(),
                      ),
                    );
                  },
                ),
                CalculatorOptionCell(
                  title: "Lumpsum SIP",
                  tapHandler: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LumpsumSipScreen(),
                      ),
                    );
                  },
                ),
                CalculatorOptionCell(
                  title: "Target SIP",
                  tapHandler: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TargetSipScreen(),
                      ),
                    );
                  },
                ),
                CalculatorOptionCell(
                  title: "EMI Calculator",
                  tapHandler: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EMICalculatorScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }
}

class CalculatorOptionCell extends StatelessWidget {
  final String title;
  final Function tapHandler;
  const CalculatorOptionCell({
    required this.title,
    required this.tapHandler,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 20,
      child: InkWell(
        onTap: () {
          tapHandler();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title),
        ),
      ),
    );
  }
}
