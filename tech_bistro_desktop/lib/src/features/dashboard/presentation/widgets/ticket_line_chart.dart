import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TicketLineChart extends StatelessWidget {
  final List<double> data;

  const TicketLineChart(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i]));

    return LineChart(
      LineChartData(
        minY: 0,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text('D${value.toInt() + 1}'),
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
