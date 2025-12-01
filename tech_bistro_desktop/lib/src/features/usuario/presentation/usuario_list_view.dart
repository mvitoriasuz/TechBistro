import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsuarioListView extends StatefulWidget {
  final VoidCallback onCreate;
  final Function(Map<String, dynamic>) onEdit;

  const UsuarioListView({
    super.key,
    required this.onCreate,
    required this.onEdit,
  });

  @override
  State<UsuarioListView> createState() => _UsuarioListViewState();
}

class _UsuarioListViewState extends State<UsuarioListView> {
  List<Map<String, dynamic>> usuarios = [];
  bool loading = true;

  final Map<int, String> hierarquiaNomes = {
    1: 'Administrador',
    2: 'Gerente',
    3: 'Atendente',
    4: 'Cozinha',
  };

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    setState(() => loading = true);
    try {
      final supabase = Supabase.instance.client;
      
      final List<dynamic> data = await supabase.rpc('get_users_list');
      
      if (mounted) {
        setState(() {
          usuarios = List<Map<String, dynamic>>.from(data);
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar usuários: $e")),
        );
      }
    }
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
                "Usuários Cadastrados",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A2A2A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: widget.onCreate,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Novo Usuário",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA58570),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : usuarios.isEmpty
                    ? const Center(child: Text("Nenhum usuário encontrado."))
                    : SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("Nome")),
                            DataColumn(label: Text("E-mail")),
                            DataColumn(label: Text("Hierarquia")),
                            DataColumn(label: Text("Estabelecimento")),
                            DataColumn(label: Text("Ações")),
                          ],
                          rows: usuarios.map((u) {
                            final hId = u['hierarquia'] as int?;
                            final hNome = hierarquiaNomes[hId] ?? 'Desconhecido ($hId)';

                            return DataRow(
                              cells: [
                                DataCell(Text(u['full_name'] ?? '-')),
                                DataCell(Text(u['email'] ?? '-')),
                                DataCell(Chip(
                                  label: Text(
                                    hNome,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: const Color(0xFFA58570),
                                )),
                                DataCell(Text(u['estabelecimento_id'] ?? '-')),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () => widget.onEdit(u),
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