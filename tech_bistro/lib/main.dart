import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tech Bistro', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF098000F), 
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFFA63D4A),
                ),
                child: Text(
                  'Ambientes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.restaurant),
                title: const Text('Salão'),
                onTap: () {
                  Navigator.pop(context);
                  // link do salae
                },
              ),
              ListTile(
                leading: const Icon(Icons.kitchen),
                title: const Text('Cozinha'),
                onTap: () {
                  Navigator.pop(context);
                  // link da cozinha
                },
              ),
            ],
          ),
        ),
        body: const Center(
          child: Text('foto ou vetor de mesas, m3'),
        ),
      ),
    );
  }
}
