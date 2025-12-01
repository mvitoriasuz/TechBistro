import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tech_bistro_desktop/src/ui/theme/app_colors.dart'; 

class SuporteAdminPage extends StatefulWidget {
  const SuporteAdminPage({super.key});

  @override
  State<SuporteAdminPage> createState() => _SuporteAdminPageState();
}

class _SuporteAdminPageState extends State<SuporteAdminPage> {
  List<Map<String, dynamic>> chamados = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    carregarChamados();
  }

  Future<void> carregarChamados() async {
    setState(() => loading = true);
    try {
      final supabase = Supabase.instance.client;
      
      final List<dynamic> data = await supabase
          .from('suporte_chamados')
          .select()
          .order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          chamados = List<Map<String, dynamic>>.from(data);
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar chamados: $e")),
        );
      }
    }
  }

  Future<void> atualizarStatus(String id, String novoStatus) async {
    try {
      await Supabase.instance.client
          .from('suporte_chamados')
          .update({'status': novoStatus})
          .eq('id', id);

      await carregarChamados();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Status atualizado com sucesso!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar: $e")),
      );
    }
  }

  void _abrirDetalhes(Map<String, dynamic> chamado) {
    showDialog(
      context: context,
      builder: (context) {
        final isPendente = (chamado['status'] as String? ?? '').toLowerCase() == 'pendente';
        
        return AlertDialog(
          title: Text(chamado['topico'] ?? 'Detalhes do Chamado'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow("Data:", _formatDate(chamado['created_at'])),
                const SizedBox(height: 10),
                _infoRow("Status Atual:", chamado['status']?.toUpperCase() ?? '-'),
                const SizedBox(height: 20),
                const Text("Descrição:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(chamado['descricao'] ?? ''),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fechar"),
            ),
            if (isPendente)
              ElevatedButton.icon(
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text("Marcar como Resolvido", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () => atualizarStatus(chamado['id'].toString(), 'resolvido'),
              ),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text(value),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Central de Suporte",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A2A2A),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: carregarChamados,
                tooltip: "Atualizar lista",
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : chamados.isEmpty
                    ? const Center(child: Text("Nenhum chamado registrado."))
                    : SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                          columns: const [
                            DataColumn(label: Text("Data")),
                            DataColumn(label: Text("Tópico")),
                            DataColumn(label: Text("Status")),
                            DataColumn(label: Text("Ações")),
                          ],
                          rows: chamados.map((c) {
                            final status = (c['status'] as String? ?? 'pendente').toLowerCase();
                            final isPendente = status == 'pendente';

                            return DataRow(
                              cells: [
                                DataCell(Text(_formatDate(c['created_at']))),
                                DataCell(
                                  SizedBox(
                                    width: 200, 
                                    child: Text(c['topico'] ?? '-', overflow: TextOverflow.ellipsis)
                                  )
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isPendente ? Colors.orange[100] : Colors.green[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isPendente ? Colors.orange : Colors.green
                                      ),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        color: isPendente ? Colors.orange[900] : Colors.green[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.visibility, color: Colors.blue),
                                    onPressed: () => _abrirDetalhes(c),
                                    tooltip: "Ver Detalhes",
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}