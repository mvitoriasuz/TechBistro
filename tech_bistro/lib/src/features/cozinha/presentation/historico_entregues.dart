import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoricoEntregaPage extends StatefulWidget {
  const HistoricoEntregaPage({super.key});

  @override
  State<HistoricoEntregaPage> createState() => _HistoricoEntregaPageState();
}

class _HistoricoEntregaPageState extends State<HistoricoEntregaPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> pedidosEntregues = [];
  bool carregandoHistorico = true;

  @override
  void initState() {
    super.initState();
    _carregarHistoricoEntregas();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _carregarHistoricoEntregas() async {
    setState(() => carregandoHistorico = true);
    try {
      final response = await supabase
          .from('pedidos')
          .select('id, id_mesa, qtd_pedido, pratos (nome_prato), observacao_pedido, alergia_pedido, horario_entregue')
          .eq('status_pedido', 'entregue')
          .order('id', ascending: false);

      setState(() {
        pedidosEntregues = response;
        carregandoHistorico = false;
      });
    } catch (e) {
      setState(() => carregandoHistorico = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar histórico: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color appBarColor = Color(0xFF840011);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Entregas', style: TextStyle(color: Colors.white)),
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.white,
        ),
      ),
      body: carregandoHistorico
          ? const Center(child: CircularProgressIndicator())
          : pedidosEntregues.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum pedido entregue ainda.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: pedidosEntregues.length,
                  itemBuilder: (context, index) {
                    final pedido = pedidosEntregues[index];
                    final prato = pedido['pratos']?['nome_prato'] ?? 'Prato Desconhecido';
                    final qtd = pedido['qtd_pedido'] ?? 0;
                    final mesa = pedido['id_mesa'] ?? 'Desconhecida';
                    final observacao = pedido['observacao_pedido'] as String?;
                    final alergia = pedido['alergia_pedido'] as String?;
                    final horarioEntregue = pedido['horario_entregue'] as String?;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                        title: Text('${qtd}x - $prato'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mesa: $mesa'),
                            if (observacao != null && observacao.isNotEmpty)
                              Text('Obs: $observacao', style: const TextStyle(fontStyle: FontStyle.italic)),
                            if (alergia != null && alergia.isNotEmpty)
                              Text('Alergia: $alergia', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: (horarioEntregue != null && horarioEntregue.isNotEmpty)
                            ? Text(
                                horarioEntregue,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: Colors.black54,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
