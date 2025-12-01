import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_controller.dart';

class PoliticaPrivacidadePage extends ConsumerWidget {
  const PoliticaPrivacidadePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = ref.watch(themeControllerProvider);
    final isDark = themeProvider.isDarkMode;

    final Color backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final Color surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color primaryRed = const Color(0xFF840011);
    final Color darkRed = const Color(0xFF510006);
    final Color textColor = isDark ? const Color(0xFFEEEEEE) : const Color(0xFF2D2D2D);
    final Color subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                    ? [Colors.black, const Color(0xFF300000)] 
                    : [darkRed, primaryRed],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),

          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Privacidade',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Nats',
                                fontWeight: FontWeight.bold,
                                fontSize: 34,
                              ),
                            ),
                            Text(
                              'Como cuidamos dos seus dados',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: primaryRed.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.shield_outlined, color: primaryRed, size: 30),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          _buildSection(
                            '1. Coleta de Informações',
                            'O aplicativo Tech Bistro coleta informações estritamente necessárias para o seu funcionamento interno em restaurantes, incluindo dados de pedidos, informações de mesa e registros de pagamento.',
                            textColor, subtitleColor,
                          ),
                          _buildDivider(isDark),
                          
                          _buildSection(
                            '2. Uso das Informações',
                            'As informações coletadas são utilizadas exclusivamente para:\n• Processar pedidos\n• Facilitar comunicação salão-cozinha\n• Controlar status das mesas\n• Melhorar a eficiência operacional',
                            textColor, subtitleColor,
                          ),
                          _buildDivider(isDark),

                          _buildSection(
                            '3. Compartilhamento',
                            'O Tech Bistro não compartilha quaisquer informações coletadas com terceiros externos ao restaurante. Todos os dados permanecem no ambiente do Supabase.',
                            textColor, subtitleColor,
                          ),
                          _buildDivider(isDark),

                          _buildSection(
                            '4. Segurança',
                            'Empregamos medidas de segurança razoáveis para proteger as informações contra acesso não autorizado, alteração, divulgação ou destruição.',
                            textColor, subtitleColor,
                          ),
                          _buildDivider(isDark),

                          _buildSection(
                            '5. Retenção',
                            'As informações são retidas pelo tempo necessário para cumprir os propósitos para os quais foram coletadas.',
                            textColor, subtitleColor,
                          ),
                          
                          const SizedBox(height: 30),
                          Center(
                            child: Text(
                              'Última atualização: Novembro 2024',
                              style: TextStyle(color: subtitleColor, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, Color titleColor, Color contentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: titleColor,
            fontFamily: 'Nats',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            color: contentColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        thickness: 1,
      ),
    );
  }
}