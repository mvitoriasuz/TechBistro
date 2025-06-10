import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewOrder extends StatefulWidget {
  final int idMesa;

  const NewOrder({Key? key, required this.idMesa}) : super(key: key);

  @override
  State<NewOrder> createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final supabase = Supabase.instance.client;
  List<dynamic> pratos = [];
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
      setState(() {
        pratos = response;
        for (var prato in pratos) {
          quantidades[prato['id']] = 0;
        }
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      _mostrarSnackBar('Erro ao carregar pratos: $e');
    }
  }

  void _mostrarSnackBar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
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
    final pedidoFinal = pratos
        .where((prato) => quantidades[prato['id']]! > 0)
        .map((prato) => {
              'id': prato['id'],
              'nome': prato['nome_prato'],
              'quantidade': quantidades[prato['id']],
              'valor_unitario': prato['valor_prato'],
            })
        .toList();

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
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() => mostrarAlergico = !mostrarAlergico),
                        child: const Text('ALÉRGICOS'),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() => mostrarObs = !mostrarObs),
                        child: const Text('OBSERVAÇÕES'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (mostrarAlergico)
                    TextField(
                      controller: alergicoController,
                      decoration: const InputDecoration(
                        labelText: 'Informe alergias',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  if (mostrarAlergico) const SizedBox(height: 12),
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final alergicos = alergicoController.text.trim();
                    final obs = obsAdicionaisController.text.trim();
                    final idMesa = widget.idMesa;
                    final observacao = obs.isEmpty ? null : obs;
                    final alergia = alergicos.isEmpty ? null : alergicos;

                    _enviarPedido(pedidoFinal, observacao, alergia, idMesa);
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchPratos,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Adicionar Itens ao Pedido',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: pratos.length,
                        itemBuilder: (context, index) {
                          final prato = pratos[index];
                          final id = prato['id'];
                          final nome = prato['nome_prato'];
                          final categoria = prato['categoria_prato'];
                          final valor = prato['valor_prato'];
                          final quantidade = quantidades[id] ?? 0;

                          return Card(
                            child: ListTile(
                              title: Text(nome),
                              subtitle: Text('$categoria - R\$ ${valor.toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => setState(() {
                                      if (quantidade > 0) quantidades[id] = quantidade - 1;
                                    }),
                                  ),
                                  Text('$quantidade'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => setState(() {
                                      quantidades[id] = quantidade + 1;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: appBarColor),
                        onPressed: _confirmarPedido,
                        child: const Text('CONFIRMAR PEDIDO', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
