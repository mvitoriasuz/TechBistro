import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techbistro/src/constants/app_colors.dart';
import 'package:techbistro/src/features/settings/presentation/theme_controller.dart';

class NewOrder extends StatefulWidget {
  final int idMesa;

  const NewOrder({super.key, required this.idMesa});

  @override
  State<NewOrder> createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final supabase = Supabase.instance.client;
  Map<String, List<dynamic>> pratosPorCategoria = {};
  Map<int, int> quantidades = {};
  bool loading = true;
  List<String> categoriasOrdenadas = [];

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
        // Nova ordem de prioridade
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
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      _mostrarSnackBar('Erro ao carregar pratos: $e');
    }
  }

  void _mostrarSnackBar(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
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
      _mostrarSnackBar('Pedido enviado com sucesso!');
      Navigator.pop(context);
    } catch (e) {
      _mostrarSnackBar('Erro ao enviar pedido: $e');
    }
  }

  void _confirmarPedido() {
    final pedidoFinal =
        quantidades.entries.where((entry) => entry.value > 0).map((entry) {
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
      _showCenteredWarningDialog(
        context,
        'Adicione ao menos 1 item ao pedido.',
      );
      return;
    }

    _mostrarPopup(pedidoFinal);
  }

  void _showCenteredWarningDialog(BuildContext context, String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.dialogTheme.backgroundColor ??
        (isDark ? Colors.grey[850] : Colors.white);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Atenção',
            style: TextStyle(
              fontFamily: 'Nats',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.amber.shade200 : Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Nats',
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  void _mostrarPopup(List<Map<String, dynamic>> pedidoFinal) {
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Informações Adicionais',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Nats',
                  color: Color(0xFF840011),
                ),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(
                              () => mostrarAlergico = !mostrarAlergico,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'ALÉRGICOS',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => mostrarObs = !mostrarObs),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'OBSERVAÇÕES',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (mostrarAlergico)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: alergicoController,
                          decoration: const InputDecoration(
                            labelText: 'Informe alergias',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            prefixIcon: Icon(Icons.warning_amber_rounded, color: Colors.orange),
                          ),
                          maxLines: 2,
                          minLines: 1,
                        ),
                      ),
                    if (mostrarObs)
                      TextField(
                        controller: obsAdicionaisController,
                        decoration: const InputDecoration(
                          labelText: 'Observações adicionais',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          prefixIcon: Icon(Icons.notes, color: Colors.blueGrey),
                        ),
                        maxLines: 2,
                        minLines: 1,
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final alergicos = alergicoController.text.trim();
                    final obs = obsAdicionaisController.text.trim();
                    final observacao = obs.isEmpty ? null : obs;
                    final alergia = alergicos.isEmpty ? null : alergicos;

                    _enviarPedido(
                      pedidoFinal,
                      observacao,
                      alergia,
                      widget.idMesa,
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF840011),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('ENVIAR PEDIDO', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    const Color appBarColor = Color(0xFF840011);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Novo Pedido',
          style: TextStyle(color: Colors.white, fontFamily: 'Nats'),
        ),
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : pratosPorCategoria.isEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'PEDIDO MESA ${widget.idMesa}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Nats',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum pedido realizado.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          itemCount: categoriasOrdenadas.length,
                          controller: PageController(viewportFraction: 0.95),
                          itemBuilder: (context, index) {
                            final categoria = categoriasOrdenadas[index];
                            final pratos = pratosPorCategoria[categoria]!;

                            return Card(
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      capitalize(categoria),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                        fontFamily: 'Nats',
                                        color: Color(0xFF840011),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: pratos.length,
                                        itemBuilder: (context, i) {
                                          final prato = pratos[i];
                                          final id = prato['id'];
                                          final nome = prato['nome_prato'];
                                          final valor = prato['valor_prato'];
                                          final quantidade = quantidades[id] ?? 0;

                                          return ListTile(
                                            title: Text(
                                              nome,
                                              style: const TextStyle(
                                                fontFamily: 'Nats',
                                                fontSize: 21,
                                              ),
                                            ),
                                            subtitle: Text(
                                              'R\$ ${valor.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontFamily: 'Nats',
                                                fontSize: 21,
                                                color: Color.fromARGB(
                                                  255,
                                                  124,
                                                  118,
                                                  118,
                                                ),
                                              ),
                                            ),
                                            trailing: Container(
                                              width: 110,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.remove,
                                                    ),
                                                    color: const Color(
                                                      0xFF840011,
                                                    ),
                                                    iconSize: 20,
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
                                                      minWidth: 30,
                                                      minHeight: 30,
                                                    ),
                                                    onPressed: () {
                                                      if (quantidade > 0) {
                                                        setState(
                                                          () =>
                                                              quantidades[id] =
                                                                  quantidade - 1,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  Text(
                                                    '$quantidade',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Nats',
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.add),
                                                    color: const Color(
                                                      0xFF840011,
                                                    ),
                                                    iconSize: 20,
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
                                                      minWidth: 30,
                                                      minHeight: 30,
                                                    ),
                                                    onPressed: () {
                                                      setState(
                                                        () =>
                                                              quantidades[id] =
                                                                  quantidade + 1,
                                                      );
                                                    },
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
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _confirmarPedido,
                          child: const Text(
                            'Finalizar pedido',
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
