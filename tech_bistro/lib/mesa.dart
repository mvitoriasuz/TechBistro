import 'package:flutter/material.dart';
import 'new_order.dart';

class Mesa extends StatelessWidget {
  const Mesa({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Resumo da Mesa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text( 
              'Cliente: Js',
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appBarColor,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewOrder()),
                  );
                },
                child: const Text(
                  'NOVO PEDIDO',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
