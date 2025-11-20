import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

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

  List<Map<String, dynamic>> hierarquias = [];
  int? hierarquiaSelecionada;

  @override
  void initState() {
    super.initState();
    _loadHierarquias();
  }

  Future<void> _loadHierarquias() async {
    setState(() => loading = true);
    try {
      final response = await supabase.from('hierarquias').select();
      hierarquias = List<Map<String, dynamic>>.from(response);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao carregar hierarquias")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> criarUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    if (hierarquiaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione uma hierarquia")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final nomeHierarquia = hierarquias
          .firstWhere((h) => h['id'] == hierarquiaSelecionada)['nome'];

      // Gerar código único se for Garçom ou Cozinha
      String? codigoAcesso;
      if (nomeHierarquia == "Garçom" || nomeHierarquia == "Cozinha") {
        codigoAcesso = _gerarCodigoUnico();
      }

      await supabase.from('users_profile').insert({
        'name': displayName.text.trim(),
        'email': email.text.trim(),
        'phone': phone.text.trim(),
        'senha': senha.text.trim(),
        'hierarquia_id': hierarquiaSelecionada,
        'role': nomeHierarquia,
        'codigo_acesso': codigoAcesso, // novo campo
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário criado com sucesso!")),
      );

      widget.onSaved();
      widget.onCancel();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao criar usuário: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // Função para gerar código único de 6 caracteres
  String _gerarCodigoUnico() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
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
              const Text(
                "Criar Usuário",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: displayName,
                decoration: const InputDecoration(labelText: "Nome"),
                validator: (v) => v!.isEmpty ? "Informe o nome" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Informe o email" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phone,
                decoration: const InputDecoration(labelText: "Telefone"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: senha,
                decoration: const InputDecoration(labelText: "Senha"),
                obscureText: true,
                validator: (v) => v!.isEmpty ? "Informe a senha" : null,
              ),
              const SizedBox(height: 16),
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
