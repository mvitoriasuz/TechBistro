import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewOrder extends StatefulWidget {
  const NewOrder({super.key});

  @override
  State<NewOrder> createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final supabase = Supabase.instance.client;
  List<dynamic> pratos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPratos();
  }

  Future<void> fetchPratos() async {
    try {
      final response = await supabase.from('pratos').select();
      setState(() {
        pratos = response;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar pratos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color appBarColor = Color(0xFF840011);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Novo Pedido',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Adicionar Itens ao Pedido',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: pratos.length,
                      itemBuilder: (context, index) {
                        final prato = pratos[index];
                        return Card(
                          child: ListTile(
                            title: Text(prato['nome_prato']),
                            subtitle: Text('${prato['categoria_prato']} - R\$ ${prato['valor_prato'].toStringAsFixed(2)}'),
                            trailing: const Icon(Icons.add),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appBarColor,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pedido enviado!')),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'CONFIRMAR PEDIDO',
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
