// ignore: implementation_imports
import 'package:flutter/material.dart';
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
              children: const [
                CalculatorOptionCell(title: "Monthly SIP"),
                CalculatorOptionCell(title: "Lumpsum SIP"),
                CalculatorOptionCell(title: "Target SIP"),
                CalculatorOptionCell(title: "EMI Calculator"),
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
  const CalculatorOptionCell({
    required this.title,
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
          print("Clicked");
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title),
        ),
      ),
    );
  }
}
