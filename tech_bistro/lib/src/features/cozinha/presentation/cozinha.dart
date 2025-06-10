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

  @override
  void initState() {
    super.initState();
    _carregarPedidosPendentes();
  }

  Future<void> _carregarPedidosPendentes() async {
    final response = await supabase
        .from('pedidos')
        .select('*, pratos(*)')
        .eq('status_pedido', 'pendente');

    setState(() {
      pedidosPendentes = response;
    });
  }

  Widget _buildKanbanColumn(String title, Color color, List<dynamic> pedidos) {
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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                final prato = pedido['pratos'] ?? {};
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(prato['nome_prato'] ?? 'Prato'),
                    subtitle: Text('Qtd: ${pedido['qtd_pedido']} - Mesa: ${pedido['id_mesa']}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightHalfBox(String title, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cozinha'),
        backgroundColor: const Color(0xFF840011),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildKanbanColumn(
                          'Pendentes',
                          const Color(0xFFFFE5B4),
                          pedidosPendentes,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildRightHalfBox('Bloco 1', const Color(0xFFCDEDF6)),
                      _buildRightHalfBox('Bloco 2', const Color(0xFFD0F0C0)),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: Text(
                'Tela da Cozinha',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
        },
      ),
    );
  }
}
