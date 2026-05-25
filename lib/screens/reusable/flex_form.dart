import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'input_row.dart';

// ─── Field descriptor ─────────────────────────────────────────────────────────

class FieldDef {
  /// Label shown to the left of the text field.
  final String label;
  final TextInputType keyboardType;

  /// Optional input formatters (e.g. digits-only).
  final List<TextInputFormatter>? formatters;

  /// Placeholder text shown when field is empty.
  final String placeholder;

  /// When true the field is rendered semi-transparent + non-interactive and
  /// its value is excluded from validation and the [onCalculate] callback.
  final bool isOptional;

  /// When true, a value of exactly 0 is accepted (e.g. step-up % = 0%).
  final bool allowZero;

  const FieldDef({
    required this.label,
    required this.keyboardType,
    this.formatters,
    this.placeholder = '0',
    this.isOptional = false,
    this.allowZero = false,
  });
}

// ─── FlexForm ─────────────────────────────────────────────────────────────────

/// Generic form that renders a list of [FieldDef] entries, validates them, and
/// calls [onCalculate] with a [List<double>] of values (in field-index order;
/// optional fields contribute 0).
class FlexForm extends StatefulWidget {
  final List<FieldDef> fields;
  final void Function(List<double> values) onCalculate;
  final VoidCallback onReset;

  /// Optional widget rendered above the fields (e.g. a [SegmentedButton] for
  /// mode selection in the SWP screen).
  final Widget? headerSlot;

  const FlexForm({
    required this.fields,
    required this.onCalculate,
    required this.onReset,
    this.headerSlot,
    super.key,
  });

  @override
  State<FlexForm> createState() => _FlexFormState();
}

class _FlexFormState extends State<FlexForm> {
  bool _isCalculated = false;
  late final List<TextEditingController> _controllers;
  late final List<String?> _errors;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.fields.length, (_) => TextEditingController());
    _errors = List.filled(widget.fields.length, null, growable: false);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _reset() {
    for (final c in _controllers) {
      c.clear();
    }
    setState(() {
      for (int i = 0; i < _errors.length; i++) {
        _errors[i] = null;
      }
      _isCalculated = false;
    });
    widget.onReset();
  }

  bool _validate() {
    FocusManager.instance.primaryFocus?.unfocus();
    bool isValid = true;
    final newErrors = List<String?>.filled(widget.fields.length, null);

    for (int i = 0; i < widget.fields.length; i++) {
      if (widget.fields[i].isOptional) continue;
      final text = _controllers[i].text.trim();
      if (text.isEmpty) {
        newErrors[i] = '${widget.fields[i].label} cannot be empty';
        isValid = false;
        continue;
      }
      final value = double.tryParse(text);
      if (value == null) {
        newErrors[i] = 'Please enter a valid number';
        isValid = false;
      } else if (!widget.fields[i].allowZero && value <= 0) {
        newErrors[i] = 'Must be greater than 0';
        isValid = false;
      } else if (widget.fields[i].allowZero && value < 0) {
        newErrors[i] = 'Cannot be negative';
        isValid = false;
      }
    }

    setState(() {
      for (int i = 0; i < _errors.length; i++) {
        _errors[i] = newErrors[i];
      }
    });
    return isValid;
  }

  void _calculate() {
    if (!_validate()) return;
    Future.delayed(const Duration(milliseconds: 80), () {
      setState(() => _isCalculated = true);
      final values = <double>[];
      for (int i = 0; i < widget.fields.length; i++) {
        values.add(widget.fields[i].isOptional
            ? 0
            : double.parse(_controllers[i].text.trim()));
      }
      widget.onCalculate(values);
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
            if (widget.headerSlot != null) ...[
              widget.headerSlot!,
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),
            ],
            ...List.generate(widget.fields.length, (i) {
              final field = widget.fields[i];
              final isLast = i == widget.fields.length - 1;
              return Column(
                children: [
                  if (i > 0) const SizedBox(height: 16),
                  Opacity(
                    opacity: field.isOptional ? 0.35 : 1.0,
                    child: IgnorePointer(
                      ignoring: field.isOptional,
                      child: InputRow(
                        label: field.label,
                        controller: _controllers[i],
                        error: field.isOptional ? null : _errors[i],
                        keyboardType: field.keyboardType,
                        textInputAction:
                            isLast ? TextInputAction.done : TextInputAction.next,
                        inputFormatters: field.formatters,
                        placeholder: field.placeholder,
                        onSubmitted:
                            (isLast && !field.isOptional) ? (_) => _calculate() : null,
                      ),
                    ),
                  ),
                ],
              );
            }),
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
