import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PratoForm extends StatefulWidget {
  final Map<String, dynamic>? prato;
  final int idEstabelecimento;
  final VoidCallback onCancel;
  final VoidCallback onSaved;

  const PratoForm({
    super.key,
    this.prato,
    required this.idEstabelecimento,
    required this.onCancel,
    required this.onSaved,
  });

  @override
  State<PratoForm> createState() => _PratoFormState();
}

class _PratoFormState extends State<PratoForm> {
  final client = Supabase.instance.client;

  final nomeCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final valorCtrl = TextEditingController();
  final categoriaCtrl = TextEditingController();
  final imagemCtrl = TextEditingController();

  bool ativo = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.prato != null) {
      nomeCtrl.text = widget.prato!['nome_prato'] ?? '';
      descCtrl.text = widget.prato!['descricao_prato'] ?? '';
      valorCtrl.text = widget.prato!['valor_prato']?.toString() ?? '0.00';
      ativo = widget.prato!['ativo'] ?? true;
      categoriaCtrl.text = widget.prato!['categoria_prato'] ?? '';
      imagemCtrl.text = widget.prato!['imagem_url'] ?? '';
    }
  }

  Future<void> salvar() async {
    final nome = nomeCtrl.text.trim();
    final valor = double.tryParse(valorCtrl.text.replaceAll(',', '.')) ?? 0.0;

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do prato')),
      );
      return;
    }

    setState(() => loading = true);

    final data = {
      'nome_prato': nome,
      'descricao_prato': descCtrl.text.trim(),
      'valor_prato': valor,
      'categoria_prato': categoriaCtrl.text.trim(),
      'id_estabelecimento': widget.idEstabelecimento,
      'ativo': ativo,
      'imagem_url': imagemCtrl.text.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      if (widget.prato == null) {
        await client.from('pratos').insert(data);
      } else {
        await client
            .from('pratos')
            .update(data)
            .eq('id', widget.prato!['id']);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prato salvo com sucesso!')),
        );
      }

      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar prato: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> excluir() async {
    if (widget.prato == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja excluir este prato?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await client.from('pratos').delete().eq('id', widget.prato!['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prato excluído')),
      );

      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.prato != null;

    return Center(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEdit ? 'Editar Prato' : 'Novo Prato',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A2A2A),
                  ),
                ),

                const SizedBox(height: 26),

                _input(nomeCtrl, 'Nome do prato'),
                const SizedBox(height: 16),

                _input(descCtrl, 'Descrição (opcional)', maxLines: 3),
                const SizedBox(height: 16),

                _input(
                  valorCtrl,
                  'Valor (ex: 12.50)',
                  keyboard: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),

                _input(
                  categoriaCtrl,
                  'Categoria (ex.: Entrada, Bebida, Sobremesa...)',
                ),
                const SizedBox(height: 16),

                _input(imagemCtrl, 'URL da imagem (opcional)'),
                const SizedBox(height: 16),

                SwitchListTile(
                  value: ativo,
                  onChanged: (v) => setState(() => ativo = v),
                  title: const Text('Ativo'),
                ),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: widget.onCancel,
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),

                    if (isEdit)
                      TextButton(
                        onPressed: excluir,
                        child: const Text(
                          'Excluir',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(width: 12),

                    ElevatedButton(
                      onPressed: loading ? null : salvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA58570),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 14),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            )
                          : const Text(
                              'Salvar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String label, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
