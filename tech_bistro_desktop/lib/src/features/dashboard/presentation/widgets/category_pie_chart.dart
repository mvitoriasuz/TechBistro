import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatefulWidget {
  final Map<String, double> categorias;

  const CategoryPieChart({super.key, required this.categorias});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categorias.isEmpty) {
      return const Center(child: Text("Sem dados de categoria"));
    }

    final total = widget.categorias.values.fold(0.0, (a, b) => a + b);
    final sortedEntries = widget.categorias.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        sections: sortedEntries.asMap().entries.map((e) {
          final isTouched = e.key == touchedIndex;
          final fontSize = isTouched ? 16.0 : 12.0;
          final radius = isTouched ? 65.0 : 55.0;
          final percent = total > 0 ? (e.value.value / total * 100) : 0;
          
          return PieChartSectionData(
            color: _getColor(e.key),
            value: e.value.value,
            title: isTouched 
                ? '${e.value.key}\n${percent.toStringAsFixed(1)}%' 
                : '${percent.toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getColor(int index) {
    const colors = [
      Color(0xFF840011),
      Color(0xFFA58570),
      Color(0xFF2E7D32),
      Color(0xFFF57C00),
      Color(0xFF1976D2),
      Color(0xFF7B1FA2),
    ];
    return colors[index % colors.length];
  }
}