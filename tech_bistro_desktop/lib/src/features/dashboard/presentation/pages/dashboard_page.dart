import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tech_bistro_desktop/src/features/dashboard/models/dashboard_models.dart';

import '../widgets/payment_pie_chart.dart';
import '../widgets/ticket_line_chart.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/mesa_bar_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final supabase = Supabase.instance.client;
  List<HistoricoMesa> historico = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchHistorico();
  }

  /// ---------------- Fetch Supabase ---------------- ///
  Future<void> fetchHistorico() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final response = await supabase
          .from('historico_mesas')
          .select()
          .gte('data_fechamento', thirtyDaysAgo.toIso8601String())
          .order('data_fechamento', ascending: false);

      if (response is List) {
        historico = response
            .map((e) => HistoricoMesa.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Erro ao buscar histórico: $e');
    }

    setState(() => loading = false);
  }

  /// ---------------- Agregações ---------------- ///
  List<PagamentoResumo> metodosPagamento() {
    final mapa = <String, double>{};

    for (final mesa in historico) {
      final pagamentos = mesa.pagamentos;

      if (pagamentos == null || pagamentos.isEmpty) continue;

      for (final p in pagamentos) {
        final metodo = p["metodo"]?.toString() ?? "Desconhecido";

        final rawValor = p["valor"] ?? p["total"] ?? 0;
        double valor = 0;

        if (rawValor is num) {
          valor = rawValor.toDouble();
        } else if (rawValor is String) {
          valor = double.tryParse(rawValor.replaceAll(",", ".")) ?? 0;
        }

        mapa[metodo] = (mapa[metodo] ?? 0) + valor;
      }
    }

    return mapa.entries
        .map((e) => PagamentoResumo(metodo: e.key, totalValor: e.value))
        .toList();
  }

  List<double> ticketPorSemana() {
    return historico.map((m) => m.valorTotal).toList();
  }

  Map<String, int> itensPorCategoria() {
    final map = <String, int>{};

    for (var mesa in historico) {
      final itens = mesa.itensPedido ?? [];

      for (var item in itens) {
        final cat = item['categoria']?.toString() ?? 'Outros';
        final qtd = ((item['quantidade'] ?? 1) as num).toInt();
        map[cat] = (map[cat] ?? 0) + qtd;
      }
    }

    return map;
  }

  Map<int, int> pedidosPorMesa() {
    final map = <int, int>{};

    for (var mesa in historico) {
      final numero = (mesa.numeroMesa is int)
          ? mesa.numeroMesa
          : int.tryParse(mesa.numeroMesa.toString()) ?? 0;

      map[numero] = (map[numero] ?? 0) + 1;
    }

    return map;
  }

  /// ---------------- Build ---------------- ///
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DashboardCard(
              title: 'Métodos de Pagamento',
              child: SizedBox(
                height: 180,
                child: PaymentPieChart(metodosPagamento()),
              ),
            ),
            const SizedBox(height: 16),

            DashboardCard(
              title: 'Ticket Médio Semanal',
              child: SizedBox(
                height: 180,
                child: TicketLineChart(ticketPorSemana()),
              ),
            ),
            const SizedBox(height: 16),

            DashboardCard(
              title: 'Produtos por Categoria',
              child: SizedBox(
                height: 180,
                child: CategoryPieChart(itensPorCategoria()),
              ),
            ),
            const SizedBox(height: 16),

            DashboardCard(
              title: 'Pedidos por Mesa',
              child: SizedBox(
                height: 180,
                child: MesaBarChart(pedidosPorMesa()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- Dashboard Card ---------------- ///
class DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;

  const DashboardCard({Key? key, required this.title, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
