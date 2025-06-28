import 'package:flutter/material.dart';
import 'package:techbistro/settings.dart';
import '../../mesa/presentation/mesa.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../cozinha/presentation/cozinha.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techbistro/src/ui/theme/app_colors.dart';

class SalaoPage extends StatefulWidget {
  const SalaoPage({super.key});

  @override
  State<SalaoPage> createState() => _SalaoPageState();
}

class _SalaoPageState extends State<SalaoPage> {
  List<int> mesas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarMesas();
  }

  Future<void> carregarMesas() async {
    try {
      final response = await Supabase.instance.client.from('mesas').select('numero');
      if (response != null && response is List) {
        final ids = response.map<int>((m) => m['numero'] as int).toList()..sort();
        setState(() => mesas = ids);
      }
    } catch (_) {} finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> adicionarMesa() async {
    final TextEditingController mesaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar nova mesa'),
          content: TextField(
            controller: mesaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Número da mesa',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final entrada = mesaController.text.trim();
                final numero = int.tryParse(entrada);

                if (numero == null || numero <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Número inválido.'), backgroundColor: Colors.red),
                  );
                  return;
                }

                if (mesas.contains(numero)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('A mesa $numero já está aberta.'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                try {
                  await Supabase.instance.client.from('mesas').insert({'numero': numero});
                  setState(() {
                    mesas.add(numero);
                    mesas.sort();
                  });
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao adicionar mesa: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

Future<void> mostrarAlergiasMesa(int numeroMesa) async {
  final supabase = Supabase.instance.client;

  try {
    final pedidos = await supabase
        .from('pedidos')
        .select('alergia_pedido')
        .eq('id_mesa', numeroMesa);

    final alergias = pedidos
        .map<String?>((p) => p['alergia_pedido']?.toString())
        .where((a) => a != null && a!.isNotEmpty)
        .toSet();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alergias da Mesa $numeroMesa'),
        content: alergias.isEmpty
            ? const Text('Nenhuma alergia registrada.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: alergias.map<Widget>((e) => Text('- $e')).toList(),
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

  Future<void> _confirmarExclusaoMesa(BuildContext context, int numeroMesa) async {
    final supabase = Supabase.instance.client;

    try {
      final pedidos = await supabase
          .from('pedidos')
          .select('qtd_pedido, pratos (valor_prato)')
          .eq('id_mesa', numeroMesa);

      double totalPedidos = pedidos.fold(0.0, (total, p) {
        final qtd = (p['qtd_pedido'] ?? 0) as int;
        final valor = (p['pratos']?['valor_prato'] ?? 0.0) as double;
        return total + qtd * valor;
      });

      final pagamentos = await supabase
          .from('pagamento')
          .select('valor_pagamento')
          .eq('id_mesa', numeroMesa);

      double totalPagamentos = pagamentos.fold(0.0, (total, pg) {
        return total + (pg['valor_pagamento'] ?? 0.0) as double;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
                if ((totalPedidos - totalPagamentos).abs() > 0.01) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('A mesa possui valores em aberto e não pode ser excluída.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await supabase.from('pedidos').delete().eq('id_mesa', numeroMesa);
                  await supabase.from('pagamento').delete().eq('id_mesa', numeroMesa);
                  await supabase.from('mesas').delete().eq('numero', numeroMesa);
                  setState(() => mesas.remove(numeroMesa));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mesa excluída com sucesso.'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir mesa: $e'), backgroundColor: Colors.red),
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
        SnackBar(content: Text('Erro ao validar exclusão: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color appBarColor = Color(0xFF840011);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TECHBISTRO', style: TextStyle(color: Colors.white, fontFamily: 'Nats')),
        backgroundColor: appBarColor,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
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
              child: Text('Ambientes', style: TextStyle(color: Colors.white, fontSize: 25)),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CozinhaPage()));
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : mesas.isEmpty
                ? const Center(child: Text('Não há mesas abertas', style: TextStyle(fontSize: 18)))
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MesaPage(numeroMesa: mesas[index]),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Mesa ${mesas[index]}',
                                        style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
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
                                icon: const Icon(Icons.more_vert, color: Colors.white),
                                onSelected: (value) {
                                  if (value == 'alergias') {
                                    mostrarAlergiasMesa(mesas[index]);
                                  } else if (value == 'excluir') {
                                    _confirmarExclusaoMesa(context, mesas[index]);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'alergias', child: Text('Ver alergias')),
                                  const PopupMenuItem(value: 'excluir', child: Text('Excluir mesa')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarMesa,
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
