    import 'package:flutter/material.dart';

    // Placeholder para a tela de Histórico de Suporte
    class HistoricoSuportePage extends StatelessWidget {
      const HistoricoSuportePage({super.key});

      @override
      Widget build(BuildContext context) {
        const Color appBarColor = Color(0xFF840011);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Histórico de Suporte', style: TextStyle(color: Colors.white, fontFamily: 'Nats')),
            backgroundColor: appBarColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.white,
            ),
          ),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Nenhum histórico de suporte disponível.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    class SuportePage extends StatefulWidget {
      const SuportePage({super.key});

      @override
      State<SuportePage> createState() => _SuportePageState();
    }

    class _SuportePageState extends State<SuportePage> {
      String? _selectedTopic;
      final TextEditingController _descriptionController = TextEditingController();

      final List<String> _supportTopics = [
        'Problema Técnico',
        'Sugestão de Melhoria',
        'Dúvida sobre o Uso',
        'Erro de Pedido/Pagamento',
        'Outro',
      ];

      @override
      void dispose() {
        _descriptionController.dispose();
        super.dispose();
      }

      void _submitSupportRequest() {
        if (_selectedTopic == null || _descriptionController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, selecione um tema e descreva o problema.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        print('Tema Selecionado: $_selectedTopic');
        print('Descrição do Problema: ${_descriptionController.text}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sua solicitação de suporte foi enviada! Tema: $_selectedTopic'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpar campos após o envio
        setState(() {
          _selectedTopic = null;
          _descriptionController.clear();
        });
      }

      @override
      Widget build(BuildContext context) {
        const Color primaryColor = Color(0xFF840011);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Suporte",
              style: TextStyle(color: Colors.white, fontFamily: 'Nats'),
            ),
            backgroundColor: primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.white,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoricoSuportePage()),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Envie sua Solicitação de Suporte',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontFamily: 'Nats',
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Selecione o Tema',
                    labelStyle: TextStyle(color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2.0),
                    ),
                  ),
                  value: _selectedTopic,
                  items: _supportTopics.map((String topic) {
                    return DropdownMenuItem<String>(
                      value: topic,
                      child: Text(topic),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTopic = newValue;
                    });
                  },
                  icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Descreva seu problema ou sugestão',
                    labelStyle: TextStyle(color: primaryColor),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2.0),
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _submitSupportRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text(
                      'Enviar Solicitação',
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
