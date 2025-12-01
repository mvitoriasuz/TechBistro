import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techbistro/src/constants/app_colors.dart';

class NewOrder extends StatefulWidget {
  final int idMesa;

  const NewOrder({super.key, required this.idMesa});

  @override
  State<NewOrder> createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final supabase = Supabase.instance.client;
  
  final Color primaryRed = const Color(0xFF840011);
  final Color backgroundApp = const Color(0xFFF8F9FA);
  final Color darkText = const Color(0xFF2D2D2D);

  Map<String, List<dynamic>> pratosPorCategoria = {};
  Map<int, int> quantidades = {};
  bool loading = true;
  List<String> categoriasOrdenadas = [];
  String categoriaSelecionada = '';

  @override
  void initState() {
    super.initState();
    fetchPratos();
  }

  Future<void> fetchPratos() async {
    try {
      final response = await supabase.from('pratos').select();
      Map<String, List<dynamic>> agrupados = {};

      for (var prato in response) {
        final categoria = prato['categoria_prato'] ?? 'Outros';
        agrupados.putIfAbsent(categoria, () => []).add(prato);
        quantidades[prato['id']] = 0;
      }

      List<String> todasCategorias = agrupados.keys.toList();
      todasCategorias.sort((a, b) {
        const ordemPrioridade = {
          'entrada': 0,
          'prato principal': 1,
          'bebidas': 2,
          'sobremesas': 3,
          'outros': 4,
        };

        final ordemA = ordemPrioridade[a.toLowerCase()] ?? 999;
        final ordemB = ordemPrioridade[b.toLowerCase()] ?? 999;

        if (ordemA != ordemB) {
          return ordemA.compareTo(ordemB);
        }
        return a.toLowerCase().compareTo(b.toLowerCase());
      });

      setState(() {
        pratosPorCategoria = agrupados;
        categoriasOrdenadas = todasCategorias;
        if (categoriasOrdenadas.isNotEmpty) {
          categoriaSelecionada = categoriasOrdenadas[0];
        }
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      _mostrarSnackBar('Erro ao carregar pratos: $e', isError: true);
    }
  }

  void _mostrarSnackBar(String mensagem, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem, style: const TextStyle(fontFamily: 'Nats', fontWeight: FontWeight.bold)),
        backgroundColor: isError ? primaryRed : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _enviarPedido(
    List<Map<String, dynamic>> pedido,
    String? observacao,
    String? alergia,
    int idMesa,
  ) async {
    try {
      final agora = DateTime.now();
      for (var item in pedido) {
        await supabase.from('pedidos').insert({
          'id_prato': item['id'],
          'qtd_pedido': item['quantidade'],
          'observacao_pedido': observacao,
          'alergia_pedido': alergia,
          'status_pedido': 'pendente',
          'id_mesa': idMesa,
          'data_pedido': agora.toIso8601String().split('T')[0],
          'horario_pedido': agora.toIso8601String().substring(11, 16),
        });
      }
      
      if (mounted) {
        _mostrarSnackBar('Pedido enviado com sucesso!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _mostrarSnackBar('Erro ao enviar pedido: $e', isError: true);
      }
    }
  }

  void _confirmarPedido() {
    final pedidoFinal = quantidades.entries.where((entry) => entry.value > 0).map((entry) {
      final prato = pratosPorCategoria.values
          .expand((x) => x)
          .firstWhere((p) => p['id'] == entry.key);
      return {
        'id': prato['id'],
        'nome': prato['nome_prato'],
        'quantidade': entry.value,
        'valor_unitario': prato['valor_prato'],
      };
    }).toList();

    if (pedidoFinal.isEmpty) {
      _showWarningDialog('Selecione ao menos um item.');
      return;
    }

    _mostrarPopupConfirmacao(pedidoFinal);
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Icon(Icons.warning_amber_rounded, size: 40, color: Colors.orange[400]),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Nats', fontSize: 18, color: darkText),
        ),
      ),
    );
  }

  void _mostrarPopupConfirmacao(List<Map<String, dynamic>> pedidoFinal) {
    final alergicoController = TextEditingController();
    final obsAdicionaisController = TextEditingController();
    bool mostrarAlergico = false;
    bool mostrarObs = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Column(
                children: [
                  Text(
                    'Revisão do Pedido',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      fontFamily: 'Nats',
                      color: primaryRed,
                    ),
                  ),
                  Text(
                    'Adicione detalhes se necessário',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Nats',
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            label: 'ALÉRGICOS',
                            icon: Icons.no_food_outlined,
                            isActive: mostrarAlergico,
                            onTap: () => setState(() => mostrarAlergico = !mostrarAlergico),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            label: 'OBSERVAÇÃO',
                            icon: Icons.edit_note_rounded,
                            isActive: mostrarObs,
                            onTap: () => setState(() => mostrarObs = !mostrarObs),
                          ),
                        ),
                      ],
                    ),
                    
                    if (mostrarAlergico) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: alergicoController,
                        decoration: InputDecoration(
                          hintText: 'Ex: Alergia a camarão, glúten...',
                          labelText: 'Alergias',
                          filled: true,
                          fillColor: Colors.red[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                        ),
                        maxLines: 2,
                        minLines: 1,
                      ),
                    ],

                    if (mostrarObs) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: obsAdicionaisController,
                        decoration: InputDecoration(
                          hintText: 'Ex: Sem cebola, ponto da carne...',
                          labelText: 'Observações Gerais',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.notes, color: Colors.grey),
                        ),
                        maxLines: 2,
                        minLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Voltar', style: TextStyle(color: Colors.grey[600], fontSize: 16, fontFamily: 'Nats', fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final alergicos = alergicoController.text.trim();
                    final obs = obsAdicionaisController.text.trim();
                    
                    Navigator.of(context).pop();

                    _enviarPedido(
                      pedidoFinal,
                      obs.isEmpty ? null : obs,
                      alergicos.isEmpty ? null : alergicos,
                      widget.idMesa,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('ENVIAR COZINHA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? primaryRed : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? primaryRed : Colors.grey.shade300),
          boxShadow: [
            if (!isActive)
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  int _getTotalItens() {
    return quantidades.values.fold(0, (sum, qtd) => sum + qtd);
  }

  double _getValorTotal() {
    double total = 0.0;
    quantidades.forEach((id, qtd) {
      if (qtd > 0) {
        final prato = pratosPorCategoria.values
            .expand((e) => e)
            .firstWhere((p) => p['id'] == id);
        total += (qtd * (prato['valor_prato'] as num).toDouble());
      }
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
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
                'Novo Pedido',
                style: TextStyle(
                  color: primaryRed,
                  fontFamily: 'Nats',
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                ),
              ),
              Text(
                'Mesa ${widget.idMesa}',
                style: TextStyle(
                  color: Colors.grey[500],
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
              icon: Icon(Icons.close_rounded, color: primaryRed),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: primaryRed))
          : Column(
              children: [
                _buildCategoriesSelector(),
                Expanded(
                  child: pratosPorCategoria.isEmpty
                      ? _buildEmptyState()
                      : _buildPratosList(),
                ),
                _buildBottomSummary(),
              ],
            ),
    );
  }

  Widget _buildCategoriesSelector() {
    return Container(
      height: 60,
      width: double.infinity,
      color: Colors.transparent,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: categoriasOrdenadas.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final categoria = categoriasOrdenadas[index];
          final isSelected = categoria == categoriaSelecionada;
          return GestureDetector(
            onTap: () => setState(() => categoriaSelecionada = categoria),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? primaryRed : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(color: Colors.grey.shade200),
                boxShadow: isSelected 
                  ? [BoxShadow(color: primaryRed.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] 
                  : [],
              ),
              child: Text(
                capitalize(categoria),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nats',
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPratosList() {
    final pratos = pratosPorCategoria[categoriaSelecionada] ?? [];
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: pratos.length,
      itemBuilder: (context, index) {
        final prato = pratos[index];
        final id = prato['id'];
        final qtd = quantidades[id] ?? 0;
        final valor = (prato['valor_prato'] as num).toDouble();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prato['nome_prato'],
                        style: TextStyle(
                          fontFamily: 'Nats',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'R\$ ${valor.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'Nats',
                          fontSize: 18,
                          color: primaryRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: backgroundApp,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildQtyButton(Icons.remove, () {
                        if (qtd > 0) setState(() => quantidades[id] = qtd - 1);
                      }),
                      Container(
                        width: 30,
                        alignment: Alignment.center,
                        child: Text(
                          '$qtd',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nats',
                            color: qtd > 0 ? primaryRed : Colors.grey,
                          ),
                        ),
                      ),
                      _buildQtyButton(Icons.add, () {
                        setState(() => quantidades[id] = qtd + 1);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20, color: primaryRed),
      ),
    );
  }

  Widget _buildBottomSummary() {
    final int count = _getTotalItens();
    final double total = _getValorTotal();

    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count itens',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  'R\$ ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    fontFamily: 'Nats',
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _confirmarPedido,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                elevation: 4,
                shadowColor: primaryRed.withOpacity(0.4),
              ),
              child: const Row(
                children: [
                  Text(
                    'Avançar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Cardápio indisponível.',
            style: TextStyle(color: Colors.grey[400], fontSize: 18, fontFamily: 'Nats'),
          ),
        ],
      ),
    );
  }
}