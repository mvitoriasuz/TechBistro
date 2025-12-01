import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/dashboard_models.dart';

class PagamentoPie extends StatelessWidget {
  final List<PagamentoResumo> resumo;

  const PagamentoPie({Key? key, required this.resumo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = resumo.fold<double>(
      0.0,
      (p, e) => p + e.totalValor,
    );

    final sections = resumo.map((r) {
      final percent = total == 0 ? 0.0 : (r.totalValor / total) * 100;
      return PieChartSectionData(
        value: r.totalValor,
        title: "${percent.toStringAsFixed(1)}%",
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métodos de pagamento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 30,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: resumo
              .map((r) => Chip(
                    label: Text(
                      "${r.metodo} — R\$ ${r.totalValor.toStringAsFixed(2)}",
                    ),
                  ))
              .toList(),
        )
      ],
    );
  }
}
