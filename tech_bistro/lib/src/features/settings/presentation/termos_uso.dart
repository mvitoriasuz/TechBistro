import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_controller.dart';

class TermosUsoPage extends ConsumerWidget {
  const TermosUsoPage({super.key});

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
            left: -60,
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
                              'Termos de Uso',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Nats',
                                fontWeight: FontWeight.bold,
                                fontSize: 34,
                              ),
                            ),
                            Text(
                              'Regras e condições',
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
                              child: Icon(Icons.gavel_rounded, color: primaryRed, size: 30),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _buildSection(
                            '1. Aceitação',
                            'Ao utilizar o aplicativo Tech Bistro, você concorda com estes Termos de Serviço. Caso não concorde, recomendamos não utilizar o aplicativo.',
                            textColor, subtitleColor,
                          ),
                          _buildDivider(isDark),

                          _buildSection(
                            '2. O Serviço',
                            'O Tech Bistro facilita:\n• Registro de pedidos\n• Comunicação interna\n• Sinalização de alergias\n• Controle de comandas',
                            textColor, subtitleColor,
                          ),
                          _buildDivider(isDark),

                          _buildSection(
                            '3. Responsabilidades',
                            'Você se compromete a usar o sistema de forma ética, fornecer informações corretas e não violar normas do restaurante.',
                            textColor, subtitleColor,
                          ),
                          _buildDivider(isDark),

                          _buildSection(
                            '4. Alergias',
                            'A responsabilidade por inserir informações de alergia corretamente é do usuário. O app não se responsabiliza por omissões.',
                            textColor, subtitleColor,
                          ),
                          _buildDivider(isDark),

                          _buildSection(
                            '5. Propriedade Intelectual',
                            'Todos os direitos de design e funcionalidades são protegidos. É proibida a reprodução sem autorização.',
                            textColor, subtitleColor,
                          ),

                          const SizedBox(height: 30),
                          Center(
                            child: Text(
                              'Versão 1.0.0',
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