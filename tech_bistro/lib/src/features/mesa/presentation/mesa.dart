import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techbistro/src/ui/theme/app_colors.dart';
import 'new_order.dart';

class MesaPage extends StatefulWidget {
  final int numeroMesa;

  const MesaPage({super.key, required this.numeroMesa});

  @override
  State<MesaPage> createState() => _MesaPageState();
}

class _MesaPageState extends State<MesaPage> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  double totalPedido = 0.0;
  double totalPago = 0.0;
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
          .select(
            'id, id_prato, qtd_pedido, observacao_pedido, status_pedido, id_mesa, pratos (nome_prato, valor_prato)',
          )
          .eq('id_mesa', widget.numeroMesa);

      double soma = 0.0;
      for (var pedido in response) {
        final qtd = pedido['qtd_pedido'] ?? 0;
        final valorPrato = (pedido['pratos']?['valor_prato'] as num? ?? 0.0).toDouble();
        soma += (qtd * valorPrato);
      }

      final pagamentosResponse = await supabase
          .from('pagamento')
          .select('valor_pagamento')
          .eq('id_mesa', widget.numeroMesa);

      double somaPagamentos = 0.0;
      for (var pagamento in pagamentosResponse) {
        somaPagamentos += (pagamento['valor_pagamento'] as num? ?? 0.0).toDouble();
      }

      setState(() {
        pedidos = response;
        totalPedido = soma;
        totalPago = somaPagamentos;
        loading = false;
      });

      if ((totalPedido - totalPago).abs() < 0.01 && totalPedido > 0) {
        _showCloseTableDialog();
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar pedidos: $e')));
    }
  }

  Future<void> _showCloseTableDialog() async {
    final bool? confirmClose = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        const appBarColor = Color(0xFF840011);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Pagamento Finalizado!',
            style: TextStyle(
              color: appBarColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nats',
            ),
          ),
          content: const Text(
            'Todos os pagamentos foram efetuados. Deseja fechar a mesa?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: appBarColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Fechar Mesa',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmClose == true) {
      _performCloseTable();
    }
  }

  Future<void> _performCloseTable() async {
    try {
      await supabase.from('pagamento').delete().eq('id_mesa', widget.numeroMesa);
      await supabase.from('pedidos').delete().eq('id_mesa', widget.numeroMesa);
      await supabase.from('mesas').delete().eq('numero', widget.numeroMesa);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mesa ${widget.numeroMesa} fechada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fechar mesa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color appBarColor = Color(0xFF840011);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.white,
        ),
        title: Text(
          'Mesa ${widget.numeroMesa}',
          style: const TextStyle(color: Colors.white, fontFamily: 'Nats'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              print('Botão de Notificação da Mesa Pressionado!');
            },
            color: Colors.white,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: appBarColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DETALHE DA MESA ${widget.numeroMesa}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                fontFamily: 'Nats',
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'VALOR TOTAL: R\$ ${totalPedido.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'Nats',
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'PAGAMENTO PARCIAL: R\$ ${totalPago.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'Nats',
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'VALOR A PAGAR: R\$ ${(totalPedido - totalPago).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'Nats',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Histórico',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                fontFamily: 'Nats',
                                color: appBarColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: pedidos.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Nenhum pedido feito ainda.',
                                      ),
                                    )
                                  : Builder(
                                      builder: (context) {
                                        final Map<String, dynamic>
                                            pedidosAgrupados = {};
                                        for (var pedido in pedidos) {
                                          final nomePrato =
                                              pedido['pratos']?['nome_prato'] ??
                                                  'Prato';
                                          final qtd =
                                              pedido['qtd_pedido'] ?? 0;
                                          final valorPrato =
                                              (pedido['pratos']?['valor_prato'] as num? ?? 0.0).toDouble();
                                          final totalPedidoItem =
                                              qtd * valorPrato;

                                          if (pedidosAgrupados.containsKey(
                                              nomePrato)) {
                                            pedidosAgrupados[nomePrato]['qtd'] +=
                                                qtd;
                                            pedidosAgrupados[nomePrato]['total'] +=
                                                totalPedidoItem;
                                          } else {
                                            pedidosAgrupados[nomePrato] = {
                                              'qtd': qtd,
                                              'total': totalPedidoItem,
                                            };
                                          }
                                        }
                                        final pedidosList =
                                            pedidosAgrupados.entries.toList();

                                        return ListView.builder(
                                          itemCount: pedidosList.length,
                                          itemBuilder: (context, index) {
                                            final pedido = pedidosList[index];
                                            return ListTile(
                                              title: Text(
                                                '${pedido.value['qtd']}x - ${pedido.key}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Nats',
                                                ),
                                              ),
                                              trailing: Text(
                                                'R\$ ${pedido.value['total'].toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'Nats',
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NewOrder(idMesa: widget.numeroMesa),
                          ),
                        );
                        fetchPedidos();
                      },
                      child: const Text(
                        'Fazer novo pedido',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final TextEditingController valorController =
                                TextEditingController();
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: const Text('Pagamento'),
                              content: SizedBox(
                                height: 100,
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: valorController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'Valor pago',
                                        prefixIcon: Icon(Icons.attach_money),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: appBarColor,
                                        ),
                                        onPressed: () async {
                                          final valor = double.tryParse(
                                                  valorController.text
                                                      .replaceAll(',', '.')) ??
                                              0.0;

                                          if (valor <= 0) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Por favor, insira um valor válido.'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          Navigator.pop(context);

                                          try {
                                            await supabase
                                                .from('pagamento')
                                                .insert({
                                                  'id_mesa': widget.numeroMesa,
                                                  'valor_pagamento': valor,
                                                });

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Pagamento de R\$ ${valor.toStringAsFixed(2)} registrado com sucesso.',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );

                                            await fetchPedidos();
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Erro ao registrar pagamento: $e',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Efetivar Pagamento',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text(
                        'Realizar Pagamento',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
