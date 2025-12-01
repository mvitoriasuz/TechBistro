import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, int> data;

  const CategoryPieChart(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.purple, Colors.orange, Colors.teal, Colors.yellow];
    final sections = <PieChartSectionData>[];
    int i = 0;

    data.forEach((label, value) {
      sections.add(PieChartSectionData(
        value: value.toDouble(),
        color: colors[i % colors.length],
        title: '$value',
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ));
      i++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 20,
        sectionsSpace: 2,
      ),
    );
  }
}
