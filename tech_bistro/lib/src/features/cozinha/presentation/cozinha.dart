import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
    timer = Timer.periodic(const Duration(seconds: 20), (_) {
      _carregarPedidos();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _carregarPedidos() async {
    setState(() => carregando = true);
    final response = await supabase
        .from('pedidos')
        .select('*, pratos(*)');

    setState(() {
      pedidosPendentes = response.where((p) => p['status_pedido'] == 'pendente').toList();
      pedidosEmPreparo = response.where((p) => p['status_pedido'] == 'em_preparo').toList();
      pedidosProntos = response.where((p) => p['status_pedido'] == 'pronto').toList();
      carregando = false;
    });
  }

  Future<void> _atualizarStatusPedido(int idPedido, String novoStatus) async {
    await supabase
        .from('pedidos')
        .update({'status_pedido': novoStatus})
        .eq('id', idPedido);
    _carregarPedidos();
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
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.fastfood_rounded, color: Colors.red),
                          title: Text(prato['nome_prato'] ?? 'Prato',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'Qtd: ${pedido['qtd_pedido']}  •  Mesa: ${pedido['id_mesa']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (statusAtual == 'pendente')
                                IconButton(
                                  icon: const Icon(Icons.kitchen, color: Colors.blue),
                                  tooltip: 'Mover para Em preparo',
                                  onPressed: () => _atualizarStatusPedido(pedido['id'], 'em_preparo'),
                                ),
                              if (statusAtual == 'em_preparo')
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  tooltip: 'Mover para Pronto',
                                  onPressed: () => _atualizarStatusPedido(pedido['id'], 'pronto'),
                                ),
                            ],
                          ),
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
