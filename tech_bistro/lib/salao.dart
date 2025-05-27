import 'package:flutter/material.dart';
import 'new_order.dart';

class SalaoPage extends StatefulWidget {
  const SalaoPage({super.key});

  @override
  State<SalaoPage> createState() => _SalaoPageState();
}

class _SalaoPageState extends State<SalaoPage> {
  final List<int> mesas = [];

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
              decoration: BoxDecoration(color: Color(0xFFA63D4A)),
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
              },
            ),
            ListTile(
              leading: const Icon(Icons.kitchen),
              title: const Text('Administração'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: mesas.isEmpty
            ? const Center(
                child: Text(
                  'Não há mesas abertas',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: mesas.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NovoPedido(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appBarColor,
                      ),
                      child: Text(
                        'Mesa ${mesas[index]}',
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            mesas.add(mesas.length + 1);
          });
        },
        backgroundColor: appBarColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
