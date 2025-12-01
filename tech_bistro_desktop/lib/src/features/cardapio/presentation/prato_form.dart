import 'package:flutter/material.dart';
import 'package:tech_bistro_desktop/src/features/cardapio/data/prato_service.dart';
import 'package:tech_bistro_desktop/src/ui/theme/app_colors.dart';

class PratoForm extends StatefulWidget {
  final String idEstabelecimento;
  final Map<String, dynamic>? pratoExistente;
  final VoidCallback onSaved;

  const PratoForm({
    super.key,
    required this.idEstabelecimento,
    this.pratoExistente,
    required this.onSaved,
  });

  @override
  State<PratoForm> createState() => _PratoFormState();
}

class _PratoFormState extends State<PratoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _categoriaCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();

  bool _loading = false;
  late PratoService service;

  @override
  void initState() {
    super.initState();
    service = PratoService();

    if (widget.pratoExistente != null) {
      _nomeCtrl.text = widget.pratoExistente!['nome_prato'] ?? '';
      _valorCtrl.text = widget.pratoExistente!['valor_prato']?.toString() ?? '';
      _categoriaCtrl.text = widget.pratoExistente!['categoria_prato'] ?? '';
      _descricaoCtrl.text = widget.pratoExistente!['descricao_prato'] ?? '';
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await (widget.pratoExistente != null
          ? service.editarPrato(
              id: widget.pratoExistente!['id'],
              nome: _nomeCtrl.text,
              valor: double.parse(_valorCtrl.text),
              categoria: _categoriaCtrl.text,
              descricao: _descricaoCtrl.text,
            )
          : service.criarPrato(
              nome: _nomeCtrl.text,
              valor: double.parse(_valorCtrl.text),
              categoria: _categoriaCtrl.text,
              idEstabelecimento: widget.idEstabelecimento,
              descricao: _descricaoCtrl.text,
            ));

      widget.onSaved();
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
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
                      const Icon(Icons.restaurant, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        widget.pratoExistente != null
                            ? "Editar Prato"
                            : "Novo Prato",
                        style: const TextStyle(
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
                    decoration: _inputDecoration("Nome do prato", Icons.fastfood),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Informe o nome" : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _valorCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("Valor", Icons.attach_money),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Informe o valor" : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _categoriaCtrl,
                    decoration: _inputDecoration("Categoria", Icons.category),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Informe a categoria" : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _descricaoCtrl,
                    maxLines: 3,
                    decoration: _inputDecoration("Descrição", Icons.notes),
                  ),
                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        child: const Text("Cancelar"),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _loading ? null : _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Salvar",
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
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}
