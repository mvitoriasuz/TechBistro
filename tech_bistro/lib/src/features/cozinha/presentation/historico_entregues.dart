import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoricoEntregaPage extends StatefulWidget {
  const HistoricoEntregaPage({super.key});

  @override
  State<HistoricoEntregaPage> createState() => _HistoricoEntregaPageState();
}

class _HistoricoEntregaPageState extends State<HistoricoEntregaPage> {
  final supabase = Supabase.instance.client;

  final Color primaryRed = const Color(0xFF840011);
  final Color backgroundLight = const Color(0xFFF8F9FA);

  List<dynamic> pedidosEntregues = [];
  bool carregandoHistorico = true;

  @override
  void initState() {
    super.initState();
    _carregarHistoricoEntregas();
  }

  Future<void> _carregarHistoricoEntregas() async {
    setState(() => carregandoHistorico = true);
    try {
      final response = await supabase
          .from('pedidos')
          .select('id, id_mesa, qtd_pedido, pratos (nome_prato), observacao_pedido, alergia_pedido, horario_entregue')
          .eq('status_pedido', 'entregue')
          .order('horario_entregue', ascending: false)
          .limit(50);

      if (mounted) {
        setState(() {
          pedidosEntregues = response;
          carregandoHistorico = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => carregandoHistorico = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: primaryRed),
        );
      }
    }
  }

  Future<bool> _processarDevolucao(int idPedido, String nomePrato) async {
    final TextEditingController motivoController = TextEditingController();

    final bool? confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.assignment_return_rounded, size: 32, color: primaryRed),
              ),
              const SizedBox(height: 20),
              Text(
                'Reportar Problema',
                style: TextStyle(
                  fontFamily: 'Nats',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryRed,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: Colors.grey[600], fontSize: 16, fontFamily: 'Nats'),
                  children: [
                    const TextSpan(text: 'O prato '),
                    TextSpan(
                      text: nomePrato,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const TextSpan(text: ' voltará para a cozinha.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: motivoController,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Qual o motivo? (Ex: Frio, Errado...)',
                  hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'Nats'),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Nats',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (motivoController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Informe o motivo!')),
                          );
                          return;
                        }
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'DEVOLVER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Nats',
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );

    if (confirmar == true) {
      try {
        await supabase.from('pedidos').update({
          'status_pedido': 'pendente',
          'erro_reportado': motivoController.text.trim(),
          'horario_entregue': null,
        }).eq('id', idPedido);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Pedido devolvido para análise!'),
              backgroundColor: primaryRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  String _formatarHorario(String? horario) {
    if (horario == null || horario.isEmpty) return '--:--';
    try {
      return horario.length >= 5 ? horario.substring(0, 5) : horario;
    } catch (e) {
      return horario;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Histórico',
                style: TextStyle(
                  color: primaryRed,
                  fontFamily: 'Nats',
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                ),
              ),
              Text(
                'Entregas finalizadas',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.close, color: primaryRed),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: carregandoHistorico
                ? Center(child: CircularProgressIndicator(color: primaryRed))
                : pedidosEntregues.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline_rounded, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma entrega registrada.',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontFamily: 'Nats',
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                        itemCount: pedidosEntregues.length,
                        itemBuilder: (context, index) {
                          final pedido = pedidosEntregues[index];
                          return Dismissible(
                            key: Key(pedido['id'].toString()),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await _processarDevolucao(
                                pedido['id'],
                                pedido['pratos']?['nome_prato'] ?? 'Prato',
                              );
                            },
                            onDismissed: (direction) {
                              setState(() {
                                pedidosEntregues.removeAt(index);
                              });
                            },
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: primaryRed,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryRed.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 32),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'REPORTAR ERRO',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.0,
                                      fontFamily: 'Nats',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                                ],
                              ),
                            ),
                            child: _buildHistoryCard(pedido),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(dynamic pedido) {
    final prato = pedido['pratos']?['nome_prato'] ?? 'Prato Desconhecido';
    final qtd = pedido['qtd_pedido'] ?? 0;
    final mesa = pedido['id_mesa'] ?? '?';
    final observacao = pedido['observacao_pedido'] as String?;
    final alergia = pedido['alergia_pedido'] as String?;
    final horario = _formatarHorario(pedido['horario_entregue'] as String?);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: primaryRed,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.table_restaurant_rounded, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Mesa $mesa',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nats',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.white70, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          horario,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Nats',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${qtd}x',
                        style: TextStyle(
                          fontFamily: 'Nats',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: primaryRed,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          prato,
                          style: const TextStyle(
                            fontFamily: 'Nats',
                            fontSize: 24,
                            height: 1.1,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if ((observacao != null && observacao.isNotEmpty) || (alergia != null && alergia.isNotEmpty)) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 12),
                    if (observacao != null && observacao.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(Icons.notes_rounded, size: 16, color: Colors.grey[400]),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                observacao,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Nats',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (alergia != null && alergia.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4F4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: primaryRed, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'ALERGIA: ${alergia.toUpperCase()}',
                              style: TextStyle(
                                color: primaryRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Deslize para reportar',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontFamily: 'Nats',
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_back_ios, size: 10, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}