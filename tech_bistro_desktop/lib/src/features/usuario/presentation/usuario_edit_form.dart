import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsuarioEditForm extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onCancel;
  final VoidCallback onSaved;

  const UsuarioEditForm({
    super.key,
    required this.usuario,
    required this.onCancel,
    required this.onSaved,
  });

  @override
  State<UsuarioEditForm> createState() => _UsuarioEditFormState();
}

class _UsuarioEditFormState extends State<UsuarioEditForm> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  late TextEditingController displayName;
  late TextEditingController email;
  late TextEditingController phone;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    displayName = TextEditingController(text: widget.usuario["name"] ?? "");
    email       = TextEditingController(text: widget.usuario["email"] ?? "");
    phone       = TextEditingController(text: widget.usuario["phone"] ?? "");
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await supabase
          .from("users_profile")
          .update({
            "name": displayName.text,
            "email": email.text,
            "phone": phone.text,
          })
          .eq("id", widget.usuario["id"]);

      widget.onSaved();
      widget.onCancel();
    } catch (e) {
      debugPrint("Erro ao editar: $e");
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
              const Text("Editar Usuário",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              TextFormField(
                controller: displayName,
                decoration: const InputDecoration(labelText: "Nome"),
              ),
              TextFormField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextFormField(
                controller: phone,
                decoration: const InputDecoration(labelText: "Telefone"),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: widget.onCancel, child: const Text("Cancelar")),
                  ElevatedButton(
                    onPressed: loading ? null : salvar,
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
