import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PaymentPieChart extends StatelessWidget {
  final Map<String, double> pagamentos;

  const PaymentPieChart({super.key, required this.pagamentos});

  @override
  Widget build(BuildContext context) {
    final total = pagamentos.values.fold(0.0, (a, b) => a + b);

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: pagamentos.entries.map((e) {
          final isLarge = total > 0 && (e.value / total > 0.2);
          final percentage = total > 0 ? (e.value / total * 100).toStringAsFixed(0) : '0';
          
          return PieChartSectionData(
            color: _getColorForMethod(e.key),
            value: e.value,
            title: '$percentage%',
            radius: isLarge ? 60 : 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getColorForMethod(String method) {
    switch (method.toLowerCase()) {
      case 'pix': return Colors.teal;
      case 'credito': return Colors.blue;
      case 'debito': return Colors.orange;
      case 'dinheiro': return Colors.green;
      default: return Colors.grey;
    }
  }
}