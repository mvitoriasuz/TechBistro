import 'package:flutter/material.dart';

class CozinhaPage extends StatelessWidget {
  const CozinhaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cozinha'),
        backgroundColor: const Color(0xFF840011),
      ),
      body: const Center(
        child: Text( 
          'Tela da Cozinha',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
