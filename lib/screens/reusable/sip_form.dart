import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SipForm extends StatefulWidget {
  final Function calculateSIPWith;
  final Function resetHandler;
  final String investmentFieldTitle;
  final String percentageFieldTitle;
  const SipForm(
      {required this.calculateSIPWith,
      required this.resetHandler,
      required this.investmentFieldTitle,
      this.percentageFieldTitle = "Expected Returns %",
      super.key});

  @override
  State<SipForm> createState() => _SipFormState();
}

class _SipFormState extends State<SipForm> {
  bool isCalculated = false;
  bool monthlyInvestmentError = false;
  bool expectedReturnsError = false;
  bool periodError = false;
  String errorMessage = "";

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
      isCalculated = false;
    });

    widget.resetHandler();
  }

  void convertValuesAndCalculateSIP() {
    final monthlyInvestment = double.parse(monthlyInvestmentController.text);
    final expectedReturns = double.parse(expectedReturnController.text);
    final period = double.parse(periodController.text);

    widget.calculateSIPWith(monthlyInvestment, period, expectedReturns);
  }

  void validateSipForm() {
    bool state = true;
    FocusManager.instance.primaryFocus?.unfocus();
    if (monthlyInvestmentController.text == "") {
      setState(() {
        monthlyInvestmentError = true;
        expectedReturnsError = false;
        periodError = false;
        errorMessage = "Monthly investment field cannot be empty";
      });
      state = false;
    } else if (monthlyInvestmentController.text[0] == "0") {
      setState(() {
        monthlyInvestmentError = true;
        expectedReturnsError = false;
        periodError = false;
        errorMessage = "Invalid data";
      });
      state = false;
    } else if (expectedReturnController.text == "") {
      setState(() {
        monthlyInvestmentError = false;
        expectedReturnsError = true;
        periodError = false;
        errorMessage = "Expected returns field cannot be empty";
      });
      state = false;
    } else if (expectedReturnController.text[0] == "0") {
      setState(() {
        monthlyInvestmentError = false;
        expectedReturnsError = true;
        periodError = false;
        errorMessage = "Invalid Data";
      });
      state = false;
    } else if (periodController.text == "") {
      setState(() {
        monthlyInvestmentError = false;
        expectedReturnsError = false;
        periodError = true;
        errorMessage = "Period (Years) field cannot be empty";
      });
      state = false;
    } else if (periodController.text[0] == "0") {
      setState(() {
        monthlyInvestmentError = false;
        expectedReturnsError = false;
        periodError = true;
        errorMessage = "Invalid Data";
      });
      state = false;
    } else {
      setState(() {
        monthlyInvestmentError = false;
        expectedReturnsError = false;
        periodError = false;
      });
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (state) {
        setState(() {
          isCalculated = true;
        });
        convertValuesAndCalculateSIP();
      }
    });
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
                  Expanded(
                    flex: 1,
                    child: Text(
                      widget.investmentFieldTitle,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        controller: monthlyInvestmentController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(
                            fontSize: 15, height: 0.75, color: Colors.black),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          hintText: '',
                          labelText: '0',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (monthlyInvestmentError)
              ErrorForTextField(errorMessage: errorMessage),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        widget.percentageFieldTitle,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        controller: expectedReturnController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 15, height: 0.75, color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: '',
                          labelText: '0%',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (expectedReturnsError)
              ErrorForTextField(errorMessage: errorMessage),
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
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          validateSipForm();
                        },
                        controller: periodController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(
                            fontSize: 15, height: 0.75, color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: '',
                          labelText: '0',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (periodError) ErrorForTextField(errorMessage: errorMessage),
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
                  Visibility(
                    visible: isCalculated,
                    child: const Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.only(left: 4, right: 6, top: 8),
                        child: ElevatedButton(
                          onPressed: null,
                          child: Text("Details"),
                        ),
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
