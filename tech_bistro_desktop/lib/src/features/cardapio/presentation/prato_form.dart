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

    final nome = _nomeCtrl.text;
    final valor = double.tryParse(_valorCtrl.text) ?? 0.0;
    final categoria = _categoriaCtrl.text;
    final descricao = _descricaoCtrl.text;

    try {
      if (widget.pratoExistente != null) {
        await service.editarPrato(
          id: widget.pratoExistente!['id'],
          nome: nome,
          valor: valor,
          categoria: categoria,
          descricao: descricao,
        );
      } else {
        await service.criarPrato(
          nome: nome,
          valor: valor,
          categoria: categoria,
          idEstabelecimento: widget.idEstabelecimento,
          descricao: descricao,
        );
      }
      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.textLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.pratoExistente != null ? 'Editar Prato' : 'Novo Prato',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildField(_nomeCtrl, 'Nome do prato'),
                const SizedBox(height: 12),
                _buildField(_valorCtrl, 'Valor', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _buildField(_categoriaCtrl, 'Categoria'),
                const SizedBox(height: 12),
                _buildField(_descricaoCtrl, 'Descrição', maxLines: 3),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _loading ? null : _salvar,
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Salvar'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
