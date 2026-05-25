import 'package:flutter/material.dart';
import 'package:sip_calculator/utils/utils.dart';
import './pie_chat.dart';

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
  final bool isSwpCalculation;
  final Function scrollForFocus;

  const SipMaturity({
    required this.sipMaturityValue,
    required this.estimatedReturns,
    required this.initialInvestmentAmount,
    required this.scrollForFocus,
    this.title1Text = 'The total value of your investment will be',
    this.title2Text = 'Invested Amount',
    this.title3Text = 'Est. Returns',
    this.hint1Text = 'Initial Investment',
    this.hint2Text = 'Est. Returns',
    this.isEMICalculation = false,
    this.isSwpCalculation = false,
    super.key,
  });

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
  void didUpdateWidget(covariant SipMaturity oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.scrollForFocus();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1565C0);
    const green = Color(0xFF2E7D32);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Blue header: maturity value ───────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Column(
                children: [
                  Text(
                    widget.title1Text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    Utils().formatNumbersInt(number: widget.sipMaturityValue),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Stats row ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  _StatBox(
                    label: widget.title2Text,
                    value: Utils().formatNumbersInt(
                        number: widget.initialInvestmentAmount),
                    valueColor: primary,
                    iconColor: const Color(0xFFBBDEFB),
                    icon: Icons.savings_outlined,
                  ),
                  Container(
                    width: 1,
                    height: 52,
                    color: const Color(0xFFEEEEEE),
                  ),
                  _StatBox(
                    label: widget.title3Text,
                    value: Utils()
                        .formatNumbersInt(number: widget.estimatedReturns),
                    valueColor: green,
                    iconColor: const Color(0xFFC8E6C9),
                    icon: Icons.trending_up_rounded,
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Divider(height: 1),
            ),

            // ── Pie chart ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: PieChartSample2(
                estimatedReturns: widget.estimatedReturns,
                initialInvestmentAmount: widget.initialInvestmentAmount,
                sipMaturityValue: widget.sipMaturityValue,
                hint1Text: widget.hint1Text,
                hint2Text: widget.hint2Text,
                isEMICalculation: widget.isEMICalculation,
                isSwpCalculation: widget.isSwpCalculation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color iconColor;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: valueColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF78909C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
