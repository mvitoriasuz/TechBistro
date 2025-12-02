import 'package:flutter/material.dart';
import 'package:tech_bistro_desktop/src/features/cardapio/data/prato_service.dart';
import 'package:tech_bistro_desktop/src/ui/theme/app_colors.dart';
import 'prato_form.dart';

class PratoListPage extends StatefulWidget {
  final String idEstabelecimento;
  const PratoListPage({super.key, required this.idEstabelecimento});

  @override
  State<PratoListPage> createState() => _PratoListPageState();
}

class _PratoListPageState extends State<PratoListPage> {
  late PratoService service;
  bool loading = true;
  List<Map<String, dynamic>> pratos = [];

  @override
  void initState() {
    super.initState();
    service = PratoService();
    _carregarPratos();
  }

  Future<void> _carregarPratos() async {
    setState(() => loading = true);
    try {
      pratos = await service.listarPratos(widget.idEstabelecimento);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar pratos: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  void _abrirForm({Map<String, dynamic>? prato}) {
    showDialog(
      context: context,
      builder: (_) => PratoForm(
        idEstabelecimento: widget.idEstabelecimento,
        pratoExistente: prato,
        onSaved: _carregarPratos,
      ),
    );
  }

  Future<void> _deletarPrato(int id) async {
    try {
      await service.deletarPrato(id);
      _carregarPratos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar prato: $e')),
      );
    }
  }
  Widget _buildTabelaAgrupada() {
  Map<String, List<Map<String, dynamic>>> grupos = {};

  for (var p in pratos) {
    String categoria = p['categoria_prato'] ?? 'Sem Categoria';
    grupos.putIfAbsent(categoria, () => []);
    grupos[categoria]!.add(p);
  }

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grupos.entries.map((grupo) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                grupo.key,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A2A2A),
                ),
              ),
            ),
            DataTable(
              columns: const [
                DataColumn(label: Text("Nome")),
                DataColumn(label: Text("Valor")),
                DataColumn(label: Text("Ações")),
              ],
              rows: grupo.value.map((p) {
                return DataRow(
                  cells: [
                    DataCell(Text(p['nome_prato'])),
                    DataCell(Text(
                        "R\$ ${p['valor_prato'].toStringAsFixed(2)}")),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _abrirForm(prato: p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletarPrato(p['id']),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Pratos do Cardápio",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A2A2A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _abrirForm(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Novo Prato",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA58570),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : pratos.isEmpty
                    ? const Center(child: Text("Nenhum prato encontrado."))
                    : SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("Nome")),
                            DataColumn(label: Text("Categoria")),
                            DataColumn(label: Text("Valor")),
                            DataColumn(label: Text("Ações")),
                          ],
                          rows: pratos.map((p) {
                            return DataRow(
                              cells: [
                                DataCell(Text(p['nome_prato'])),
                                DataCell(Text(p['categoria_prato'] ?? '-')),
                                DataCell(Text(
                                    "R\$ ${p['valor_prato'].toStringAsFixed(2)}")),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () =>
                                            _abrirForm(prato: p),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _deletarPrato(p['id']),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
