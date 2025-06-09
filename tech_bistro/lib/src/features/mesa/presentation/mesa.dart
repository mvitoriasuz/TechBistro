import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../new_order.dart';

class MesaPage extends StatefulWidget {
  final int numeroMesa;

  const MesaPage({Key? key, required this.numeroMesa}) : super(key: key);

  @override
  State<MesaPage> createState() => _MesaPageState();1
}

class _MesaPageState extends State<MesaPage> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  double totalPedido = 0.0;
  List<dynamic> pedidos = [];

  @override
  void initState() {
    super.initState();
    fetchPedidos();
  }

  Future<void> fetchPedidos() async {
    setState(() => loading = true);
    try {
      final response = await supabase
          .from('pedidos')
          .select('id, id_prato, qtd_pedido, observacao_pedido, status_pedido, id_mesa, pratos (valor_prato)')
          .eq('id_mesa', widget.numeroMesa);

      double soma = 0.0;
      for (var pedido in response) {
        final qtd = pedido['qtd_pedido'] ?? 0;
        final valorPrato = pedido['pratos'] != null ? (pedido['pratos']['valor_prato'] ?? 0.0) : 0.0;
        soma += (qtd * valorPrato);
      }

      setState(() {
        pedidos = response;
        totalPedido = soma;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar pedidos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color appBarColor = Color(0xFF840011);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mesa ${widget.numeroMesa}', style: const TextStyle(color: Colors.white)),
        backgroundColor: appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Total do pedido: R\$ ${totalPedido.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Itens pedidos:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        ...pedidos.map((pedido) {
                          final nomePrato = pedido['pratos']?['nome_prato'] ?? 'Prato';
                          final qtd = pedido['qtd_pedido'] ?? 0;
                          final valorPrato = pedido['pratos']?['valor_prato'] ?? 0.0;
                          return Text('$nomePrato x$qtd - R\$ ${(valorPrato * qtd).toStringAsFixed(2)}');
                        }).toList(),
                      ],
                    ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: appBarColor),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewOrder(idMesa: widget.numeroMesa),
                    ),
                  );
                  fetchPedidos();
                },
                child: const Text('Fazer novo pedido', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
