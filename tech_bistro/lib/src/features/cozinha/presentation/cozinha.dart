import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CozinhaPage extends StatefulWidget {
  const CozinhaPage({super.key});

  @override
  State<CozinhaPage> createState() => _CozinhaPageState();
}

class _CozinhaPageState extends State<CozinhaPage> {
  final supabase = Supabase.instance.client;

  final Color primaryRed = const Color(0xFF840011);
  final Color backgroundLight = const Color(0xFFF5F7FA);
  final Color textDark = const Color(0xFF2D2D2D);
  
  final Color statusPendente = const Color(0xFFFFF8E1);
  final Color textPendente = const Color(0xFFF57F17);
  
  final Color statusPreparo = const Color(0xFFE3F2FD);
  final Color textPreparo = const Color(0xFF1565C0);
  
  final Color statusPronto = const Color(0xFFE8F5E9);
  final Color textPronto = const Color(0xFF2E7D32);

  final Color bgErro = const Color(0xFFFFEBEE);
  final Color borderErro = const Color(0xFFD32F2F);

  List<dynamic> pedidosPendentes = [];
  List<dynamic> pedidosEmPreparo = [];
  List<dynamic> pedidosProntos = [];
  
  bool carregando = true;
  StreamSubscription<List<Map<String, dynamic>>>? _pedidosRealtimeSubscription;

  bool _expandPendente = true;
  bool _expandPreparo = true;
  bool _expandPronto = true;

  @override
  void initState() {
    super.initState();
    _loadAndListenPedidos();
  }

  @override
  void dispose() {
    _pedidosRealtimeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadAndListenPedidos() async {
    setState(() => carregando = true);
    try {
      final initialResponse = await supabase
          .from('pedidos')
          .select('*, pratos(*), observacao_pedido, alergia_pedido, horario_finalizacao, erro_reportado')
          .order('id', ascending: true);
      _updatePedidosState(initialResponse);
    } catch (e) {
      debugPrint('Erro: $e');
    } finally {
      if (mounted) setState(() => carregando = false);
    }

    _pedidosRealtimeSubscription = supabase
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) async {
          try {
            final updatedResponse = await supabase
                .from('pedidos')
                .select('*, pratos(*), observacao_pedido, alergia_pedido, horario_finalizacao, erro_reportado')
                .order('id', ascending: true);
            if (mounted) _updatePedidosState(updatedResponse);
          } catch (e) {
            debugPrint('Erro realtime: $e');
          }
        });
  }

  void _updatePedidosState(List<dynamic> allPedidos) {
    setState(() {
      pedidosPendentes = allPedidos.where((p) => p['status_pedido'] == 'pendente').toList();
      pedidosEmPreparo = allPedidos.where((p) => p['status_pedido'] == 'em_preparo').toList();
      pedidosProntos = allPedidos.where((p) => p['status_pedido'] == 'pronto').toList();
    });
  }

  Future<void> _atualizarStatusPedido(int idPedido, String novoStatus) async {
    try {
      Map<String, dynamic> updatePayload = {
        'status_pedido': novoStatus,
        'erro_reportado': null
      };
      
      if (novoStatus == 'pronto') {
        final now = DateTime.now();
        final timeString = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        updatePayload['horario_finalizacao'] = timeString;
      }

      await supabase.from('pedidos').update(updatePayload).eq('id', idPedido);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monitor de Cozinha',
                style: TextStyle(
                  color: primaryRed,
                  fontFamily: 'Nats',
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  height: 1.0,
                ),
              ),
              Text(
                'Acompanhamento em tempo real',
                style: TextStyle(
                  color: Colors.grey[600],
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
              icon: Icon(Icons.close, color: primaryRed, size: 26),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Fechar',
            ),
          ),
        ],
      ),
      body: carregando
          ? Center(child: CircularProgressIndicator(color: primaryRed))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: isPortrait 
                ? Column(children: _buildVerticalLayout())
                : Row(children: _buildHorizontalLayout()),
            ),
    );
  }

  List<Widget> _buildHorizontalLayout() {
    const double spacing = 12.0;
    return [
      Expanded(
        child: _buildColumn(
          title: 'PENDENTE',
          lista: pedidosPendentes,
          bgColor: statusPendente,
          accentColor: textPendente,
          statusAtual: 'pendente',
          isPortrait: false,
          isExpanded: true,
          onToggle: () {},
        ),
      ),
      const SizedBox(width: spacing),
      Expanded(
        child: _buildColumn(
          title: 'PREPARO',
          lista: pedidosEmPreparo,
          bgColor: statusPreparo,
          accentColor: textPreparo,
          statusAtual: 'em_preparo',
          isPortrait: false,
          isExpanded: true,
          onToggle: () {},
        ),
      ),
      const SizedBox(width: spacing),
      Expanded(
        child: _buildColumn(
          title: 'PRONTO',
          lista: pedidosProntos,
          bgColor: statusPronto,
          accentColor: textPronto,
          statusAtual: 'pronto',
          isPortrait: false,
          isExpanded: true,
          onToggle: () {},
        ),
      ),
    ];
  }

  List<Widget> _buildVerticalLayout() {
    const double spacing = 8.0;
    return [
      _expandPendente 
        ? Expanded(
            flex: 4,
            child: _buildColumn(
              title: 'PENDENTE',
              lista: pedidosPendentes,
              bgColor: statusPendente,
              accentColor: textPendente,
              statusAtual: 'pendente',
              isPortrait: true,
              isExpanded: true,
              onToggle: () => setState(() => _expandPendente = !_expandPendente),
            ),
          )
        : _buildColumn(
            title: 'PENDENTE',
            lista: pedidosPendentes,
            bgColor: statusPendente,
            accentColor: textPendente,
            statusAtual: 'pendente',
            isPortrait: true,
            isExpanded: false,
            onToggle: () => setState(() => _expandPendente = !_expandPendente),
          ),
      
      const SizedBox(height: spacing),

      _expandPreparo
        ? Expanded(
            flex: 4,
            child: _buildColumn(
              title: 'PREPARO',
              lista: pedidosEmPreparo,
              bgColor: statusPreparo,
              accentColor: textPreparo,
              statusAtual: 'em_preparo',
              isPortrait: true,
              isExpanded: true,
              onToggle: () => setState(() => _expandPreparo = !_expandPreparo),
            ),
          )
        : _buildColumn(
            title: 'PREPARO',
            lista: pedidosEmPreparo,
            bgColor: statusPreparo,
            accentColor: textPreparo,
            statusAtual: 'em_preparo',
            isPortrait: true,
            isExpanded: false,
            onToggle: () => setState(() => _expandPreparo = !_expandPreparo),
          ),

      const SizedBox(height: spacing),

      _expandPronto
        ? Expanded(
            flex: 3,
            child: _buildColumn(
              title: 'PRONTO',
              lista: pedidosProntos,
              bgColor: statusPronto,
              accentColor: textPronto,
              statusAtual: 'pronto',
              isPortrait: true,
              isExpanded: true,
              onToggle: () => setState(() => _expandPronto = !_expandPronto),
            ),
          )
        : _buildColumn(
            title: 'PRONTO',
            lista: pedidosProntos,
            bgColor: statusPronto,
            accentColor: textPronto,
            statusAtual: 'pronto',
            isPortrait: true,
            isExpanded: false,
            onToggle: () => setState(() => _expandPronto = !_expandPronto),
          ),
    ];
  }

  Widget _buildColumn({
    required String title,
    required List<dynamic> lista,
    required Color bgColor,
    required Color accentColor,
    required String statusAtual,
    required bool isPortrait,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPortrait ? Colors.transparent : Colors.white, 
        borderRadius: BorderRadius.circular(16),
        border: isPortrait ? null : Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: isPortrait 
            ? null 
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: isPortrait ? onToggle : null,
            borderRadius: isPortrait 
                  ? BorderRadius.circular(12) 
                  : const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: isPortrait ? 12 : 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isPortrait ? bgColor : Colors.white, 
                borderRadius: isPortrait 
                    ? BorderRadius.circular(12) 
                    : const BorderRadius.vertical(top: Radius.circular(16)),
                border: isPortrait 
                    ? Border.all(color: accentColor.withOpacity(0.3)) 
                    : Border(top: BorderSide(color: accentColor, width: 4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isPortrait) 
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded, 
                      color: accentColor, 
                      size: 24
                    )
                  else 
                    const SizedBox(width: 24),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isPortrait ? accentColor : textDark,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nats',
                          fontSize: isPortrait ? 18 : 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPortrait ? Colors.white : accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${lista.length}',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 24),
                ],
              ),
            ),
          ),
          
          if (isExpanded) ...[
            if (isPortrait) const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isPortrait ? Colors.transparent : bgColor.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: lista.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.check_circle_outline, 
                          color: isPortrait ? Colors.grey[300] : accentColor.withOpacity(0.2), 
                          size: 32
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(isPortrait ? 0 : 8),
                        itemCount: lista.length,
                        itemBuilder: (context, index) {
                          return _buildKitchenCard(
                            lista[index], 
                            accentColor, 
                            statusAtual, 
                            isPortrait
                          );
                        },
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKitchenCard(dynamic pedido, Color accentColor, String statusAtual, bool isPortrait) {
    final prato = pedido['pratos'] ?? {};
    final observacao = pedido['observacao_pedido'] as String?;
    final alergia = pedido['alergia_pedido'] as String?;
    final erroReportado = pedido['erro_reportado'] as String?;
    final horarioFinalizacao = pedido['horario_finalizacao'] as String?;

    bool temErro = erroReportado != null && erroReportado.isNotEmpty;
    Color cardBg = temErro ? bgErro : Colors.white;
    Color borderColor = temErro ? borderErro : Colors.transparent;
    double borderWidth = temErro ? 2.0 : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (statusAtual == 'pendente') {
              _atualizarStatusPedido(pedido['id'], 'em_preparo');
            } else if (statusAtual == 'em_preparo') {
              _atualizarStatusPedido(pedido['id'], 'pronto');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'MESA ${pedido['id_mesa']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (statusAtual == 'pronto' && horarioFinalizacao != null)
                      Text(
                        horarioFinalizacao,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    if (temErro)
                      const Icon(Icons.warning_rounded, color: Colors.red, size: 20),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pedido['qtd_pedido']}x ',
                      style: TextStyle(
                        fontFamily: 'Nats',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: temErro ? borderErro : accentColor,
                        height: 1.0,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        prato['nome_prato'] ?? 'Prato',
                        style: TextStyle(
                          fontFamily: 'Nats',
                          fontSize: 20,
                          height: 1.1,
                          color: textDark,
                        ),
                      ),
                    ),
                  ],
                ),

                if (temErro || (alergia != null && alergia.isNotEmpty) || (observacao != null && observacao.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (temErro)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.assignment_return, color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    erroReportado!.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (alergia != null && alergia.isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.no_food_outlined, color: Colors.red, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'ALERGIA: ${alergia.toUpperCase()}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (observacao != null && observacao.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(Icons.notes, size: 14, color: Colors.grey[600]),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    observacao,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontStyle: FontStyle.italic,
                                      fontSize: 13,
                                      fontFamily: 'Nats',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}