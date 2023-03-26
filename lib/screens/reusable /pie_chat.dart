import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import './indicator.dart';

class PieChartSample2 extends StatefulWidget {
  final int sipMaturityValue;
  final int initialInvestmentAmount;
  final int estimatedReturns;

  const PieChartSample2(
      {required this.sipMaturityValue,
      required this.initialInvestmentAmount,
      required this.estimatedReturns,
      super.key});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 18,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 35,
                  sections: showingSections(
                      estimatedReturns: widget.estimatedReturns,
                      initialInvestment: widget.initialInvestmentAmount,
                      sipMaturityAmout: widget.sipMaturityValue),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Indicator(
                color: Colors.blue,
                text: 'Initial Investment',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: Colors.yellow,
                text: 'Est. Returns',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
            ],
          ),
          const SizedBox(
            width: 5,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(
      {required int sipMaturityAmout,
      required int initialInvestment,
      required int estimatedReturns}) {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.blue,
            value: (initialInvestment / sipMaturityAmout) * 100,
            title: '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.yellow,
            value: (estimatedReturns / sipMaturityAmout) * 100,
            title: '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
