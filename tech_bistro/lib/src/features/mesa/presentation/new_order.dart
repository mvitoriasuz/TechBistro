import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techbistro/src/ui/theme/app_colors.dart';

class NewOrder extends StatefulWidget {
  final int idMesa;

  const NewOrder({Key? key, required this.idMesa}) : super(key: key);

  @override
  State<NewOrder> createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final supabase = Supabase.instance.client;
  Map<String, List<dynamic>> pratosPorCategoria = {};
  Map<int, int> quantidades = {};
  bool loading = true;

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

      setState(() {
        pratosPorCategoria = agrupados;
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
      for (var item in pedido) {
        await supabase.from('pedidos').insert({
          'id_prato': item['id'],
          'qtd_pedido': item['quantidade'],
          'observacao_pedido': observacao,
          'alergia_pedido': alergia,
          'status_pedido': 'pendente',
          'id_mesa': idMesa,
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
      _mostrarSnackBar('Adicione ao menos 1 item ao pedido.');
      return;
    }

    _mostrarPopup(pedidoFinal);
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
              title: const Text('Informações adicionais'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 10,
                      children: [
                        ElevatedButton(
                          onPressed:
                              () => setState(
                                () => mostrarAlergico = !mostrarAlergico,
                              ),
                          child: const Text('ALÉRGICOS'),
                        ),
                        ElevatedButton(
                          onPressed:
                              () => setState(() => mostrarObs = !mostrarObs),
                          child: const Text('OBSERVAÇÕES'),
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
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ),
                    if (mostrarObs)
                      TextField(
                        controller: obsAdicionaisController,
                        decoration: const InputDecoration(
                          labelText: 'Observações adicionais',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
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
                  child: const Text('ENVIAR PEDIDO'),
                ),
              ],
            );
          },
        );
      },
    );
  }

/// Função para capitalizar a primeira letra de uma string
    String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    const Color appBarColor = Color(0xFF840011);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Pedido', style: TextStyle(color: Colors.white)),
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
          ? const Center(
              child: Text(
                'Nenhum prato encontrado.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                // CARD DE CABEÇALHO
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
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

                // CARROSSEL DE CATEGORIAS
                Expanded(
                  child: Container(
                    child: PageView.builder(
                      itemCount: pratosPorCategoria.length,
                      controller: PageController(viewportFraction: 0.9),
                      itemBuilder: (context, index) {
                        final categoria =
                            pratosPorCategoria.keys.elementAt(index);
                        final pratos = pratosPorCategoria[categoria]!;
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  capitalize(categoria),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Nats',
                                    color: Color(0xFF840011),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: pratos.length,
                                    itemBuilder: (context, i) {
                                      final prato = pratos[i];
                                      final id = prato['id'];
                                      final nome = prato['nome_prato'];
                                      final valor = prato['valor_prato'];
                                      final quantidade = quantidades[id] ?? 0;
                                      return Card(
                                        child: ListTile(
                                          title: Text(nome),
                                          subtitle: Text(
                                            'R\$ ${valor.toStringAsFixed(2)}',
                                          ),
                                          trailing: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.remove,
                                                    color: appBarColor,
                                                  ),
                                                  onPressed: () => setState(() {
                                                    if (quantidade > 0) {
                                                      quantidades[id] =
                                                          quantidade - 1;
                                                    }
                                                  }),
                                                ),
                                                Container(
                                                  width: 40,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '$quantidade',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.add,
                                                    color: appBarColor,
                                                  ),
                                                  onPressed: () => setState(() {
                                                    quantidades[id] =
                                                        quantidade + 1;
                                                  }),
                                                ),
                                              ],
                                            ),
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
                ),

                // BOTÃO CONFIRMAR
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                      onPressed: _confirmarPedido,
                      child: const Text(
                        'Finalizar pedido',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'Nats',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
),
    );
  }
}