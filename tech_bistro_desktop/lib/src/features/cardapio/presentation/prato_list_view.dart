import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'prato.dart';

class PratoListView extends StatefulWidget {
  final int idEstabelecimento;
  const PratoListView({super.key, required this.idEstabelecimento});

  @override
  State<PratoListView> createState() => _PratoListViewState();
}

class _PratoListViewState extends State<PratoListView> {
  final client = Supabase.instance.client;

  String screen = "list"; // list | create | edit
  Map<String, dynamic>? pratoSelecionado;

  List<Map<String, dynamic>> pratos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final resp = await client.from('pratos').select();
      pratos = List<Map<String, dynamic>>.from(resp)
          .where((p) => p['id_estabelecimento'] == widget.idEstabelecimento)
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar pratos: $e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void goToCreate() {
    setState(() {
      screen = "create";
      pratoSelecionado = null;
    });
  }

  void goToList() {
    setState(() {
      screen = "list";
      pratoSelecionado = null;
    });
    load();
  }

  void goToEdit(Map<String, dynamic> prato) {
    setState(() {
      screen = "edit";
      pratoSelecionado = prato;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (screen) {
      case "create":
        return PratoForm(
          idEstabelecimento: widget.idEstabelecimento,
          prato: null,
          onCancel: goToList,
          onSaved: goToList,
        );

      case "edit":
        if (pratoSelecionado == null) {
          return const Center(child: Text("Nenhum prato selecionado."));
        }

        return PratoForm(
          idEstabelecimento: widget.idEstabelecimento,
          prato: pratoSelecionado!,
          onCancel: goToList,
          onSaved: goToList,
        );

      default:
        return buildList();
    }
  }

  Widget buildList() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Título + botão novo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Pratos",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: goToCreate,
                icon: const Icon(Icons.add, color:Colors.white,),
                label: const Text(
                  "Novo Prato",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA58570),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : pratos.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhum prato cadastrado",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.separated(
                    itemCount: pratos.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final p = pratos[i];
                      return ListTile(
                        title: Text(p['nome_prato'] ?? ''),
                        subtitle: Text(
                          'R\$ ${p['valor_prato'] ?? 0}  —  ${p['categoria_prato'] ?? 'Sem categoria'}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => goToEdit(p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
