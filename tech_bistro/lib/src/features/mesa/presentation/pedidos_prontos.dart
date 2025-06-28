import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PedidosProntosPage extends StatefulWidget {
  const PedidosProntosPage({super.key});

  @override
  State<PedidosProntosPage> createState() => _PedidosProntosPageState();
}

class _PedidosProntosPageState extends State<PedidosProntosPage> {
  final supabase = Supabase.instance.client;

  List<dynamic> pedidosProntos = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarPedidos();
  }

  Future<void> carregarPedidos() async {
    setState(() => carregando = true);

    try {
      final response = await supabase
          .from('pedidos')
          .select('id, id_mesa, qtd_pedido, pratos (nome_prato)')
          .eq('status_pedido', 'pronto')
          .order('id', ascending: true);

      setState(() {
        pedidosProntos = response;
        carregando = false;
      });
    } catch (e) {
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar pedidos: $e')),
      );
    }
  }

  Future<void> marcarComoEntregue(int idPedido) async {
    try {
      await supabase
          .from('pedidos')
          .update({'status_pedido': 'entregue'})
          .eq('id', idPedido);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido marcado como entregue')),
      );

      carregarPedidos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar pedido: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color(0xFF840011);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos Prontos',
            style: TextStyle(color: Colors.white, fontFamily: 'Nats')),
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.white,
        ),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : pedidosProntos.isEmpty
              ? const Center(child: Text('Nenhum pedido pronto no momento.'))
              : ListView.builder(
                  itemCount: pedidosProntos.length,
                  itemBuilder: (context, index) {
                    final pedido = pedidosProntos[index];
                    final prato = pedido['pratos']?['nome_prato'] ?? 'Prato';
                    final qtd = pedido['qtd_pedido'] ?? 0;
                    final mesa = pedido['id_mesa'];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: const Icon(Icons.restaurant, color: appBarColor),
                        title: Text('${qtd}x - $prato'),
                        subtitle: Text('Mesa $mesa'),
                        trailing: IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          tooltip: 'Marcar como entregue',
                          onPressed: () => marcarComoEntregue(pedido['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
