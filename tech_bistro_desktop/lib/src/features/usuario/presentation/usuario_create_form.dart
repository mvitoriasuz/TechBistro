import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsuarioCreateForm extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSaved;

  const UsuarioCreateForm({
    super.key,
    required this.onCancel,
    required this.onSaved,
  });

  @override
  State<UsuarioCreateForm> createState() => _UsuarioCreateFormState();
}

class _UsuarioCreateFormState extends State<UsuarioCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  final TextEditingController displayName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController senha = TextEditingController();

  bool loading = false;

  final List<Map<String, dynamic>> hierarquias = [
    {'id': 1, 'nome': 'Admin'},
    {'id': 2, 'nome': 'Garçom'},
    {'id': 3, 'nome': 'Cozinha'},
  ];

  int? hierarquiaSelecionada;

  Future<void> criarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final response = await supabase.from('users_profile').insert({
        'name': displayName.text.trim(),
        'email': email.text.trim(),
        'role': hierarquias.firstWhere((h) => h['id'] == hierarquiaSelecionada)['nome'],
        'phone': phone.text.trim(),
        'senha': senha.text.trim(),
        'hierarquia_id': hierarquiaSelecionada,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (response.isEmpty) {
        throw "Falha ao inserir usuário.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário criado com sucesso!")),
      );

      widget.onSaved();
      widget.onCancel();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao criar usuário: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Criar Usuário",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              TextFormField(
                controller: displayName,
                decoration: const InputDecoration(labelText: "Nome"),
                validator: (v) => v!.isEmpty ? "Informe o nome" : null,
              ),

              TextFormField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Informe o email" : null,
              ),

              TextFormField(
                controller: phone,
                decoration: const InputDecoration(labelText: "Telefone"),
              ),

              TextFormField(
                controller: senha,
                decoration: const InputDecoration(labelText: "Senha"),
                obscureText: true,
                validator: (v) => v!.isEmpty ? "Informe a senha" : null,
              ),

              DropdownButtonFormField<int>(
                value: hierarquiaSelecionada,
                decoration: const InputDecoration(labelText: "Hierarquia"),
                items: hierarquias
                    .map((h) => DropdownMenuItem<int>(
                          value: h['id'],
                          child: Text(h['nome']),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => hierarquiaSelecionada = v),
                validator: (v) => v == null ? "Selecione uma hierarquia" : null,
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: loading ? null : criarUsuario,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text("Salvar"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
