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
          .select('id, id_mesa, qtd_pedido, pratos (nome_prato), observacao_pedido, alergia_pedido, horario_finalizacao, horario_entregue')
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

  Future<void> marcarComoEntregue(int idPedido, String prato, int qtd, int mesa) async {
    const appBarColor = Color(0xFF840011);

    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmar Entrega',
            style: TextStyle(color: appBarColor),
          ),
          content: Text('Confirmar a entrega de ${qtd}x $prato da Mesa $mesa?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: appBarColor,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      try {
        await supabase
            .from('pedidos')
            .update({
              'status_pedido': 'entregue',
              'horario_entregue': DateTime.now().toIso8601String().substring(11,16), // Apenas hora e minuto
            })
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
                    final observacao = pedido['observacao_pedido'] as String?;
                    final alergia = pedido['alergia_pedido'] as String?;
                    final horarioFinalizacao = pedido['horario_finalizacao'] as String?;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: const Icon(Icons.restaurant, color: appBarColor),
                        title: Text('${qtd}x - $prato'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mesa $mesa'),
                            if (observacao != null && observacao.isNotEmpty)
                              Text('Obs: $observacao', style: const TextStyle(fontStyle: FontStyle.italic)),
                            if (alergia != null && alergia.isNotEmpty)
                              Text('Alergia: $alergia', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (horarioFinalizacao != null && horarioFinalizacao.isNotEmpty)
                              Text(
                                horarioFinalizacao,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.black87,
                                ),
                              ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.task_alt, color: Colors.green, size: 30.0),
                              tooltip: 'Marcar como entregue',
                              onPressed: () => marcarComoEntregue(pedido['id'], prato, qtd, mesa),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
