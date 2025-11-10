import 'package:flutter/material.dart';

class UsuarioPage extends StatelessWidget {
  const UsuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuario Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Usuario Page!'),
      ),
    );
  }
  
}