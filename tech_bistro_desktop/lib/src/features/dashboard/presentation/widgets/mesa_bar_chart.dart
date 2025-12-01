import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tech_bistro_desktop/src/ui/theme/app_colors.dart';
import '../../models/dashboard_models.dart';

class MesaBarChart extends StatelessWidget {
  final List<ItemVendido> topItens;

  const MesaBarChart({super.key, required this.topItens});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (topItens.isEmpty ? 10 : topItens.first.quantidade * 1.2).toDouble(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                topItens[group.x.toInt()].nome,
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
getTitlesWidget: (value, meta) {
  final index = value.toInt();
  if (index < topItens.length) {
    String nome = topItens[index].nome;
    if (nome.length > 10) {
      nome = '${nome.substring(0, 10)}...';
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Tooltip(
        message: topItens[index].nome,
        child: Text(
          nome,
          style: TextStyle(color: Colors.grey[600], fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  return const SizedBox.shrink();
},
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: topItens.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.quantidade.toDouble(),
                color: AppColors.secondary,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}