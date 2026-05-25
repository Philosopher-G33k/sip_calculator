import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'input_row.dart';

class SipForm extends StatefulWidget {
  final Function calculateSIPWith;
  final Function resetHandler;
  final String investmentFieldTitle;
  final String percentageFieldTitle;

  const SipForm({
    required this.calculateSIPWith,
    required this.resetHandler,
    required this.investmentFieldTitle,
    this.percentageFieldTitle = 'Expected Returns %',
    super.key,
  });

  @override
  State<SipForm> createState() => _SipFormState();
}

class _SipFormState extends State<SipForm> {
  bool _isCalculated = false;
  String? _investmentError;
  String? _returnsError;
  String? _periodError;

  final _investmentController = TextEditingController();
  final _returnsController = TextEditingController();
  final _periodController = TextEditingController();

  @override
  void dispose() {
    _investmentController.dispose();
    _returnsController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _reset() {
    _investmentController.clear();
    _returnsController.clear();
    _periodController.clear();
    setState(() {
      _investmentError = null;
      _returnsError = null;
      _periodError = null;
      _isCalculated = false;
    });
    widget.resetHandler();
  }

  bool _validate() {
    FocusManager.instance.primaryFocus?.unfocus();

    String? inv, ret, per;

    final invText = _investmentController.text.trim();
    if (invText.isEmpty) {
      inv = '${widget.investmentFieldTitle} cannot be empty';
    } else if (invText[0] == '0') {
      inv = 'Please enter a valid amount';
    }

    final retText = _returnsController.text.trim();
    if (retText.isEmpty) {
      ret = '${widget.percentageFieldTitle} cannot be empty';
    } else if (retText[0] == '0') {
      ret = 'Please enter a valid rate';
    }

    final perText = _periodController.text.trim();
    if (perText.isEmpty) {
      per = 'Period cannot be empty';
    } else if (perText[0] == '0') {
      per = 'Please enter a valid period';
    }

    setState(() {
      _investmentError = inv;
      _returnsError = ret;
      _periodError = per;
    });

    return inv == null && ret == null && per == null;
  }

  void _calculate() {
    if (!_validate()) return;
    Future.delayed(const Duration(milliseconds: 80), () {
      setState(() => _isCalculated = true);
      widget.calculateSIPWith(
        double.parse(_investmentController.text.trim()),
        double.parse(_periodController.text.trim()),
        double.parse(_returnsController.text.trim()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputRow(
              label: widget.investmentFieldTitle,
              controller: _investmentController,
              error: _investmentError,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              placeholder: '0',
            ),
            const SizedBox(height: 16),
            InputRow(
              label: widget.percentageFieldTitle,
              controller: _returnsController,
              error: _returnsError,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              placeholder: '0.0',
            ),
            const SizedBox(height: 16),
            InputRow(
              label: 'Period (Years)',
              controller: _periodController,
              error: _periodError,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              placeholder: '0',
              onSubmitted: (_) => _calculate(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    onPressed: _calculate,
                    child: const Text('Calculate'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: const Text('Reset'),
                  ),
                ),
                if (_isCalculated) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        disabledForegroundColor: Colors.black26,
                        side: const BorderSide(color: Colors.black12),
                      ),
                      child: const Text('Details'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// _InputRow has been extracted to input_row.dart as the public InputRow widget.

// Kept for any legacy references; new code uses _InputRow
class ErrorForTextField extends StatelessWidget {
  final String errorMessage;

  const ErrorForTextField({
    this.errorMessage = 'Text field cannot be empty',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        errorMessage,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }
}
