import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/dashboard_models.dart'; // ou onde PagamentoResumo está

class PaymentPieChart extends StatelessWidget {
  final List<PagamentoResumo> data;

  const PaymentPieChart(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sections = data.map((p) {
      return PieChartSectionData(
        value: p.totalValor,
        title: '${p.metodo}\n${p.totalValor.toStringAsFixed(2)}',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
