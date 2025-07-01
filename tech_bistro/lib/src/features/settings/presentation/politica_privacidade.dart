import 'package:flutter/material.dart';

class PoliticaPrivacidadePage extends StatelessWidget {
  const PoliticaPrivacidadePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF840011);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Política de Privacidade",
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
              'Política de Privacidade – TechBistro',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: 'Nats',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '1. Coleta de Informações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'O aplicativo Tech Bistro coleta informações estritamente necessárias para o seu funcionamento interno em restaurantes, incluindo dados de pedidos (pratos, quantidades, observações, alergias), informações de mesa e registros de pagamento. Não coletamos dados pessoais sensíveis de clientes finais, apenas informações operacionais para a gestão do restaurante.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '2. Uso das Informações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'As informações coletadas são utilizadas exclusivamente para:\n'
              'Processar e gerenciar pedidos dentro do restaurante;\n'
              'Facilitar a comunicação entre as equipes de salão e cozinha;\n'
              'Controlar o status das mesas e pagamentos;\n'
              'Melhorar a eficiência operacional do estabelecimento.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '3. Compartilhamento de Informações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'O Tech Bistro não compartilha quaisquer informações coletadas com terceiros externos ao restaurante. Todos os dados permanecem no ambiente de banco de dados do restaurante (Supabase) e são acessíveis apenas por usuários autorizados do estabelecimento.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '4. Segurança dos Dados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Empregamos medidas de segurança razoáveis para proteger as informações contra acesso não autorizado, alteração, divulgação ou destruição. No entanto, nenhum sistema de segurança é impenetrável e não podemos garantir a segurança absoluta dos dados.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '5. Retenção de Dados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'As informações são retidas pelo tempo necessário para cumprir os propósitos para os quais foram coletadas, ou conforme exigido por lei. O restaurante é responsável pela gestão da retenção de seus próprios dados no Supabase.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '6. Alterações na Política de Privacidade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta Política de Privacidade pode ser atualizada periodicamente. Quaisquer alterações serão publicadas dentro do aplicativo. O uso continuado do aplicativo após a publicação de alterações constitui aceitação dessas alterações.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '7. Contato',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Para quaisquer dúvidas sobre esta Política de Privacidade, entre em contato com a administração do restaurante ou com a equipe de suporte técnico do Tech Bistro.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
