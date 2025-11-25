import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techbistro/src/constants/app_colors.dart';
import '../../mesa/presentation/mesa.dart';
import '../../cozinha/presentation/cozinha.dart';

class SalaoPage extends StatefulWidget {
  const SalaoPage({super.key});

  @override
  State<SalaoPage> createState() => _SalaoPageState();
}

class _SalaoPageState extends State<SalaoPage> {
  List<int> mesas = [];
  bool isLoading = true;
  StreamSubscription<List<Map<String, dynamic>>>? _mesasSubscription;
  
  final Color primaryRed = const Color(0xFF840011);
  final Color darkRed = const Color(0xFF510006);
  final Color backgroundLight = const Color(0xFFF8F9FA);
  
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
              const Text(
                'Qual o número da nova mesa?',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: mesaController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryRed),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '00',
                  hintStyle: TextStyle(color: Colors.grey[300]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
            color: Colors.grey[600]!,
            onPressed: () => Navigator.pop(context),
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
    try {
      final pedidos = await supabase.from('pedidos').select('qtd_pedido, pratos (valor_prato)').eq('id_mesa', numeroMesa);
      
      showDialog(
        context: context,
        builder: (context) => _buildModernDialog(
          title: 'Excluir Mesa $numeroMesa?',
          icon: Icons.delete_forever_rounded,
          iconColor: Colors.red[700],
          content: Text(
            'Todos os pedidos e histórico desta mesa serão apagados. Deseja continuar?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700], height: 1.5),
          ),
          actions: [
             _buildDialogButton(
              label: 'Voltar',
              color: Colors.grey[600]!,
              onPressed: () => Navigator.pop(context),
            ),
             _buildDialogButton(
              label: 'Excluir',
              color: Colors.red,
              isPrimary: true,
              onPressed: () async {
                try {
                  await supabase.from('mesas').delete().eq('numero', numeroMesa);
                  setState(() => mesas.remove(numeroMesa));
                  Navigator.pop(context);
                  _showSnackBar('Mesa $numeroMesa excluída.', isError: false);
                } catch(e) {
                  // erro silencioso ou log
                }
              },
            ),
          ],
        ),
      );
    } catch (e) {
      _showSnackBar('Erro de conexão.', isError: true);
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
                            Icon(Icons.storefront_outlined, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma mesa ativa',
                              style: TextStyle(color: Colors.grey[400], fontSize: 18),
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
          ),
        ),
      ),
    );
  }
  
  Widget _buildMesaCardRed(int numero) {
    return Container(
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
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MesaPage(numeroMesa: numero)),
            ).then((_) => carregarMesas());
          },
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (value) {
                          if (value == 'excluir') _confirmarExclusaoMesa(numero);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'excluir',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                SizedBox(width: 10),
                                Text('Excluir', style: TextStyle(color: Colors.red)),
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'MESA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          '$numero',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Nats',
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