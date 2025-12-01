import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MesaBarChart extends StatelessWidget {
  final Map<int, int> data;

  const MesaBarChart(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final barGroups = <BarChartGroupData>[];

    data.forEach((mesa, qtd) {
      barGroups.add(
        BarChartGroupData(
          x: mesa,
          barRods: [
            BarChartRodData(toY: qtd.toDouble(), color: Colors.blue, width: 16),
          ],
        ),
      );
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (data.values.reduce((a, b) => a > b ? a : b)).toDouble() + 5,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text('M${value.toInt()}'),
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        ),
        gridData: FlGridData(show: true),
      ),
    );
  }
}
