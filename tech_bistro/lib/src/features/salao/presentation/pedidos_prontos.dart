import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../cozinha/presentation/historico_entregues.dart';

class PedidosProntosPage extends StatefulWidget {
  const PedidosProntosPage({super.key});

  @override
  State<PedidosProntosPage> createState() => _PedidosProntosPageState();
}

class _PedidosProntosPageState extends State<PedidosProntosPage> {
  final supabase = Supabase.instance.client;
  final Color primaryRed = const Color(0xFF840011);
  final Color backgroundLight = const Color(0xFFF8F9FA);

  List<dynamic> pedidosProntos = [];
  bool carregando = true;
  StreamSubscription<List<Map<String, dynamic>>>? _pedidosSubscription;

  @override
  void initState() {
    super.initState();
    carregarPedidos();
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    _pedidosSubscription?.cancel();
    super.dispose();
  }

  void _setupRealtimeListener() {
    _pedidosSubscription = supabase
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .listen((data) {
      carregarPedidos();
    });
  }

  Future<void> carregarPedidos() async {
    if (pedidosProntos.isEmpty) {
      setState(() => carregando = true);
    }
    
    try {
      final response = await supabase
          .from('pedidos')
          .select('id, id_mesa, qtd_pedido, pratos (nome_prato), observacao_pedido, alergia_pedido, horario_finalizacao, horario_entregue')
          .eq('status_pedido', 'pronto')
          .order('id', ascending: true);

      if (mounted) {
        setState(() {
          pedidosProntos = response;
          carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => carregando = false);
        _showSnackBar('Erro ao carregar pedidos: $e', isError: true);
      }
    }
  }

  Future<void> marcarComoEntregue(int idPedido, String prato, int qtd, int mesa) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => _buildModernDialog(
        title: 'Confirmar Entrega',
        content: Text(
          'Confirmar a entrega de ${qtd}x $prato da Mesa $mesa?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[700], fontSize: 16),
        ),
        icon: Icons.check_circle_outline,
        actions: [
          _buildDialogButton(
            label: 'Cancelar',
            color: Colors.grey[600]!,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          _buildDialogButton(
            label: 'Confirmar',
            color: primaryRed,
            isPrimary: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await supabase
            .from('pedidos')
            .update({
              'status_pedido': 'entregue',
              'horario_entregue': DateTime.now().toIso8601String().substring(11, 16),
            })
            .eq('id', idPedido);

        if (mounted) {
          _showSnackBar('Pedido marcado como entregue');
          carregarPedidos(); 
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar('Erro ao atualizar pedido: $e', isError: true);
        }
      }
    }
  }

  String formatarHora(String? horario) {
    if (horario == null || horario.isEmpty) return '--:--';
    try {
      if (horario.length >= 5) {
        return horario.substring(0, 5);
      }
      return horario;
    } catch (e) {
      return horario;
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? primaryRed : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pedidos Prontos',
                style: TextStyle(
                  color: primaryRed,
                  fontFamily: 'Nats',
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                ),
              ),
              Text(
                'Visão geral da cozinha',
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
              icon: Icon(Icons.history, color: primaryRed),
              tooltip: 'Histórico de Entregas',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoricoEntregaPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: carregando
          ? Center(child: CircularProgressIndicator(color: primaryRed))
          : pedidosProntos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Tudo entregue por enquanto!',
                        style: TextStyle(color: Colors.grey[400], fontSize: 18),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: pedidosProntos.length,
                  itemBuilder: (context, index) {
                    final pedido = pedidosProntos[index];
                    final prato = pedido['pratos']?['nome_prato'] ?? 'Prato';
                    final qtd = pedido['qtd_pedido'] ?? 0;
                    final mesa = pedido['id_mesa'];
                    final observacao = pedido['observacao_pedido'] as String?;
                    final alergia = pedido['alergia_pedido'] as String?;
                    final horario = formatarHora(pedido['horario_finalizacao'] as String?);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: primaryRed,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryRed.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => marcarComoEntregue(pedido['id'], prato, qtd, mesa),
                          child: Stack(
                            children: [
                              Positioned(
                                top: -20,
                                left: -20,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white.withOpacity(0.05),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'MESA $mesa',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time_rounded, size: 16, color: Colors.white70),
                                            const SizedBox(width: 4),
                                            Text(
                                              horario,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${qtd}x',
                                          style: const TextStyle(
                                            fontFamily: 'Nats',
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            prato,
                                            style: const TextStyle(
                                              fontFamily: 'Nats',
                                              fontSize: 26,
                                              color: Colors.white,
                                              height: 1.1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (observacao != null && observacao.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.info_outline, color: Colors.white70, size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                observacao,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    if (alergia != null && alergia.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.red[900]?.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'ALERGIA: ${alergia.toUpperCase()}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'ENTREGAR',
                                        style: TextStyle(
                                          color: primaryRed,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildModernDialog({
    required String title,
    required Widget content,
    required List<Widget> actions,
    IconData? icon,
    Color? iconColor,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (iconColor ?? primaryRed).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: iconColor ?? primaryRed),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 16),
            content,
            const SizedBox(height: 24),
            Row(
              children: actions.map((e) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: e))).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isPrimary ? color : Colors.white,
        foregroundColor: isPrimary ? Colors.white : color,
        side: isPrimary ? BorderSide.none : BorderSide(color: color.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}