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

    final List<Color> gradientColors = isDark 
        ? [Colors.black, const Color(0xFF300000)] 
        : [darkRed, primaryRed];

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
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
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.close_rounded, color: primaryRed),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
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
          Positioned(
            top: 40,
            left: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
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