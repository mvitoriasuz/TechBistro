import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techbistro/src/features/settings/presentation/theme_controller.dart';
import '../../mesa/presentation/mesa.dart';
import '../../cozinha/presentation/cozinha.dart';

class SalaoPage extends ConsumerStatefulWidget {
  const SalaoPage({super.key});

  @override
  ConsumerState<SalaoPage> createState() => _SalaoPageState();
}

class _SalaoPageState extends ConsumerState<SalaoPage> {
  List<int> mesas = [];
  bool isLoading = true;
  StreamSubscription<List<Map<String, dynamic>>>? _mesasSubscription;
  
  @override
  void initState() {
    super.initState();
    carregarMesas();
    _startMesasRealtimeListener();
  }

  @override
  void dispose() {
    _mesasSubscription?.cancel();
    super.dispose();
  }

  Future<void> carregarMesas() async {
    try {
      final response = await Supabase.instance.client
          .from('mesas')
          .select('numero');
      if (response is List) {
        final ids = response.map<int>((m) => m['numero'] as int).toList()..sort();
        if (mounted) setState(() => mesas = ids);
      }
    } catch (e) {
      debugPrint('Erro ao carregar mesas: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _startMesasRealtimeListener() {
    _mesasSubscription = Supabase.instance.client
        .from('mesas')
        .stream(primaryKey: ['numero'])
        .listen((data) => carregarMesas());
  }

  Future<void> adicionarMesa() async {
    final TextEditingController mesaController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    final isDark = ref.read(themeControllerProvider).isDarkMode;
    final primaryRed = const Color(0xFF840011);
    final inputFill = isDark ? const Color(0xFF2C2C2C) : Colors.grey[50];
    final hintColor = isDark ? Colors.grey[500] : Colors.grey[300];
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    showDialog(
      context: context,
      builder: (context) => _buildModernDialog(
        title: 'Adicionar Mesa',
        icon: Icons.add_business_rounded,
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Qual o número da nova mesa?',
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: mesaController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryRed, fontFamily: 'Nats'),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '00',
                  hintStyle: TextStyle(color: hintColor, fontFamily: 'Nats'),
                  filled: true,
                  fillColor: inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: primaryRed, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
                validator: (value) {
                  final numero = int.tryParse(value ?? '');
                  if (numero == null || numero <= 0) return 'Inválido';
                  if (mesas.contains(numero)) return 'Já existe';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          _buildDialogButton(
            label: 'Cancelar',
            color: isDark ? Colors.grey[600]! : Colors.grey[600]!,
            onPressed: () => Navigator.pop(context),
            isPrimary: false,
          ),
          _buildDialogButton(
            label: 'Adicionar',
            color: primaryRed,
            isPrimary: true,
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                await Supabase.instance.client.from('mesas').insert({
                  'numero': int.parse(mesaController.text.trim()),
                });
                await carregarMesas();
                if (mounted) Navigator.pop(context);
              } catch (e) {
                _showSnackBar('Erro ao adicionar: $e', isError: true);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarExclusaoMesa(int numeroMesa) async {
    final supabase = Supabase.instance.client;
    final isDark = ref.read(themeControllerProvider).isDarkMode;
    final primaryRed = const Color(0xFF840011);
    final textColor = isDark ? const Color(0xFFEEEEEE) : const Color(0xFF2D2D2D);

    try {
      final pedidosResponse = await supabase
          .from('pedidos')
          .select('qtd_pedido, status_pedido, pratos (nome_prato, valor_prato)')
          .eq('id_mesa', numeroMesa);
      
      final pagamentosResponse = await supabase
          .from('pagamento')
          .select('valor_pagamento, forma_pagamento')
          .eq('id_mesa', numeroMesa);

      double totalConsumido = 0.0;
      bool temPedidosPendentes = false;
      
      final List<Map<String, dynamic>> itensParaHistorico = [];

      for (var p in pedidosResponse) {
        final qtd = (p['qtd_pedido'] as num).toInt();
        final valor = (p['pratos']?['valor_prato'] as num).toDouble();
        final status = p['status_pedido'] as String;
        
        totalConsumido += (qtd * valor);
        
        itensParaHistorico.add({
          'prato': p['pratos']?['nome_prato'],
          'qtd': qtd,
          'valor_unitario': valor,
          'status': status
        });

        if (status != 'entregue') {
          temPedidosPendentes = true;
        }
      }

      double totalPago = 0.0;
      final List<Map<String, dynamic>> pagsParaHistorico = [];
      
      for (var pag in pagamentosResponse) {
        final valor = (pag['valor_pagamento'] as num).toDouble();
        totalPago += valor;
        pagsParaHistorico.add(pag);
      }

      final faltaPagar = totalConsumido - totalPago;

      if (temPedidosPendentes) {
        if (mounted) {
           _showBloqueioDialog(
            'Pedidos não entregues', 
            'Esta mesa possui pedidos pendentes, em preparo ou prontos (não entregues). Certifique-se de que tudo foi entregue ao cliente.'
          );
        }
        return;
      }

      if (faltaPagar > 0.1) { 
        if (mounted) {
           _showBloqueioDialog(
            'Pagamento Pendente', 
            'A conta ainda não foi totalmente paga. Faltam R\$ ${faltaPagar.toStringAsFixed(2)}.'
          );
        }
        return;
      }
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => _buildModernDialog(
            title: 'Encerrar Atendimento?',
            icon: Icons.assignment_turned_in_rounded,
            iconColor: primaryRed,
            content: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 16, height: 1.5, fontFamily: 'Roboto'),
                children: [
                  const TextSpan(text: 'A Mesa '),
                  TextSpan(text: '$numeroMesa', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  const TextSpan(text: ' será arquivada.\nTodos os pedidos foram entregues e a conta quitada.'),
                ],
              ),
            ),
            actions: [
              _buildDialogButton(
                label: 'Voltar',
                color: isDark ? Colors.grey[600]! : Colors.grey[600]!,
                onPressed: () => Navigator.pop(context),
                isPrimary: false,
              ),
              _buildDialogButton(
                label: 'FINALIZAR',
                color: primaryRed,
                isPrimary: true,
                onPressed: () async {
                  try {
                    await supabase.from('historico_mesas').insert({
                      'numero_mesa': numeroMesa,
                      'valor_total': totalConsumido,
                      'itens_pedido': itensParaHistorico,
                      'pagamentos': pagsParaHistorico,
                    });

                    await supabase.from('pagamento').delete().eq('id_mesa', numeroMesa);
                    await supabase.from('pedidos').delete().eq('id_mesa', numeroMesa);
                    await supabase.from('mesas').delete().eq('numero', numeroMesa);
                    
                    setState(() => mesas.remove(numeroMesa));
                    if(mounted) {
                      Navigator.pop(context);
                      _showSnackBar('Mesa $numeroMesa finalizada com sucesso.', isError: false);
                    }
                  } catch(e) {
                    if (mounted) {
                       Navigator.pop(context);
                       _showSnackBar('Erro ao finalizar: $e', isError: true);
                    }
                  }
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Erro de conexão: $e', isError: true);
    }
  }

  void _showBloqueioDialog(String title, String msg) {
    final isDark = ref.read(themeControllerProvider).isDarkMode;
    final primaryRed = const Color(0xFF840011);

    showDialog(
      context: context,
      builder: (context) => _buildModernDialog(
        title: title,
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.amber[800],
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], height: 1.5, fontSize: 15),
        ),
        actions: [
          _buildDialogButton(
            label: 'Entendi',
            color: primaryRed,
            isPrimary: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    final primaryRed = const Color(0xFF840011);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: isError ? primaryRed : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ref.watch(themeControllerProvider);
    final isDark = themeProvider.isDarkMode;

    final Color backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final Color surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color primaryRed = const Color(0xFF840011);
    final Color subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[500]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Salão Principal',
                style: TextStyle(
                  color: primaryRed,
                  fontFamily: 'Nats',
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                ),
              ),
              Text(
                'Visão geral das mesas',
                style: TextStyle(
                  color: subtitleColor,
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
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.soup_kitchen_outlined, color: primaryRed),
              tooltip: 'Cozinha',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CozinhaPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: primaryRed))
                : mesas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.storefront_outlined, size: 60, color: Colors.grey[400]),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma mesa ativa',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[400], 
                                fontSize: 18, 
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                        itemCount: mesas.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) => _buildMesaCardRed(mesas[index]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: adicionarMesa,
        backgroundColor: primaryRed,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nova Mesa',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
  
  Widget _buildMesaCardRed(int numero) {
    final isDark = ref.read(themeControllerProvider).isDarkMode;
    final primaryRed = const Color(0xFF840011);
    final darkRed = const Color(0xFF510006);
    final darkText = const Color(0xFF2D2D2D);

    final List<Color> gradientColors = isDark 
        ? [Colors.black, const Color(0xFF300000)] 
        : [darkRed, primaryRed];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MesaPage(numeroMesa: numero)),
              ).then((_) => carregarMesas());
            },
            child: Stack(
              children: [
                Positioned(
                  top: -30,
                  right: -30,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withOpacity(0.05),
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, right: 8),
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_horiz, color: Colors.white70),
                          padding: EdgeInsets.zero,
                          elevation: 4,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onSelected: (value) {
                            if (value == 'excluir') _confirmarExclusaoMesa(numero);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'excluir',
                              child: Row(
                                children: [
                                  Icon(Icons.assignment_turned_in_outlined, color: darkText, size: 20), 
                                  const SizedBox(width: 12),
                                  Text('Finalizar Mesa', style: TextStyle(color: darkText, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SvgPicture.asset(
                          'assets/mesa.svg',
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          placeholderBuilder: (_) => const Icon(Icons.table_restaurant, size: 50, color: Colors.white),
                        ),
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'MESA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 2.0,
                            ),
                          ),
                          Text(
                            '$numero',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Nats',
                              height: 1.0
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
    final isDark = ref.read(themeControllerProvider).isDarkMode;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFEEEEEE) : const Color(0xFF2D2D2D);
    final primaryRed = const Color(0xFF840011);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (iconColor ?? primaryRed).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: iconColor ?? primaryRed),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            content,
            const SizedBox(height: 32),
            Row(
              children: actions.map((e) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: e))).toList(),
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
    final isDark = ref.read(themeControllerProvider).isDarkMode;
    final surfaceColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]!;

    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0),
        ),
      );
    } else {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: surfaceColor,
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      );
    }
  }
}