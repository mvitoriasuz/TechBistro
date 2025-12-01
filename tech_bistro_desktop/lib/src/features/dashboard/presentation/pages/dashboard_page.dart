import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/historico_mesa.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;
  List<HistoricoMesa> _dados = [];
  
  double faturamentoTotal = 0;
  int totalAtendimentos = 0;
  double ticketMedio = 0;
  List<Map<String, dynamic>> faturamentoSemanal = [];
  Map<String, double> distribuicaoPagamentos = {};
  List<Map<String, dynamic>> topPratos = [];
  List<double> fluxoHorario = List.filled(24, 0.0);

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('historico_mesas')
          .select()
          .not('data_fechamento', 'is', null)
          .order('data_fechamento', ascending: false);

      final List<dynamic> data = response;
      
      setState(() {
        _dados = data.map((json) => HistoricoMesa.fromJson(json)).toList();
        _calcularMetricas();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erro dashboard: $e");
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _calcularMetricas() {
    faturamentoTotal = 0;
    distribuicaoPagamentos = {};
    Map<String, int> contagemPratos = {};
    fluxoHorario = List.filled(24, 0.0);
    Map<int, double> diasSemana = {1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0};

    for (var mesa in _dados) {
      faturamentoTotal += mesa.valorTotal;

      for (var pg in mesa.pagamentos) {
        String metodo = pg['metodo'] ?? pg['forma_pagamento'] ?? 'Outros';
        double valor = double.tryParse((pg['valor'] ?? 0).toString()) ?? 0;
        distribuicaoPagamentos[metodo] = (distribuicaoPagamentos[metodo] ?? 0) + valor;
      }

      for (var item in mesa.itensPedido) {
        String nome = item['nome'] ?? item['produto'] ?? 'Item';
        int qtd = int.tryParse((item['quantidade'] ?? 1).toString()) ?? 1;
        contagemPratos[nome] = (contagemPratos[nome] ?? 0) + qtd;
      }

      if (mesa.dataFechamento != null) {
        fluxoHorario[mesa.dataFechamento!.hour] += 1;
        
        if (DateTime.now().difference(mesa.dataFechamento!).inDays <= 7) {
          diasSemana[mesa.dataFechamento!.weekday] = (diasSemana[mesa.dataFechamento!.weekday] ?? 0) + mesa.valorTotal;
        }
      }
    }

    totalAtendimentos = _dados.length;
    if (totalAtendimentos > 0) ticketMedio = faturamentoTotal / totalAtendimentos;

    var sortedPratos = contagemPratos.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    topPratos = sortedPratos.take(5).map((e) => {'prato': e.key, 'qtd': e.value}).toList();

    List<String> labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    faturamentoSemanal = [];
    for(int i=1; i<=7; i++) {
      faturamentoSemanal.add({'dia': labels[i-1], 'valor': diasSemana[i], 'index': i-1});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dashboard Gerencial", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            Row(
              children: [
                _kpiCard("Faturamento", currency.format(faturamentoTotal), Icons.attach_money, Colors.green),
                const SizedBox(width: 16),
                _kpiCard("Atendimentos", totalAtendimentos.toString(), Icons.people, Colors.blue),
                const SizedBox(width: 16),
                _kpiCard("Ticket Médio", currency.format(ticketMedio), Icons.receipt_long, Colors.orange),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _chartContainer("Faturamento Semanal", _buildBarChart(currency))),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _chartContainer("Pagamentos", _buildPieChart())),
              ],
            ),
             const SizedBox(height: 24),

             Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _chartContainer("Mais Vendidos", _buildTopPratos())),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _chartContainer("Fluxo por Hora", _buildLineChart())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Row(children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          ])
        ]),
      ),
    );
  }

  Widget _chartContainer(String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 300,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Expanded(child: content),
      ]),
    );
  }

  Widget _buildBarChart(NumberFormat currency) {
    double maxY = 100;
    if (faturamentoSemanal.isNotEmpty) {
      maxY = (faturamentoSemanal.map((e) => e['valor'] as double).reduce((a, b) => a > b ? a : b)) * 1.2;
    }
    if (maxY == 0) maxY = 100;

    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
            if (v.toInt() >= 0 && v.toInt() < faturamentoSemanal.length) {
              return Text(faturamentoSemanal[v.toInt()]['dia'], style: const TextStyle(fontSize: 10));
            }
            return const Text("");
        })),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      barGroups: faturamentoSemanal.map((d) => BarChartGroupData(x: d['index'], barRods: [
        BarChartRodData(toY: d['valor'], color: Colors.blueAccent, width: 14, borderRadius: BorderRadius.circular(4))
      ])).toList(),
      barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(getTooltipItem: (group, groupIndex, rod, rodIndex) {
        return BarTooltipItem(currency.format(rod.toY), const TextStyle(color: Colors.white));
      })),
    ));
  }

  Widget _buildPieChart() {
    if (distribuicaoPagamentos.isEmpty) return const Center(child: Text("Sem dados"));
    int i = 0;
    List<Color> colors = [Colors.teal, Colors.orange, Colors.purple, Colors.red];
    
    return PieChart(PieChartData(
      sections: distribuicaoPagamentos.entries.map((e) {
        final color = colors[i++ % colors.length];
        return PieChartSectionData(
          color: color, 
          value: e.value, 
          title: '',
          radius: 50,
          badgeWidget: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Text("${e.key}\n${NumberFormat.compact().format(e.value)}", style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold), textAlign: TextAlign.center)
          ),
          badgePositionPercentageOffset: 1.3
        );
      }).toList(),
      centerSpaceRadius: 30,
      sectionsSpace: 2,
    ));
  }

  Widget _buildTopPratos() {
    if (topPratos.isEmpty) return const Center(child: Text("Sem dados"));
    return ListView(
      children: topPratos.map((p) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: Colors.orange.shade100, child: Text("${p['qtd']}", style: const TextStyle(color: Colors.orange, fontSize: 12))),
        title: Text(p['prato'], style: const TextStyle(fontSize: 13)),
      )).toList(),
    );
  }

  Widget _buildLineChart() {
    List<FlSpot> spots = [];
    for(int i=0; i<fluxoHorario.length; i++) spots.add(FlSpot(i.toDouble(), fluxoHorario[i]));
    
    return LineChart(LineChartData(
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 4, getTitlesWidget: (v, m) => Text("${v.toInt()}h", style: const TextStyle(fontSize: 10)))),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      minX: 0, maxX: 23, minY: 0,
      lineBarsData: [
        LineChartBarData(spots: spots, isCurved: true, color: Colors.orange, barWidth: 3, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: Colors.orange.withOpacity(0.2))),
      ],
    ));
  }
}