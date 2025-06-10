import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'new_order.dart';

class MesaPage extends StatefulWidget {
  final int numeroMesa;

  const MesaPage({Key? key, required this.numeroMesa}) : super(key: key);

  @override
  State<MesaPage> createState() => _MesaPageState();
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
          .select('id, id_prato, qtd_pedido, observacao_pedido, status_pedido, id_mesa, pratos (nome_prato, valor_prato)')
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
        backgroundColor: appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Card com total do pedido
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(
                        'Detalhe da Mesa ${widget.numeroMesa}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Total do pedido: R\$ ${totalPedido.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Card com itens do pedido
                  Expanded(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: pedidos.isEmpty
                            ? const Center(child: Text('Nenhum pedido feito ainda.'))
                            : ListView.builder(
                                itemCount: pedidos.length,
                                itemBuilder: (context, index) {
                                  final pedido = pedidos[index];
                                  final nomePrato = pedido['pratos']?['nome_prato'] ?? 'Prato';
                                  final qtd = pedido['qtd_pedido'] ?? 0;
                                  final valorPrato = pedido['pratos']?['valor_prato'] ?? 0.0;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text('$nomePrato x$qtd - R\$ ${(valorPrato * qtd).toStringAsFixed(2)}'),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botão novo pedido
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
                        fetchPedidos(); // Atualiza os dados após novo pedido
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
