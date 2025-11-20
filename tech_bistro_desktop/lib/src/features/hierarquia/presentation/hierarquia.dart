import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const allPermissions = {
  "can_view_tables": "Visualizar mesas",
  "can_open_table": "Abrir mesa",
  "can_edit_table": "Editar mesa",
  "can_delete_table": "Excluir mesa",
  "can_close_table": "Fechar mesa",
  "can_create_order": "Criar pedido",
  "can_edit_order": "Editar pedido",
  "can_cancel_order_item": "Cancelar item do pedido",
  "can_view_kitchen_queue": "Visualizar fila da cozinha",
  "can_update_kitchen_status": "Atualizar status da cozinha",
};

class HierarquiaForm extends StatefulWidget {
  final Map<String, dynamic>? hierarquia;

  const HierarquiaForm({super.key, this.hierarquia});

  @override
  State<HierarquiaForm> createState() => _HierarquiaFormState();
}

class _HierarquiaFormState extends State<HierarquiaForm> {
  final client = Supabase.instance.client;
  final nomeCtrl = TextEditingController();
  Map<String, bool> permissoes = {};
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.hierarquia != null) {
      nomeCtrl.text = widget.hierarquia!['nome'] ?? '';
      final rawPerm = widget.hierarquia!['permissoes'] ?? {};
      permissoes = {for (var e in rawPerm.entries) e.key: e.value == true};
    } else {
      permissoes = {for (var k in allPermissions.keys) k: false};
    }
  }

  Future<void> salvar() async {
    setState(() => loading = true);

    final data = {"nome": nomeCtrl.text, "permissoes": permissoes};

    try {
      if (widget.hierarquia == null) {
        await client.from("hierarquias").insert(data);
      } else {
        await client
            .from("hierarquias")
            .update(data)
            .eq("id", widget.hierarquia!["id"]);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hierarquia salva com sucesso!")),
        );

        // Delay para exibir o SnackBar antes de fechar
        await Future.delayed(const Duration(milliseconds: 300));

        if (Navigator.canPop(context)) {
          Navigator.pop(context, true); // retorna true para recarregar a lista
        }
      }
    } catch (e, st) {
      print("Erro ao salvar hierarquia: $e\n$st");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro inesperado ao salvar: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hierarquia == null
            ? "Nova hierarquia"
            : "Editar hierarquia"),
        actions: [
          IconButton(
            icon: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.save),
            onPressed: loading ? null : salvar,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nomeCtrl,
              decoration: const InputDecoration(
                  labelText: "Nome da hierarquia",
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text(
              "Permissões",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...allPermissions.entries.map((p) {
              return SwitchListTile(
                title: Text(p.value),
                value: permissoes[p.key] ?? false,
                onChanged: (v) {
                  setState(() => permissoes[p.key] = v);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
