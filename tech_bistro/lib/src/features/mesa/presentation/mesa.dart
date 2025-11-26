import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techbistro/src/constants/app_colors.dart';
import 'package:techbistro/src/features/salao/presentation/salao.dart';
import 'new_order.dart';

class MesaPage extends StatefulWidget {
  final int numeroMesa;

  const MesaPage({super.key, required this.numeroMesa});

  @override
  State<MesaPage> createState() => _MesaPageState();
}

class _MesaPageState extends State<MesaPage> {
  final supabase = Supabase.instance.client;

  final Color primaryRed = const Color(0xFF840011);
  final Color backgroundApp = const Color(0xFFF8F9FA);
  final Color successGreen = const Color(0xFF2E7D32);
  final Color darkText = const Color(0xFF2D2D2D);

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

      if (mounted) {
        setState(() {
          pedidos = response;
          totalPedido = soma;
          totalPago = somaPagamentos;
          loading = false;
        });
      }

      if ((totalPedido - totalPago).abs() < 0.01 && totalPedido > 0) {
        _showCloseTableDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar pedidos: $e'), backgroundColor: primaryRed),
        );
      }
    }
  }

  Future<void> _showCloseTableDialog() async {
    final bool? confirmClose = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: successGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_outline, size: 40, color: successGreen),
                ),
                const SizedBox(height: 20),
                Text(
                  'Conta Finalizada',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nats',
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Todos os pagamentos foram efetuados.\nDeseja liberar a Mesa ${widget.numeroMesa}?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Manter Aberta', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('FECHAR MESA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SalaoPage()),
          (Route<dynamic> route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mesa ${widget.numeroMesa} fechada com sucesso!'), backgroundColor: successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fechar mesa: $e'), backgroundColor: primaryRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final valorRestante = totalPedido - totalPago;
    final percentualPago = totalPedido > 0 ? totalPago / totalPedido : 0.0;

    return Scaffold(
      backgroundColor: backgroundApp,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mesa ${widget.numeroMesa}',
                style: TextStyle(
                  color: primaryRed,
                  fontFamily: 'Nats',
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                ),
              ),
              Text(
                'Gerenciamento de pedidos',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'Nats',
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: primaryRed, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: primaryRed))
          : Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryRed,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryRed.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Consumido',
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'R\$ ${totalPedido.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Nats',
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatusValue('Já Pago', totalPago, Colors.greenAccent),
                                Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
                                _buildStatusValue('A Pagar', valorRestante, Colors.white),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: percentualPago.clamp(0.0, 1.0),
                                backgroundColor: Colors.white.withOpacity(0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                          child: Text(
                            'Pedidos da Mesa',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nats',
                              color: darkText,
                            ),
                          ),
                        ),
                        Expanded(
                          child: pedidos.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.restaurant_menu_rounded, size: 60, color: Colors.grey[300]),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Nenhum pedido realizado.',
                                        style: TextStyle(color: Colors.grey[400], fontFamily: 'Nats', fontSize: 18),
                                      ),
                                    ],
                                  ),
                                )
                              : _buildPedidosList(),
                        ),
                        
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewOrder(idMesa: widget.numeroMesa),
                                      ),
                                    );
                                    fetchPedidos();
                                  },
                                  icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                                  label: const Text(
                                    'NOVO PEDIDO',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryRed,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: OutlinedButton.icon(
                                  onPressed: () => _showPaymentDialog(valorRestante),
                                  icon: Icon(Icons.attach_money_rounded, color: primaryRed),
                                  label: Text(
                                    'REALIZAR PAGAMENTO',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: primaryRed,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: primaryRed, width: 2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusValue(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
        Text(
          'R\$ ${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nats',
          ),
        ),
      ],
    );
  }

  Widget _buildPedidosList() {
    final Map<String, dynamic> pedidosAgrupados = {};
    
    for (var pedido in pedidos) {
      final nomePrato = pedido['pratos']?['nome_prato'] ?? 'Prato';
      final qtd = pedido['qtd_pedido'] ?? 0;
      final valorPrato = (pedido['pratos']?['valor_prato'] as num? ?? 0.0).toDouble();
      final totalItem = qtd * valorPrato;

      if (pedidosAgrupados.containsKey(nomePrato)) {
        pedidosAgrupados[nomePrato]['qtd'] += qtd;
        pedidosAgrupados[nomePrato]['total'] += totalItem;
      } else {
        pedidosAgrupados[nomePrato] = {'qtd': qtd, 'total': totalItem};
      }
    }

    final lista = pedidosAgrupados.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final item = lista[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundApp,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${item.value['qtd']}x',
                  style: TextStyle(
                    color: primaryRed,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nats',
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.key,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Nats',
                    color: darkText,
                  ),
                ),
              ),
              Text(
                'R\$ ${item.value['total'].toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Nats',
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentDialog(double valorPendente) {
    final TextEditingController valorController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.payments_rounded, size: 32, color: primaryRed),
                ),
                const SizedBox(height: 20),
                Text(
                  'Registrar Pagamento',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nats',
                    color: primaryRed,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Falta pagar: R\$ ${valorPendente.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: valorController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: 'R\$ ',
                    filled: true,
                    fillColor: backgroundApp,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  validator: (value) {
                    final parsed = double.tryParse(value?.replaceAll(',', '.') ?? '');
                    if (parsed == null || parsed <= 0) return 'Valor inválido';
                    if (parsed > valorPendente + 0.01) return 'Valor excede o restante';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: Text('Cancelar', style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final valor = double.parse(valorController.text.replaceAll(',', '.'));
                          Navigator.pop(context);
                          await _processPayment(valor);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: const Text('CONFIRMAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment(double valor) async {
    try {
      await supabase.from('pagamento').insert({
        'id_mesa': widget.numeroMesa,
        'valor_pagamento': valor,
      });
      await fetchPedidos();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pagamento de R\$ ${valor.toStringAsFixed(2)} registrado!'),
            backgroundColor: successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar: $e'), backgroundColor: primaryRed),
        );
      }
    }
  }
}