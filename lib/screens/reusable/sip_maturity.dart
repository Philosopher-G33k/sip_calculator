import 'package:flutter/material.dart';

import '../reusable/pie_chat.dart';

class SipMaturity extends StatelessWidget {
  final String sipMaturityValue;
  final String initialInvestmentAmount;
  final String estimatedReturns;

  final String title1Text;
  final String title2Text;
  final String title3Text;

  const SipMaturity(
      {required this.sipMaturityValue,
      required this.estimatedReturns,
      required this.initialInvestmentAmount,
      this.title1Text = "The total value of your investment will be",
      this.title2Text = "Invested Amount",
      this.title3Text = "Est. Returns",
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8, left: 16, right: 16),
      child: Card(
        elevation: 20,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 8, left: 16, right: 16),
              child: Text(title1Text,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 20, left: 16, right: 16),
              child: Text(
                sipMaturityValue,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            title2Text,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          initialInvestmentAmount,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            title3Text,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          estimatedReturns,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PieChartSample2(
                estimatedReturns: int.parse(estimatedReturns),
                initialInvestmentAmount: int.parse(initialInvestmentAmount),
                sipMaturityValue: int.parse(sipMaturityValue)),
          ],
        ),
      ),
    );
  }
}
