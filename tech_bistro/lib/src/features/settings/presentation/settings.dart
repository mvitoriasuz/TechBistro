import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/presentation/login_screen.dart';
import 'theme_controller.dart';
import 'politica_privacidade.dart';
import 'termos_uso.dart';
import 'suporte.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = ref.watch(themeControllerProvider);
    final isDark = themeProvider.isDarkMode;

    final Color backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final Color surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color primaryRed = const Color(0xFF840011);
    final Color darkRed = const Color(0xFF510006);
    final Color textColor = isDark ? const Color(0xFFEEEEEE) : const Color(0xFF2D2D2D);
    final Color iconColor = isDark ? Colors.white70 : primaryRed;
    final Color subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final Color dividerColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    final user = Supabase.instance.client.auth.currentUser;
    final String userEmail = user?.email ?? 'email@techbistro.com';
    
    String userName = 'Usuário TechBistro';
    if (user != null && user.userMetadata != null) {
      final meta = user.userMetadata!;
      if (meta['nome'] != null && meta['nome'].toString().isNotEmpty) {
        userName = meta['nome'];
      } else if (meta['name'] != null && meta['name'].toString().isNotEmpty) {
        userName = meta['name'];
      } else if (meta['full_name'] != null && meta['full_name'].toString().isNotEmpty) {
        userName = meta['full_name'];
      } else {
        final emailName = userEmail.split('@').first;
        userName = emailName[0].toUpperCase() + emailName.substring(1);
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                    ? [Colors.black, const Color(0xFF300000)] 
                    : [darkRed, primaryRed],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ajustes Gerais',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Nats',
                                fontWeight: FontWeight.bold,
                                fontSize: 34,
                              ),
                            ),
                            Text(
                              'Personalize sua experiência',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Nats',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF333333) : Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: primaryRed,
                                child: Text(
                                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Nats',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                      fontFamily: 'Nats',
                                    ),
                                  ),
                                  Text(
                                    userEmail,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: subtitleColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.logout_rounded, color: primaryRed),
                              tooltip: 'Sair',
                              onPressed: () async {
                                await Supabase.instance.client.auth.signOut();
                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (route) => false,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      _buildSectionHeader('PREFERÊNCIAS', isDark),
                      _buildSettingsContainer(
                        surfaceColor,
                        [
                          _buildSwitchTile(
                            title: 'Modo Escuro',
                            icon: isDark ? Icons.dark_mode : Icons.light_mode,
                            value: isDark,
                            activeColor: primaryRed,
                            textColor: textColor,
                            iconColor: iconColor,
                            tileColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]!,
                            onChanged: (val) => ref.read(themeControllerProvider.notifier).toggleTheme(val),
                          ),
                          _buildDivider(dividerColor),
                          _buildSwitchTile(
                            title: 'Notificações',
                            icon: Icons.notifications_none_rounded,
                            value: true,
                            activeColor: primaryRed,
                            textColor: textColor,
                            iconColor: iconColor,
                            tileColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]!,
                            onChanged: (val) {},
                          ),
                        ],
                        isDark,
                      ),

                      const SizedBox(height: 24),

                      _buildSectionHeader('SUPORTE', isDark),
                      _buildSettingsContainer(
                        surfaceColor,
                        [
                          _buildNavTile(
                            title: 'Central de Ajuda',
                            icon: Icons.headset_mic_outlined,
                            textColor: textColor,
                            iconColor: iconColor,
                            tileColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]!,
                            arrowColor: subtitleColor,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SuportePage()),
                            ),
                          ),
                        ],
                        isDark,
                      ),

                      const SizedBox(height: 24),

                      _buildSectionHeader('SOBRE', isDark),
                      _buildSettingsContainer(
                        surfaceColor,
                        [
                          _buildNavTile(
                            title: 'Política de Privacidade',
                            icon: Icons.privacy_tip_outlined,
                            textColor: textColor,
                            iconColor: iconColor,
                            tileColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]!,
                            arrowColor: subtitleColor,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PoliticaPrivacidadePage()),
                            ),
                          ),
                          _buildDivider(dividerColor),
                          _buildNavTile(
                            title: 'Termos de Uso',
                            icon: Icons.description_outlined,
                            textColor: textColor,
                            iconColor: iconColor,
                            tileColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]!,
                            arrowColor: subtitleColor,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TermosUsoPage()),
                            ),
                          ),
                          _buildDivider(dividerColor),
                          _buildInfoTile(
                            title: 'Versão do App',
                            icon: Icons.info_outline_rounded,
                            value: '1.0.0 (Beta)',
                            textColor: textColor,
                            iconColor: iconColor,
                            valueColor: subtitleColor,
                            tileColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]!,
                          ),
                        ],
                        isDark,
                      ),

                      const SizedBox(height: 40),
                      
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'TechBistro',
                              style: TextStyle(
                                color: subtitleColor,
                                fontFamily: 'Nats',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Desenvolvido por Bruno, Maria Vitoria e Rafaela',
                              style: TextStyle(color: subtitleColor.withOpacity(0.7), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.grey[400] : const Color(0xFF840011),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(Color color, List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required Color activeColor,
    required Color textColor,
    required Color iconColor,
    required Color tileColor,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: Switch(
        value: value,
        activeColor: activeColor,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNavTile({
    required String title,
    required IconData icon,
    required Color textColor,
    required Color iconColor,
    required Color tileColor,
    required Color arrowColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: arrowColor),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required IconData icon,
    required String value,
    required Color textColor,
    required Color iconColor,
    required Color valueColor,
    required Color tileColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          color: valueColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 76,
      endIndent: 20,
      color: color,
    );
  }
}