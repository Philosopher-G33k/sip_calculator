import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import './indicator.dart';

const _kChartBlue = Color(0xFF1976D2);
const _kChartGreen = Color(0xFF43A047);

class PieChartSample2 extends StatefulWidget {
  final int sipMaturityValue;
  final int initialInvestmentAmount;
  final int estimatedReturns;
  final String hint1Text;
  final String hint2Text;
  final bool isEMICalculation;

  /// When true the chart shows SWP ratios:
  ///   section 0 (blue)  = totalWithdrawn  / initialCorpus
  ///   section 1 (green) = remainingCorpus / initialCorpus
  /// Caller maps: sipMaturityValue=remaining, initialInvestmentAmount=withdrawn,
  ///              estimatedReturns=initialCorpus.
  final bool isSwpCalculation;

  const PieChartSample2({
    required this.sipMaturityValue,
    required this.initialInvestmentAmount,
    required this.estimatedReturns,
    this.hint1Text = 'Initial Investment',
    this.hint2Text = 'Est. Returns',
    this.isEMICalculation = false,
    this.isSwpCalculation = false,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _PieChart2State();
}

class _PieChart2State extends State<PieChartSample2> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.4,
      child: Row(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _buildSections(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Indicator(
                color: _kChartBlue,
                text: widget.hint1Text,
                isSquare: false,
              ),
              const SizedBox(height: 8),
              Indicator(
                color: _kChartGreen,
                text: widget.hint2Text,
                isSquare: false,
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return List.generate(2, (i) {
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 58.0 : 50.0;
      final fontSize = isTouched ? 14.0 : 0.0;

      switch (i) {
        // Section 0 — blue
        case 0:
          final double value;
          if (widget.isSwpCalculation) {
            // withdrawn / initialCorpus
            final denom = widget.estimatedReturns == 0 ? 1 : widget.estimatedReturns;
            value = (widget.initialInvestmentAmount / denom) * 100;
          } else if (widget.isEMICalculation) {
            final denom = widget.estimatedReturns == 0 ? 1 : widget.estimatedReturns;
            value = ((widget.estimatedReturns - widget.initialInvestmentAmount) / denom) * 100;
          } else {
            final denom = widget.sipMaturityValue == 0 ? 1 : widget.sipMaturityValue;
            value = (widget.initialInvestmentAmount / denom) * 100;
          }
          return PieChartSectionData(
            color: _kChartBlue,
            value: value.clamp(0, 100),
            title: '${value.clamp(0, 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );

        // Section 1 — green
        case 1:
          final double value;
          if (widget.isSwpCalculation) {
            // remaining / initialCorpus
            final denom = widget.estimatedReturns == 0 ? 1 : widget.estimatedReturns;
            value = (widget.sipMaturityValue / denom) * 100;
          } else if (widget.isEMICalculation) {
            final denom = widget.estimatedReturns == 0 ? 1 : widget.estimatedReturns;
            value = (widget.initialInvestmentAmount / denom) * 100;
          } else {
            final denom = widget.sipMaturityValue == 0 ? 1 : widget.sipMaturityValue;
            value = (widget.estimatedReturns / denom) * 100;
          }
          return PieChartSectionData(
            color: _kChartGreen,
            value: value.clamp(0, 100),
            title: '${value.clamp(0, 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );

        default:
          throw Error();
      }
    });
  }
}
