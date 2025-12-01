// presentation/widgets/faturamento_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/dashboard_models.dart';

class FaturamentoChart extends StatelessWidget {
  final List<FaturamentoPeriod> semanas;
  FaturamentoChart({Key? key, required this.semanas}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (int i = 0; i < semanas.length; i++) {
      spots.add(FlSpot(i.toDouble(), (semanas[i].total ?? 0).toDouble()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Faturamento semanal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minY: 0,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  dotData: FlDotData(show: false),
                ),
              ],
              titlesData: FlTitlesData(show: true),
            ),
          ),
        ),
      ],
    );
  }
}
