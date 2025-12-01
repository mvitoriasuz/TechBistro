import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _imagemSelecionada;
  String? _urlImagemExistente;
  
  late PratoService service;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    service = PratoService();

    if (widget.pratoExistente != null) {
      _nomeCtrl.text = widget.pratoExistente!['nome_prato'] ?? '';
      _valorCtrl.text = widget.pratoExistente!['valor_prato']?.toString() ?? '';
      _categoriaCtrl.text = widget.pratoExistente!['categoria_prato'] ?? '';
      _descricaoCtrl.text = widget.pratoExistente!['descricao_prato'] ?? '';
      
      _urlImagemExistente = widget.pratoExistente!['imagem_prato'];
    }
  }

  Future<void> _selecionarImagem() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _imagemSelecionada = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Erro ao selecionar imagem: $e");
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      String? finalImageUrl = _urlImagemExistente;

      if (_imagemSelecionada != null) {
        finalImageUrl = await service.uploadImagem(_imagemSelecionada!);
      }

      if (widget.pratoExistente != null) {
        await service.editarPrato(
          id: widget.pratoExistente!['id'],
          nome: _nomeCtrl.text,
          valor: double.parse(_valorCtrl.text.replaceAll(',', '.')),
          categoria: _categoriaCtrl.text,
          descricao: _descricaoCtrl.text,
          imagemUrl: finalImageUrl,
        );
      } else {
        await service.criarPrato(
          nome: _nomeCtrl.text,
          valor: double.parse(_valorCtrl.text.replaceAll(',', '.')),
          categoria: _categoriaCtrl.text,
          idEstabelecimento: widget.idEstabelecimento,
          descricao: _descricaoCtrl.text,
          imagemUrl: finalImageUrl,
        );
      }

      widget.onSaved();
      if (mounted) Navigator.pop(context);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
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
              child: SingleChildScrollView(
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

                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _selecionarImagem,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                                image: _getDecorationImage(),
                              ),
                              child: _imagemSelecionada == null && _urlImagemExistente == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.add_a_photo,
                                            size: 40, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text("Adicionar Foto",
                                            style: TextStyle(color: Colors.grey)),
                                      ],
                                    )
                                  : null,
                            ),
                          ),
                          if (_imagemSelecionada != null || _urlImagemExistente != null)
                            TextButton.icon(
                              onPressed: _selecionarImagem,
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text("Alterar Imagem"),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _nomeCtrl,
                      decoration: _inputDecoration("Nome do prato", Icons.fastfood),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Informe o nome" : null,
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _valorCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration("Valor", Icons.attach_money),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Informe o valor";
                        if (double.tryParse(v.replaceAll(',', '.')) == null) {
                          return "Valor inválido";
                        }
                        return null;
                      },
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
      ),
    );
  }

  DecorationImage? _getDecorationImage() {
    if (_imagemSelecionada != null) {
      return DecorationImage(
        image: FileImage(_imagemSelecionada!),
        fit: BoxFit.cover,
      );
    }
    if (_urlImagemExistente != null && _urlImagemExistente!.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(_urlImagemExistente!),
        fit: BoxFit.cover,
      );
    }
    return null;
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