import 'dart:convert';
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
      final response =
          await client.from('hierarquias').select() as List<dynamic>;
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

    if (result == true) {
      load();
    }
  }

  Map<String, dynamic> parsePermissoes(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is String) {
      try {
        return jsonDecode(value);
      } catch (e) {
        print("Erro ao decodificar permissoes: $e");
      }
    }
    return {};
  }

  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F6FA),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com título e botão
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Hierarquias",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A2A2A),
                ),
              ),

              ElevatedButton.icon(
                onPressed: () => openEditor(null),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Nova Hierarquia",
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

          const SizedBox(height: 20),

          // Lista ou loading
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: hierarquias.length,
                    itemBuilder: (_, i) {
                      final h = hierarquias[i];
                      final permissoes = parsePermissoes(h['permissoes']);

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => openEditor(h),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                // Nome
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        h['nome'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Permissões: ${permissoes.keys.length}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                const Icon(Icons.chevron_right, size: 30),
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
}

}
