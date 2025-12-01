import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techbistro/src/features/settings/presentation/theme_controller.dart';

class CozinhaPage extends ConsumerStatefulWidget {
  const CozinhaPage({super.key});

  @override
  ConsumerState<CozinhaPage> createState() => _CozinhaPageState();
}

class _CozinhaPageState extends ConsumerState<CozinhaPage> {
  final supabase = Supabase.instance.client;

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
    final themeProvider = ref.watch(themeControllerProvider);
    final isDark = themeProvider.isDarkMode;
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    final Color backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final Color surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? const Color(0xFFEEEEEE) : const Color(0xFF2D2D2D);
    final Color primaryRed = const Color(0xFF840011);
    
    final Color statusPendenteBg = isDark ? const Color(0xFF3E2723) : const Color(0xFFFFF8E1);
    final Color statusPendenteText = isDark ? const Color(0xFFFFCC80) : const Color(0xFFF57F17);
    
    final Color statusPreparoBg = isDark ? const Color(0xFF0D47A1).withOpacity(0.3) : const Color(0xFFE3F2FD);
    final Color statusPreparoText = isDark ? const Color(0xFF90CAF9) : const Color(0xFF1565C0);
    
    final Color statusProntoBg = isDark ? const Color(0xFF1B5E20).withOpacity(0.3) : const Color(0xFFE8F5E9);
    final Color statusProntoText = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32);

    final Color errorBg = isDark ? const Color(0xFF451010) : const Color(0xFFFFEBEE);
    final Color errorBorder = const Color(0xFFD32F2F);
    final Color cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
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
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
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
              color: isDark ? const Color(0xFF333333) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                ? Column(
                    children: _buildVerticalLayout(
                      statusPendenteBg, statusPendenteText,
                      statusPreparoBg, statusPreparoText,
                      statusProntoBg, statusProntoText,
                      textColor, surfaceColor, cardColor, errorBg, errorBorder,
                    )
                  )
                : Row(
                    children: _buildHorizontalLayout(
                      statusPendenteBg, statusPendenteText,
                      statusPreparoBg, statusPreparoText,
                      statusProntoBg, statusProntoText,
                      textColor, surfaceColor, cardColor, errorBg, errorBorder,
                    )
                  ),
            ),
    );
  }

  List<Widget> _buildHorizontalLayout(
    Color bgPendente, Color txtPendente,
    Color bgPreparo, Color txtPreparo,
    Color bgPronto, Color txtPronto,
    Color textColor, Color surfaceColor, Color cardColor, Color errorBg, Color errorBorder,
  ) {
    const double spacing = 12.0;
    return [
      Expanded(
        child: _buildColumn(
          title: 'PENDENTE',
          lista: pedidosPendentes,
          bgColor: bgPendente,
          accentColor: txtPendente,
          statusAtual: 'pendente',
          isPortrait: false,
          isExpanded: true,
          surfaceColor: surfaceColor,
          cardColor: cardColor,
          textColor: textColor,
          errorBg: errorBg,
          errorBorder: errorBorder,
          onToggle: () {},
        ),
      ),
      const SizedBox(width: spacing),
      Expanded(
        child: _buildColumn(
          title: 'PREPARO',
          lista: pedidosEmPreparo,
          bgColor: bgPreparo,
          accentColor: txtPreparo,
          statusAtual: 'em_preparo',
          isPortrait: false,
          isExpanded: true,
          surfaceColor: surfaceColor,
          cardColor: cardColor,
          textColor: textColor,
          errorBg: errorBg,
          errorBorder: errorBorder,
          onToggle: () {},
        ),
      ),
      const SizedBox(width: spacing),
      Expanded(
        child: _buildColumn(
          title: 'PRONTO',
          lista: pedidosProntos,
          bgColor: bgPronto,
          accentColor: txtPronto,
          statusAtual: 'pronto',
          isPortrait: false,
          isExpanded: true,
          surfaceColor: surfaceColor,
          cardColor: cardColor,
          textColor: textColor,
          errorBg: errorBg,
          errorBorder: errorBorder,
          onToggle: () {},
        ),
      ),
    ];
  }

  List<Widget> _buildVerticalLayout(
    Color bgPendente, Color txtPendente,
    Color bgPreparo, Color txtPreparo,
    Color bgPronto, Color txtPronto,
    Color textColor, Color surfaceColor, Color cardColor, Color errorBg, Color errorBorder,
  ) {
    const double spacing = 8.0;
    return [
      _expandPendente 
        ? Expanded(
            flex: 4,
            child: _buildColumn(
              title: 'PENDENTE',
              lista: pedidosPendentes,
              bgColor: bgPendente,
              accentColor: txtPendente,
              statusAtual: 'pendente',
              isPortrait: true,
              isExpanded: true,
              surfaceColor: surfaceColor,
              cardColor: cardColor,
              textColor: textColor,
              errorBg: errorBg,
              errorBorder: errorBorder,
              onToggle: () => setState(() => _expandPendente = !_expandPendente),
            ),
          )
        : _buildColumn(
            title: 'PENDENTE',
            lista: pedidosPendentes,
            bgColor: bgPendente,
            accentColor: txtPendente,
            statusAtual: 'pendente',
            isPortrait: true,
            isExpanded: false,
            surfaceColor: surfaceColor,
            cardColor: cardColor,
            textColor: textColor,
            errorBg: errorBg,
            errorBorder: errorBorder,
            onToggle: () => setState(() => _expandPendente = !_expandPendente),
          ),
      
      const SizedBox(height: spacing),

      _expandPreparo
        ? Expanded(
            flex: 4,
            child: _buildColumn(
              title: 'PREPARO',
              lista: pedidosEmPreparo,
              bgColor: bgPreparo,
              accentColor: txtPreparo,
              statusAtual: 'em_preparo',
              isPortrait: true,
              isExpanded: true,
              surfaceColor: surfaceColor,
              cardColor: cardColor,
              textColor: textColor,
              errorBg: errorBg,
              errorBorder: errorBorder,
              onToggle: () => setState(() => _expandPreparo = !_expandPreparo),
            ),
          )
        : _buildColumn(
            title: 'PREPARO',
            lista: pedidosEmPreparo,
            bgColor: bgPreparo,
            accentColor: txtPreparo,
            statusAtual: 'em_preparo',
            isPortrait: true,
            isExpanded: false,
            surfaceColor: surfaceColor,
            cardColor: cardColor,
            textColor: textColor,
            errorBg: errorBg,
            errorBorder: errorBorder,
            onToggle: () => setState(() => _expandPreparo = !_expandPreparo),
          ),

      const SizedBox(height: spacing),

      _expandPronto
        ? Expanded(
            flex: 3,
            child: _buildColumn(
              title: 'PRONTO',
              lista: pedidosProntos,
              bgColor: bgPronto,
              accentColor: txtPronto,
              statusAtual: 'pronto',
              isPortrait: true,
              isExpanded: true,
              surfaceColor: surfaceColor,
              cardColor: cardColor,
              textColor: textColor,
              errorBg: errorBg,
              errorBorder: errorBorder,
              onToggle: () => setState(() => _expandPronto = !_expandPronto),
            ),
          )
        : _buildColumn(
            title: 'PRONTO',
            lista: pedidosProntos,
            bgColor: bgPronto,
            accentColor: txtPronto,
            statusAtual: 'pronto',
            isPortrait: true,
            isExpanded: false,
            surfaceColor: surfaceColor,
            cardColor: cardColor,
            textColor: textColor,
            errorBg: errorBg,
            errorBorder: errorBorder,
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
    required Color surfaceColor,
    required Color cardColor,
    required Color textColor,
    required Color errorBg,
    required Color errorBorder,
    required VoidCallback onToggle,
  }) {
    final bool isDark = ref.read(themeControllerProvider).isDarkMode;
    
    return Container(
      decoration: BoxDecoration(
        color: isPortrait ? Colors.transparent : surfaceColor, 
        borderRadius: BorderRadius.circular(16),
        border: isPortrait ? null : Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1)),
        boxShadow: isPortrait 
            ? null 
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
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
                color: isPortrait ? bgColor : surfaceColor, 
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
                          color: isPortrait ? accentColor : textColor,
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
                          color: isPortrait ? surfaceColor : accentColor.withOpacity(0.1),
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
                  color: isPortrait ? Colors.transparent : bgColor.withOpacity(isDark ? 0.2 : 0.5),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: lista.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.check_circle_outline, 
                          color: isPortrait ? (isDark ? Colors.white10 : Colors.grey[300]) : accentColor.withOpacity(0.2), 
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
                            isPortrait,
                            cardColor,
                            textColor,
                            errorBg,
                            errorBorder,
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

  Widget _buildKitchenCard(
    dynamic pedido, 
    Color accentColor, 
    String statusAtual, 
    bool isPortrait,
    Color cardColor,
    Color textColor,
    Color errorBg,
    Color errorBorder,
  ) {
    final prato = pedido['pratos'] ?? {};
    final observacao = pedido['observacao_pedido'] as String?;
    final alergia = pedido['alergia_pedido'] as String?;
    final erroReportado = pedido['erro_reportado'] as String?;
    final horarioFinalizacao = pedido['horario_finalizacao'] as String?;
    final bool isDark = ref.read(themeControllerProvider).isDarkMode;

    bool temErro = erroReportado != null && erroReportado.isNotEmpty;
    Color cardBg = temErro ? errorBg : cardColor;
    Color borderColor = temErro ? errorBorder : Colors.transparent;
    double borderWidth = temErro ? 2.0 : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
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
                        color: isDark ? Colors.white24 : Colors.black87,
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
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                        color: temErro ? errorBorder : accentColor,
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
                          color: textColor,
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
                              color: errorBg,
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
                              color: isDark ? Colors.white10 : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(Icons.notes, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    observacao,
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[300] : Colors.grey[800],
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