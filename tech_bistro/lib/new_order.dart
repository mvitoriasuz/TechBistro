import 'package:flutter/material.dart';

class NovoPedido extends StatelessWidget {
  const NovoPedido({super.key});

  @override
  Widget build(BuildContext context) {
    const Color appBarColor = Color(0xFF840011);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tech Bistro',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Tela de Novo Pedido',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
