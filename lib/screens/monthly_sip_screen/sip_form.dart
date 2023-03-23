import 'package:flutter/material.dart';

class SipForm extends StatefulWidget {
  const SipForm({super.key});

  @override
  State<SipForm> createState() => _SipFormState();
}

class _SipFormState extends State<SipForm> {
  final bool isCalculated = false;
  bool monthlyInvestmentError = false;
  bool expectedReturnsError = false;
  bool periodError = false;

  final monthlyInvestmentController = TextEditingController();
  final expectedReturnController = TextEditingController();
  final periodController = TextEditingController();

  void resetHandler() {
    monthlyInvestmentController.text = "";
    expectedReturnController.text = "";
    periodController.text = "";

    setState(() {
      monthlyInvestmentError = false;
      expectedReturnsError = false;
      periodError = false;
    });
  }

  bool validateSipForm() {
    bool state = true;

    if (monthlyInvestmentController.text == "") {
      print("Monthly investment empty");
      setState(() {
        monthlyInvestmentError = true;
        expectedReturnsError = false;
        periodError = false;
      });
      state = false;
    } else if (expectedReturnController.text == "") {
      print("Expected return empty");
      setState(() {
        monthlyInvestmentError = false;
        expectedReturnsError = true;
        periodError = false;
      });
      state = false;
    } else if (periodController.text == "") {
      print("Period empty");
      setState(() {
        monthlyInvestmentError = false;
        expectedReturnsError = false;
        periodError = true;
      });
      state = false;
    } else {
      setState(() {
        monthlyInvestmentError = false;
        expectedReturnsError = false;
        periodError = false;
      });
    }

    return state;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    monthlyInvestmentController.dispose();
    expectedReturnController.dispose();
    periodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8, left: 16, right: 16),
      child: Card(
        elevation: 20,
        borderOnForeground: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Text(
                      "Monthly Investment",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: TextField(
                        controller: monthlyInvestmentController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                            fontSize: 15, height: 0.75, color: Colors.black),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          hintText: '0',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (monthlyInvestmentError)
              const ErrorForTextField(
                  errorMessage: "Monthly investment field cannot be empty"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text(
                        "Expected Returns %",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: TextField(
                        controller: expectedReturnController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 15, height: 0.75, color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: '0%',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (expectedReturnsError)
              const ErrorForTextField(
                  errorMessage: "Expected returns field cannot be empty"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text(
                        "Period (Years)",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: TextField(
                        controller: periodController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 15, height: 0.75, color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: '0',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (periodError)
              const ErrorForTextField(
                  errorMessage: "Period (Years) field cannot be empty"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6, right: 4, top: 8),
                      child: ElevatedButton(
                        onPressed: () => {validateSipForm()},
                        child: const Text(
                          "Calculate",
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4, top: 8),
                      child: ElevatedButton(
                        onPressed: () => {resetHandler()},
                        child: const Text(
                          "Reset",
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: 4, right: 6, top: 8),
                      child: ElevatedButton(
                        onPressed: null,
                        child: Text("Details"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorForTextField extends StatelessWidget {
  final String errorMessage;

  const ErrorForTextField({
    this.errorMessage = "Text field cannot be empty",
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 4, right: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.end,
        ),
      ),
    );
  }
}
