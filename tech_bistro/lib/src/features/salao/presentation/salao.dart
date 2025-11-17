import 'dart:async';
import 'package:flutter/material.dart';
import 'package:techbistro/src/features/settings/presentation/settings.dart';
import '../../mesa/presentation/mesa.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../cozinha/presentation/cozinha.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techbistro/src/constants/app_colors.dart';
import 'pedidos_prontos.dart';
import '../../administracao/presentation/users.dart';

class SalaoPage extends StatefulWidget {
  const SalaoPage({super.key});

  @override
  State<SalaoPage> createState() => _SalaoPageState();
}

class _SalaoPageState extends State<SalaoPage> {
  List<int> mesas = [];
  bool isLoading = true;
  int _readyOrdersCount = 0;
  StreamSubscription<List<Map<String, dynamic>>>? _mesasSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _readyOrdersSubscription;

  @override
  void initState() {
    super.initState();
    carregarMesas();
    _startMesasRealtimeListener();
    _setupReadyOrdersRealtimeListener();
  }

  @override
  void dispose() {
    _mesasSubscription?.cancel();
    _readyOrdersSubscription?.cancel();
    super.dispose();
  }

  Future<void> carregarMesas() async {
    try {
      final response = await Supabase.instance.client
          .from('mesas')
          .select('numero');
      if (response is List) {
        final ids =
            response.map<int>((m) => m['numero'] as int).toList()..sort();
        setState(() => mesas = ids);
      }
    } catch (e) {
      print('Erro ao carregar mesas: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _startMesasRealtimeListener() {
    _mesasSubscription = Supabase.instance.client
        .from('mesas')
        .stream(primaryKey: ['numero'])
        .listen(
          (List<Map<String, dynamic>> data) {
            print('Realtime de mesas acionado. Dados recebidos: $data');
            carregarMesas();
          },
          onError: (error) {
            print('Erro no listener de tempo real das mesas: $error');
          },
        );
  }

  Future<void> _fetchReadyOrdersCount() async {
    try {
      final response = await Supabase.instance.client
          .from('pedidos')
          .select('id')
          .eq('status_pedido', 'pronto');

      if (response is List) {
        setState(() {
          _readyOrdersCount = response.length;
        });
      }
    } catch (e) {
      print('Erro ao buscar contagem de pedidos prontos: $e');
    }
  }

  void _setupReadyOrdersRealtimeListener() {
    _fetchReadyOrdersCount();
    _readyOrdersSubscription = Supabase.instance.client
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .listen(
          (List<Map<String, dynamic>> data) {
            _fetchReadyOrdersCount();
          },
          onError: (error) {
            print('Erro no listener de tempo real de pedidos prontos: $error');
          },
        );
  }

  Future<void> adicionarMesa() async {
    final TextEditingController mesaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        final TextEditingController mesaController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: const [
                  Icon(Icons.add_circle_outline, color: AppColors.secondary),
                  SizedBox(width: 8),
                  Text(
                    'Adicionar nova mesa',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: mesaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Número da mesa',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final numero = int.tryParse(value ?? '');
                    if (numero == null || numero <= 0) {
                      return 'Informe um número válido.';
                    }
                    if (mesas.contains(numero)) {
                      return 'A mesa $numero já está aberta.';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final numero = int.parse(mesaController.text.trim());

                    try {
                      await Supabase.instance.client.from('mesas').insert({
                        'numero': numero,
                      });
                      await carregarMesas();
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao adicionar mesa: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> mostrarAlergiasMesa(int numeroMesa) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('pedidos')
          .select('alergia_pedido')
          .eq('id_mesa', numeroMesa);

      final alergias =
          response
              .map<String?>((p) => p['alergia_pedido']?.toString())
              .where((a) => a != null && a!.isNotEmpty)
              .toSet();

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Alergias da Mesa $numeroMesa'),
              content:
                  alergias.isEmpty
                      ? const Text('Nenhuma alergia registrada.')
                      : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            alergias.map<Widget>((e) => Text('- $e')).toList(),
                      ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar alergias: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmarExclusaoMesa(
    BuildContext context,
    int numeroMesa,
  ) async {
    final supabase = Supabase.instance.client;

    try {
      final pedidos = await supabase
          .from('pedidos')
          .select('qtd_pedido, pratos (valor_prato)')
          .eq('id_mesa', numeroMesa);

      double totalPedidos = pedidos.fold(0.0, (total, p) {
        final qtd = (p['qtd_pedido'] ?? 0);
        final valorRaw = p['pratos']?['valor_prato'];

        double valor = 0.0;
        if (valorRaw is int) {
          valor = valorRaw.toDouble();
        } else if (valorRaw is double) {
          valor = valorRaw;
        }

        double quantidade = 0.0;
        if (qtd is int) {
          quantidade = qtd.toDouble();
        } else if (qtd is double) {
          quantidade = qtd;
        }
        return total + (quantidade * valor);
      });

      final pagamentos = await supabase
          .from('pagamento')
          .select('valor_pagamento')
          .eq('id_mesa', numeroMesa);

      double totalPagamentos = pagamentos.fold(0.0, (total, pg) {
        final valorPagamentoRaw = pg['valor_pagamento'];
        double valorPagamento = 0.0;
        if (valorPagamentoRaw is int) {
          valorPagamento = valorPagamentoRaw.toDouble();
        } else if (valorPagamentoRaw is double) {
          valorPagamento = valorPagamentoRaw;
        }
        return total + valorPagamento;
      });

      print('Mesa $numeroMesa:');
      print('Total de Pedidos: R\$ ${totalPedidos.toStringAsFixed(2)}');
      print('Total Pago: R\$ ${totalPagamentos.toStringAsFixed(2)}');
      print('Diferença (abs): ${(totalPedidos - totalPagamentos).abs()}');
      print(
        'Condição de bloqueio: ${(totalPedidos - totalPagamentos).abs() > 0.01}',
      );

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Confirmar exclusão'),
              content: Text(
                'Deseja realmente excluir a mesa $numeroMesa?\n\n'
                'Total do pedido: R\$ ${totalPedidos.toStringAsFixed(2)}\n'
                'Total pago: R\$ ${totalPagamentos.toStringAsFixed(2)}\n\n'
                'Essa ação apagará todos os pedidos e pagamentos da mesa.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if ((totalPedidos - totalPagamentos).abs() > 0.001) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'A mesa possui valores em aberto e não pode ser excluída.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      await supabase
                          .from('pedidos')
                          .delete()
                          .eq('id_mesa', numeroMesa);
                      await supabase
                          .from('pagamento')
                          .delete()
                          .eq('id_mesa', numeroMesa);
                      await supabase
                          .from('mesas')
                          .delete()
                          .eq('numero', numeroMesa);
                      setState(() => mesas.remove(numeroMesa));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mesa excluída com sucesso.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao excluir mesa: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao validar exclusão: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color appBarColor = Color(0xFF840011);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Techbistro',
          style: TextStyle(color: Colors.white, fontFamily: 'Nats'),
        ),
        backgroundColor: appBarColor,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF8C0010)),
              child: Text(
                'Ambientes',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: const Text('Salão'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.kitchen),
              title: const Text('Cozinha'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CozinhaPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Administração'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : mesas.isEmpty
                ? const Center(
                  child: Text(
                    'Não há mesas abertas',
                    style: TextStyle(fontSize: 18),
                  ),
                )
                : GridView.builder(
                  itemCount: mesas.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    return Card(
                      color: appBarColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          MesaPage(numeroMesa: mesas[index]),
                                ),
                              );
                              carregarMesas();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Mesa ${mesas[index]}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final size = constraints.maxWidth * 0.6;
                                        return SvgPicture.asset(
                                          'assets/mesa.svg',
                                          fit: BoxFit.contain,
                                          width: size,
                                          height: size,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              onSelected: (value) {
                                if (value == 'alergias') {
                                  mostrarAlergiasMesa(mesas[index]);
                                } else if (value == 'excluir') {
                                  _confirmarExclusaoMesa(context, mesas[index]);
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    PopupMenuItem<String>(
                                      value: 'alergias',
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.warning_rounded,
                                            color: Colors.orange,
                                          ),
                                          SizedBox(width: 8),
                                          Text('Ver alergias'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'excluir',
                                      child: Row(
                                        children: const [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Excluir mesa'),
                                        ],
                                      ),
                                    ),
                                  ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            heroTag: 'user_btn',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UsersPage()),
              );
            },
            backgroundColor: AppColors.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          FloatingActionButton(
            heroTag: 'add_mesa_btn',
            onPressed: adicionarMesa,
            backgroundColor: AppColors.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                heroTag: 'notifications_btn',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PedidosProntosPage(),
                    ),
                  );
                },
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                ),
              ),
              if (_readyOrdersCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Text(
                      '$_readyOrdersCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
