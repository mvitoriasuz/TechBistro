import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techbistro/src/ui/theme/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    carregarMesas();
  }

  Future<void> carregarMesas() async {
  try {
    final response = await Supabase.instance.client
        .from('pedidos')
        .select('id_mesa');

    if (response != null && response is List) {
      final ids = response
          .map<int>((m) => m['id_mesa'] as int)
          .toSet()
          .toList()
        ..sort();

      setState(() {
        mesas = ids;
      });
    }
  } catch (e) {
    print('Erro ao carregar mesas: $e');
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}
  Future<void> adicionarMesa() async {
    final novoNumero = mesas.isEmpty ? 1 : (mesas.reduce((a, b) => a > b ? a : b) + 1);

    try {
      await Supabase.instance.client.from('mesas').insert({'numero': novoNumero});
      setState(() {
        mesas.add(novoNumero);
      });
    } catch (e) {
      print('Erro ao adicionar mesa: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color appBarColor = Color(0xFF840011);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tech Bistro', style: TextStyle(color: Colors.white)),
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
            onPressed: () {},
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
        child: isLoading
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
                        child: InkWell(
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
                              children: [
                                Text(
                                  'Mesa ${mesas[index]}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final size = constraints.maxWidth * 0.8;
                                      return SvgPicture.asset(
                                        'assets/mesa.svg',
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
