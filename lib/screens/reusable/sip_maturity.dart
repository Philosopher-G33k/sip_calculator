import 'package:flutter/material.dart';
import 'package:sip_calculator/utils/utils.dart';

import '../reusable/pie_chat.dart';

class SipMaturity extends StatefulWidget {
  final int sipMaturityValue;
  final int initialInvestmentAmount;
  final int estimatedReturns;

  final String title1Text;
  final String title2Text;
  final String title3Text;

  final String hint1Text;
  final String hint2Text;

  final bool isEMICalculation;

  final Function scrollForFocus;

  const SipMaturity(
      {required this.sipMaturityValue,
      required this.estimatedReturns,
      required this.initialInvestmentAmount,
      required this.scrollForFocus,
      this.title1Text = "The total value of your investment will be",
      this.title2Text = "Invested Amount",
      this.title3Text = "Est. Returns",
      this.hint1Text = "Initial Investment",
      this.hint2Text = "Est. Returns",
      this.isEMICalculation = false,
      super.key});

  @override
  State<SipMaturity> createState() => _SipMaturityState();
}

class _SipMaturityState extends State<SipMaturity> {
  @override
  void initState() {
    super.initState();
    widget.scrollForFocus();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget as SipMaturity);
    widget.scrollForFocus();
  }

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
              child: Text(widget.title1Text,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 20, left: 16, right: 16),
              child: Text(
                Utils().formatNumbersInt(number: widget.sipMaturityValue),
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
                            widget.title2Text,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          Utils().formatNumbersInt(
                              number: widget.initialInvestmentAmount),
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
                            widget.title3Text,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          Utils().formatNumbersInt(
                              number: widget.estimatedReturns),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            widget.isEMICalculation
                // If true we need to send the calculations too
                ? PieChartSample2(
                    estimatedReturns: widget.estimatedReturns,
                    initialInvestmentAmount: widget.initialInvestmentAmount,
                    sipMaturityValue: widget.sipMaturityValue,
                    hint1Text: widget.hint1Text,
                    hint2Text: widget.hint2Text,
                    isEMICalculation: widget.isEMICalculation,
                  )
                : PieChartSample2(
                    estimatedReturns: widget.estimatedReturns,
                    initialInvestmentAmount: widget.initialInvestmentAmount,
                    sipMaturityValue: widget.sipMaturityValue,
                    hint1Text: widget.hint1Text,
                    hint2Text: widget.hint2Text,
                  ),
          ],
        ),
      ),
    );
  }
}
