import 'package:flutter/material.dart';

class TermosUsoPage extends StatelessWidget {
  const TermosUsoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF840011);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Termos de Serviço",
          style: TextStyle(color: Colors.white, fontFamily: 'Nats'),
        ),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Termos de Serviço – TechBistro',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: 'Nats',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '1. Aceitação dos Termos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ao utilizar o aplicativo Tech Bistro, você concorda com estes Termos de Serviço e com a Política de Privacidade aplicável. Caso não concorde com qualquer parte destes termos, recomendamos que não utilize o aplicativo.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '2. Descrição do Serviço',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'O Tech Bistro é um sistema desenvolvido para uso interno de restaurantes, com o objetivo de facilitar:\n'
              'O registro e o gerenciamento de pedidos realizados nas mesas;\n'
              'A comunicação eficiente entre a equipe do salão e da cozinha;\n'
              'A sinalização de alergias, restrições alimentares e observação nos pedidos;\n'
              'A organização e controle de comandas e pagamentos.\n\n'
              'O app é destinado para uso profissional em estabelecimentos alimentícios.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '3. Responsabilidades dos Usuários',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ao utilizar o aplicativo, você se compromete a:\n'
              'Utilizar o sistema de forma ética e responsável;\n'
              'Fornecer informações corretas ao registrar pedidos e observações;\n'
              'Respeitar os direitos de outros usuários e colaboradores;\n'
              'Não utilizar o aplicativo para fins ilegais, ofensivos ou que violem normas do restaurante.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '4. Informações sobre Alergias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'O Tech Bistro permite o registro de alergias e restrições alimentares nos pedidos. No entanto, a responsabilidade por inserir essas informações corretamente é do usuário (cliente ou funcionário que registra o pedido). O restaurante e o aplicativo não se responsabilizam por omissões ou erros no preenchimento desses dados.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '5. Disponibilidade e Manutenção',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'O Tech Bistro poderá passar por atualizações ou manutenções sem aviso prévio. Embora busquemos garantir o funcionamento contínuo, não garantimos que o serviço esteja livre de falhas o tempo todo.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '6. Propriedade Intelectual',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Todos os direitos relacionados à marca, design, layout e funcionalidades do Tech Bistro são protegidos por leis de propriedade intelectual. É proibida a reprodução total ou parcial sem autorização.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '7. Alterações nos Termos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nos reservamos no direito de modificar estes Termos de Serviço a qualquer momento. Alterações importantes serão comunicadas dentro do próprio aplicativo.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '8. Contato e Suporte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dúvidas ou sugestões podem ser encaminhadas para a equipe técnica responsável ou para a administração do restaurante.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
