import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../cozinha/presentation/historico_entregues.dart';

class CozinhaPage extends StatefulWidget {
  const CozinhaPage({super.key});

  @override
  State<CozinhaPage> createState() => _CozinhaPageState();
}

class _CozinhaPageState extends State<CozinhaPage> {
  final supabase = Supabase.instance.client;

  List<dynamic> pedidosPendentes = [];
  List<dynamic> pedidosEmPreparo = [];
  List<dynamic> pedidosProntos = [];
  bool carregando = true;
  StreamSubscription<List<Map<String, dynamic>>>? _pedidosRealtimeSubscription;

  @override
  void initState() {
    super.initState();
    _loadAndListenPedidos();
  }

  @override
  void dispose() {
    _pedidosRealtimeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadAndListenPedidos() async {
    setState(() => carregando = true);
    try {
      final initialResponse = await supabase
          .from('pedidos')
          .select('*, pratos(*), observacao_pedido, alergia_pedido, horario_finalizacao');
      _updatePedidosState(initialResponse);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar pedidos iniciais: $e')),
      );
    } finally {
      setState(() => carregando = false);
    }

    _pedidosRealtimeSubscription = supabase
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) async {
          try {
            final updatedResponse = await supabase
                .from('pedidos')
                .select('*, pratos(*), observacao_pedido, alergia_pedido, horario_finalizacao');
            _updatePedidosState(updatedResponse);
            print('CozinhaPage: Dados atualizados via Realtime e refetch.');
          } catch (e) {
            print('CozinhaPage: Erro ao refetchar pedidos via stream: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao atualizar pedidos em tempo real: $e')),
            );
          }
        }, onError: (error) {
          print('CozinhaPage: Erro no listener de tempo real de pedidos: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro no stream de pedidos: $error')),
          );
        });
  }

  void _updatePedidosState(List<dynamic> allPedidos) {
    setState(() {
      pedidosPendentes = allPedidos.where((p) => p['status_pedido'] == 'pendente').toList();
      pedidosEmPreparo = allPedidos.where((p) => p['status_pedido'] == 'em_preparo').toList();
      pedidosProntos = allPedidos.where((p) => p['status_pedido'] == 'pronto').toList();
    });
  }


  Future<void> _atualizarStatusPedido(int idPedido, String novoStatus) async {
    try {
      Map<String, dynamic> updatePayload = {'status_pedido': novoStatus};
      if (novoStatus == 'pronto') {
        final now = DateTime.now();
        final timeString = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        updatePayload['horario_finalizacao'] = timeString;
      }

      await supabase
          .from('pedidos')
          .update(updatePayload)
          .eq('id', idPedido);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar pedido: $e')),
      );
    }
  }

  Widget _buildKanbanColumn(String title, Color color, List<dynamic> pedidos, String statusAtual) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: pedidos.isEmpty
                ? const Center(child: Text('Nenhum pedido'))
                : ListView.builder(
                    itemCount: pedidos.length,
                    itemBuilder: (context, index) {
                      final pedido = pedidos[index];
                      final prato = pedido['pratos'] ?? {};
                      final observacao = pedido['observacao_pedido'] as String?;
                      final alergia = pedido['alergia_pedido'] as String?;
                      final horarioFinalizacao = pedido['horario_finalizacao'] as String?;

                      Widget trailingWidget;
                      if (statusAtual == 'pronto' && horarioFinalizacao != null && horarioFinalizacao.isNotEmpty) {
                        trailingWidget = Text(
                          horarioFinalizacao,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                        );
                      } else if (statusAtual == 'pendente') {
                        trailingWidget = IconButton(
                          icon: const Icon(Icons.kitchen, color: Colors.blue, size: 36.0),
                          tooltip: 'Mover para Em preparo',
                          onPressed: () => _atualizarStatusPedido(pedido['id'], 'em_preparo'),
                        );
                      } else if (statusAtual == 'em_preparo') {
                        trailingWidget = IconButton(
                          icon: const Icon(Icons.bakery_dining_rounded, color: Colors.green, size: 36.0),
                          tooltip: 'Mover para Pronto',
                          onPressed: () => _atualizarStatusPedido(pedido['id'], 'pronto'),
                        );
                      } else {
                        trailingWidget = const SizedBox.shrink();
                      }

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.fastfood_rounded, color: Colors.red),
                          title: Text(prato['nome_prato'] ?? 'Prato',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Qtd: ${pedido['qtd_pedido']}  •  Mesa: ${pedido['id_mesa']}'),
                              if (observacao != null && observacao.isNotEmpty)
                                Text('Obs: $observacao', style: const TextStyle(fontStyle: FontStyle.italic)),
                              if (alergia != null && alergia.isNotEmpty)
                                Text('Alergia: $alergia', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          trailing: trailingWidget,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayout({required bool isLandscape}) {
    if (isLandscape) {
      return Row(
        children: [
          Expanded(
            child: _buildKanbanColumn(
              'Pendentes',
              const Color(0xFFFFE5B4),
              pedidosPendentes,
              'pendente',
            ),
          ),
          Expanded(
            child: _buildKanbanColumn(
              'Em preparo',
              const Color(0xFFCDEDF6),
              pedidosEmPreparo,
              'em_preparo',
            ),
          ),
          Expanded(
            child: _buildKanbanColumn(
              'Prontos',
              const Color(0xFFD0F0C0),
              pedidosProntos,
              'pronto',
            ),
          ),
        ],
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 400,
              child: _buildKanbanColumn(
                'Pendentes',
                const Color(0xFFFFE5B4),
                pedidosPendentes,
                'pendente',
              ),
            ),
            SizedBox(
              height: 400,
              child: _buildKanbanColumn(
                'Em preparo',
                const Color(0xFFCDEDF6),
                pedidosEmPreparo,
                'em_preparo',
              ),
            ),
            SizedBox(
              height: 400,
              child: _buildKanbanColumn(
                'Prontos',
                const Color(0xFFD0F0C0),
                pedidosProntos,
                'pronto',
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cozinha', style: TextStyle(color: Colors.white, fontFamily: 'Nats')),
        backgroundColor: const Color(0xFF840011),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoricoEntregaPage()),
              );
            },
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : OrientationBuilder(
              builder: (context, orientation) {
                return _buildLayout(isLandscape: orientation == Orientation.landscape);
              },
            ),
    );
  }
}
