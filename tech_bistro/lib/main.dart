import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color appBarColor = Color(0xFF840011);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Tech Bistro',
            style: TextStyle(color: Colors.white),
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
                },
              ),
              ListTile(
                leading: const Icon(Icons.kitchen),
                title: const Text('Relatórios'),
                onTap: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
        body: const Center(child: Text('Não há mesas abertas')),
      ),
    );
  }
}
