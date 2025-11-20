import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'hierarquia.dart';

class HierarquiaListView extends StatefulWidget {
  const HierarquiaListView({super.key});

  @override
  State<HierarquiaListView> createState() => _HierarquiaListViewState();
}

class _HierarquiaListViewState extends State<HierarquiaListView> {
  final client = Supabase.instance.client;
  List<Map<String, dynamic>> hierarquias = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final response = await client.from('hierarquias').select() as List<dynamic>;
      setState(() {
        hierarquias = List<Map<String, dynamic>>.from(response);
      });
    } catch (e, st) {
      print("Erro ao carregar hierarquias: $e\n$st");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao carregar hierarquias")),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void openEditor(Map<String, dynamic>? h) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HierarquiaForm(hierarquia: h)),
    );

    // Se o formulário retornar true, recarrega a lista
    if (result == true) {
      load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hierarquias"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openEditor(null),
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: hierarquias.length,
              itemBuilder: (_, i) {
                final h = hierarquias[i];
                final permissoes = h['permissoes'] as Map<String, dynamic>? ?? {};
                return ListTile(
                  title: Text(h['nome'] ?? ''),
                  subtitle: Text("Permissões: ${permissoes.keys.length}"),
                  onTap: () => openEditor(h),
                );
              },
            ),
    );
  }
}
