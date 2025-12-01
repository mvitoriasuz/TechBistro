import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tech_bistro_desktop/src/ui/theme/app_colors.dart';

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
  
  late TextEditingController _nomeCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;

  bool _loading = false;
  int? _hierarquiaSelecionada;

  final List<Map<String, dynamic>> _hierarquias = [
    {'id': 1, 'nome': 'Apenas App (Garçom/Cozinha)'},
    {'id': 2, 'nome': 'App e Desktop (Gerente)'},
    {'id': 3, 'nome': 'Apenas Desktop (Caixa/Admin)'},
  ];

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.usuario['full_name'] ?? '');
    _emailCtrl = TextEditingController(text: widget.usuario['email'] ?? '');
    _phoneCtrl = TextEditingController(text: widget.usuario['phone'] ?? widget.usuario['phone_number'] ?? '');
    
    if (widget.usuario['hierarquia'] != null) {
      _hierarquiaSelecionada = widget.usuario['hierarquia'] is int 
          ? widget.usuario['hierarquia'] 
          : int.tryParse(widget.usuario['hierarquia'].toString());
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_hierarquiaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione uma hierarquia")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await Supabase.instance.client.rpc('admin_update_user', params: {
        'target_user_id': widget.usuario['id'],
        'new_name': _nomeCtrl.text.trim(),
        'new_phone': _phoneCtrl.text.trim(),
        'new_hierarquia': _hierarquiaSelecionada,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário atualizado com sucesso!")),
      );
      
      widget.onSaved();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao editar: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: widget.onCancel,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Editar Usuário",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  TextFormField(
                    controller: _nomeCtrl,
                    decoration: _inputDecoration("Nome", Icons.person),
                    validator: (v) => v!.isEmpty ? "Informe o nome" : null,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emailCtrl,
                          readOnly: true,
                          decoration: _inputDecoration("E-mail (Não editável)", Icons.email)
                              .copyWith(fillColor: Colors.grey[200]),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneCtrl,
                          decoration: _inputDecoration("Telefone", Icons.phone),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<int>(
                    value: _hierarquiaSelecionada,
                    decoration: _inputDecoration("Hierarquia", Icons.work),
                    items: _hierarquias.map((h) {
                      return DropdownMenuItem<int>(
                        value: h['id'],
                        child: Text(h['nome']),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _hierarquiaSelecionada = v),
                    validator: (v) => v == null ? "Obrigatório" : null,
                  ),
                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.onCancel,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: const Text("Cancelar"),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _loading ? null : _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "Salvar Alterações",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.secondary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}