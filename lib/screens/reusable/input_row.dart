import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared label-on-left + text-field-on-right row used by both
/// [SipForm] and [FlexForm].
class InputRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? error;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onSubmitted;
  final String placeholder;
  final bool enabled;

  const InputRow({
    required this.label,
    required this.controller,
    required this.keyboardType,
    required this.textInputAction,
    this.error,
    this.inputFormatters,
    this.onSubmitted,
    this.placeholder = '0',
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            onSubmitted: onSubmitted,
            enabled: enabled,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0A1929),
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              errorText: error,
            ),
          ),
        ),
      ],
    );
  }
}
