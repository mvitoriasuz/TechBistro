import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tech_bistro_desktop/src/ui/theme/app_colors.dart';
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
  
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmaSenhaCtrl = TextEditingController();

  bool _loading = false;
  int? _hierarquiaSelecionada;

  final List<Map<String, dynamic>> _hierarquias = [
    {'id': 1, 'nome': 'Apenas App (Garçom/Cozinha)'},
    {'id': 2, 'nome': 'App e Desktop (Gerente)'},
    {'id': 3, 'nome': 'Apenas Desktop (Caixa/Admin)'},
  ];

  String _gerarCodigoUnico() {
    const chars = '0123456789';
    final rand = Random();
    return List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _criarUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    if (_hierarquiaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione uma hierarquia")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final adminUser = Supabase.instance.client.auth.currentUser;
      final estabelecimentoId = adminUser?.userMetadata?['estabelecimento_id'] ?? '';
      final cnpj = adminUser?.userMetadata?['cnpj'] ?? estabelecimentoId;

      final tempClient = SupabaseClient(
        'https://hliczkulyvskjjbigvvk.supabase.co',
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhsaWN6a3VseXZza2pqYmlndnZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY4MzgyMTEsImV4cCI6MjA2MjQxNDIxMX0.qexOzbr1wBH6D07pk2wgAJTI1GidrAXrpMZSZzl-0NE',
        authOptions: const AuthClientOptions(
          authFlowType: AuthFlowType.implicit,
        ),
      );

      String? codigoAcesso;
      if (_hierarquiaSelecionada == 1 || _hierarquiaSelecionada == 2) {
        codigoAcesso = _gerarCodigoUnico();
      }

      final response = await tempClient.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _senhaCtrl.text.trim(),
        data: {
          'full_name': _nomeCtrl.text.trim(),
          'hierarquia': _hierarquiaSelecionada,
          'phone': _phoneCtrl.text.trim(),
          'estabelecimento_id': estabelecimentoId,
          'cnpj': cnpj,
          'codigo_acesso': codigoAcesso,
          'role': 'funcionario',
        },
      );

      await tempClient.dispose();

      if (response.user != null) {
        if (codigoAcesso != null) {
            try {
                await Supabase.instance.client.from('users_profile').update({
                    'codigo_acesso': codigoAcesso,
                }).eq('id', response.user!.id);
            } catch (_) {} 
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuário criado com sucesso!")),
        );
        widget.onSaved();
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro de Auth: ${e.message}"), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao criar: $e"), backgroundColor: Colors.red),
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
                        "Novo Usuário",
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
                    decoration: _inputDecoration("Nome Completo", Icons.person),
                    validator: (v) => v!.isEmpty ? "Informe o nome" : null,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emailCtrl,
                          decoration: _inputDecoration("E-mail", Icons.email),
                          validator: (v) => v!.contains("@") ? null : "E-mail inválido",
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
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _senhaCtrl,
                          obscureText: true,
                          decoration: _inputDecoration("Senha", Icons.lock),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Informe a senha";
                            if (v.length < 6) return "Mínimo 6 caracteres";
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _confirmaSenhaCtrl,
                          obscureText: true,
                          decoration: _inputDecoration("Confirmar Senha", Icons.lock_outline),
                          validator: (v) {
                            if (v != _senhaCtrl.text) return "Senhas não conferem";
                            return null;
                          },
                        ),
                      ),
                    ],
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
                        onPressed: _loading ? null : _criarUsuario,
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
                                "Cadastrar",
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