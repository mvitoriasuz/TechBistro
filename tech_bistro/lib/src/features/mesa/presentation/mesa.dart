import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techbistro/src/features/home/presentation/home_screen.dart';
import 'package:techbistro/src/features/settings/presentation/theme_controller.dart';
import 'new_order.dart';

class MesaPage extends ConsumerStatefulWidget {
  final int numeroMesa;

  const MesaPage({super.key, required this.numeroMesa});

  @override
  ConsumerState<MesaPage> createState() => _MesaPageState();
}

class _MesaPageState extends ConsumerState<MesaPage> {
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
      bool todosEntregues = true;

      for (var pedido in response) {
        final qtd = pedido['qtd_pedido'] ?? 0;
        final valorPrato = (pedido['pratos']?['valor_prato'] as num? ?? 0.0).toDouble();
        soma += (qtd * valorPrato);

        if (pedido['status_pedido'] != 'entregue') {
          todosEntregues = false;
        }
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

      bool contaPaga = (totalPedido - totalPago).abs() < 0.01 && totalPedido > 0;

      if (contaPaga) {
        if (todosEntregues) {
          _showCloseTableDialog();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Conta paga! Aguarde a entrega de todos os pedidos para fechar a mesa.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.orange[700],
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar pedidos: $e'), backgroundColor: const Color(0xFF840011)),
        );
      }
    }
  }

  Future<void> _showCloseTableDialog() async {
    final isDark = ref.read(themeControllerProvider).isDarkMode;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFEEEEEE) : const Color(0xFF2D2D2D);

    final bool? confirmClose = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline, size: 40, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 20),
                Text(
                  'Conta Finalizada',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nats',
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pagamentos OK e pedidos entregues.\nDeseja liberar a Mesa ${widget.numeroMesa}?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Manter Aberta', 
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600], 
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF840011),
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
      final pedidosHistorico = pedidos.map((p) {
        return {
          'prato': p['pratos']?['nome_prato'],
          'qtd': p['qtd_pedido'],
          'valor_unitario': p['pratos']?['valor_prato'],
          'status': p['status_pedido']
        };
      }).toList();

      final pagamentosResponse = await supabase
          .from('pagamento')
          .select('valor_pagamento, forma_pagamento')
          .eq('id_mesa', widget.numeroMesa);

      final pagamentosHistorico = (pagamentosResponse as List).map((p) => p).toList();

      await supabase.from('historico_mesas').insert({
        'numero_mesa': widget.numeroMesa,
        'valor_total': totalPedido,
        'itens_pedido': pedidosHistorico,
        'pagamentos': pagamentosHistorico,
      });

      await supabase.from('pagamento').delete().eq('id_mesa', widget.numeroMesa);
      await supabase.from('pedidos').delete().eq('id_mesa', widget.numeroMesa);
      await supabase.from('mesas').delete().eq('numero', widget.numeroMesa);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mesa fechada e arquivada!'), backgroundColor: Color(0xFF2E7D32)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fechar mesa: $e'), backgroundColor: const Color(0xFF840011)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ref.watch(themeControllerProvider);
    final isDark = themeProvider.isDarkMode;

    final Color primaryRed = const Color(0xFF840011);
    final Color darkRed = const Color(0xFF510006);
    
    final Color backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final Color surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? const Color(0xFFEEEEEE) : const Color(0xFF2D2D2D);
    final Color subTextColor = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    final Color itemBackground = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F9FA);

    final List<Color> cardGradient = isDark 
        ? [Colors.black, const Color(0xFF300000)] 
        : [darkRed, primaryRed];

    final valorRestante = totalPedido - totalPago;
    final percentualPago = totalPedido > 0 ? totalPago / totalPedido : 0.0;

    return Scaffold(
      backgroundColor: backgroundColor,
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
                  color: subTextColor,
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
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: cardGradient,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
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
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
                              color: textColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: pedidos.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.restaurant_menu_rounded, size: 60, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Nenhum pedido realizado.',
                                        style: TextStyle(color: subTextColor, fontFamily: 'Nats', fontSize: 18),
                                      ),
                                    ],
                                  ),
                                )
                              : _buildPedidosList(textColor, primaryRed, itemBackground),
                        ),
                        
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: surfaceColor,
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

  Widget _buildPedidosList(Color textColor, Color primaryRed, Color itemBackground) {
    final Map<String, dynamic> pedidosAgrupados = {};
    
    for (var pedido in pedidos) {
      final nomePrato = pedido['pratos']?['nome_prato'] ?? 'Prato';
      final qtd = pedido['qtd_pedido'] ?? 0;
      final valorPrato = (pedido['pratos']?['valor_prato'] as num? ?? 0.0).toDouble();
      final totalItem = qtd * valorPrato;
      final status = pedido['status_pedido'] ?? 'pendente';
      
      if (pedidosAgrupados.containsKey(nomePrato)) {
        pedidosAgrupados[nomePrato]['qtd'] += qtd;
        pedidosAgrupados[nomePrato]['total'] += totalItem;
      } else {
        pedidosAgrupados[nomePrato] = {'qtd': qtd, 'total': totalItem, 'status': status};
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
            color: itemBackground,
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
                    color: textColor,
                  ),
                ),
              ),
              Text(
                'R\$ ${item.value['total'].toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Nats',
                  color: Colors.grey[600],
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
    String formaPagamento = 'Crédito';
    
    final isDark = ref.read(themeControllerProvider).isDarkMode;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final inputFill = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F9FA);
    final textColor = isDark ? const Color(0xFFEEEEEE) : const Color(0xFF2D2D2D);
    final primaryRed = const Color(0xFF840011);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: surfaceColor,
              child: Container(
                padding: const EdgeInsets.all(24),
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
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: valorController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixText: 'R\$ ',
                          prefixStyle: TextStyle(color: textColor),
                          filled: true,
                          fillColor: inputFill,
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
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: formaPagamento,
                        dropdownColor: surfaceColor,
                        style: TextStyle(color: textColor, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        ),
                        items: ['Crédito', 'Débito', 'Dinheiro', 'PIX']
                            .map((label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(label),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            formaPagamento = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                              child: Text(
                                'Cancelar', 
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600], 
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;
                                final valor = double.parse(valorController.text.replaceAll(',', '.'));
                                Navigator.pop(context);
                                await _processPayment(valor, formaPagamento);
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
            );
          },
        );
      },
    );
  }

  Future<void> _processPayment(double valor, String formaPagamento) async {
    try {
      await supabase.from('pagamento').insert({
        'id_mesa': widget.numeroMesa,
        'valor_pagamento': valor,
        'forma_pagamento': formaPagamento,
      });
      await fetchPedidos();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pagamento de R\$ ${valor.toStringAsFixed(2)} ($formaPagamento) registrado!'),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar: $e'), backgroundColor: const Color(0xFF840011)),
        );
      }
    }
  }
}