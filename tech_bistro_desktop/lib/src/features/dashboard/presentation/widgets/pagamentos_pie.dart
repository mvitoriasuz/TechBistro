import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PagamentosPieChart extends StatelessWidget {
  final Map<String, double> pagamentos;

  const PagamentosPieChart({super.key, required this.pagamentos});

  @override
  Widget build(BuildContext context) {
    if (pagamentos.isEmpty) {
      return const Center(child: Text("Sem dados de pagamentos"));
    }
    final total = pagamentos.values.fold(0.0, (a, b) => a + b);

    final sections = pagamentos.entries.map((entry) {
      final percent = total == 0 ? 0.0 : (entry.value / total) * 100;
      
      return PieChartSectionData(
        value: entry.value,
        title: "${percent.toStringAsFixed(1)}%",
        radius: 50,
        color: _getColorForMethod(entry.key),
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: pagamentos.entries.map((e) {
            return Chip(
              avatar: CircleAvatar(
                backgroundColor: _getColorForMethod(e.key),
                radius: 6,
              ),
              label: Text(
                "${e.key} (R\$ ${e.value.toStringAsFixed(2)})",
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.grey[100],
              padding: const EdgeInsets.all(4),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getColorForMethod(String method) {
    switch (method.toLowerCase()) {
      case 'pix': return Colors.teal;
      case 'credito': return Colors.blue[700]!;
      case 'debito': return Colors.orange[400]!;
      case 'dinheiro': return Colors.green[600]!;
      case 'voucher': return Colors.purple;
      default: return Colors.grey;
    }
  }
}