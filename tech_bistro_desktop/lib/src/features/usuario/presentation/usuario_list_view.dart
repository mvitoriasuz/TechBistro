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

  final supabase = Supabase.instance.client;

  Future<void> carregar() async {
    setState(() => loading = true);

    try {
      // Buscando usuários da tabela users_profile + hierarquia
      final response = await supabase
          .from('users_profile')
          .select(
            'id, name, email, phone, role, hierarquia_id, hierarquias(nome)',
          )
          .order('created_at', ascending: true);

      // Converte para List<Map<String, dynamic>>
      usuarios = List<Map<String, dynamic>>.from(response as List);

      setState(() {
        usuarios = List<Map<String, dynamic>>.from(response);
        loading = false;
      });
    } catch (e) {
      debugPrint("Erro ao listar usuários: $e");
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> excluirUsuario(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmação"),
        content: const Text("Deseja realmente excluir este usuário?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final response = await supabase.from('users_profile').delete().eq('id', id);

    if (response.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao excluir usuário: ${response.error!.message}"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário excluído com sucesso!")),
      );
      carregar();
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
                "Usuários",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: widget.onCreate,
                child: const Text("Novo Usuário"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : DataTable(
                    columns: const [
                      DataColumn(label: Text("ID")),
                      DataColumn(label: Text("Nome")),
                      DataColumn(label: Text("E-mail")),
                      DataColumn(label: Text("Telefone")),
                      DataColumn(label: Text("Role")),
                      DataColumn(label: Text("Hierarquia")),
                      DataColumn(label: Text("Ações")),
                    ],
                    rows: usuarios.map((u) {
                      return DataRow(
                        cells: [
                          DataCell(Text(u['id'].toString())),
                          DataCell(Text(u['name'] ?? '')),
                          DataCell(Text(u['email'] ?? '')),
                          DataCell(Text(u['phone'] ?? '')),
                          DataCell(Text(u['role'] ?? '')),
                          DataCell(Text(u['hierarquias']?['nome'] ?? '')),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => widget.onEdit(u),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => excluirUsuario(u['id']),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
