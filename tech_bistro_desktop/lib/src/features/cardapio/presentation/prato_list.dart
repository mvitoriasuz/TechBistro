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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar pratos: $e')));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao deletar prato: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _abrirForm(),
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : pratos.isEmpty
              ? const Center(child: Text('Nenhum prato encontrado'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pratos.length,
                  itemBuilder: (_, i) {
                    final p = pratos[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        title: Text(p['nome_prato']),
                        subtitle: Text('${p['categoria_prato']} • R\$ ${p['valor_prato'].toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: () => _abrirForm(prato: p), icon: const Icon(Icons.edit, color: Colors.orange)),
                            IconButton(onPressed: () => _deletarPrato(p['id']), icon: const Icon(Icons.delete, color: Colors.red)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
