import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_controller.dart';
import '../../settings/presentation/politica_privacidade.dart';
import '../../settings/presentation/termos_uso.dart';
import '../../settings/presentation/suporte.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = ref.watch(themeControllerProvider);
    
    const Color primaryColor = Color(0xFF840011);
    const Color darkRed = Color(0xFF510006);
    const Color backgroundColor = Color(0xFFF5F5F5);

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
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [darkRed, primaryColor],
              ),
            ),
          ),
          
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),

          Column(
            children: [
              const SafeArea(
                bottom: false,
                child: SizedBox(height: 60),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 28,
                          backgroundColor: primaryColor,
                          child: Icon(Icons.person, size: 32, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nome do Usuário',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Nats',
                              ),
                            ),
                            Text(
                              'usuario@restaurante.com',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Editar perfil em breve.')),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      children: [
                        _buildSectionHeader('APARÊNCIA', primaryColor),
                        _buildSettingsTile(
                          icon: Icons.dark_mode_outlined,
                          title: "Modo Escuro",
                          trailing: Switch(
                            value: themeProvider.isDarkMode,
                            activeColor: primaryColor,
                            onChanged: (value) {
                              ref.read(themeControllerProvider.notifier).toggleTheme(value);
                            },
                          ),
                        ),

                        _buildDivider(),
                        _buildSectionHeader('NOTIFICAÇÕES', primaryColor),
                        
                        _buildSettingsTile(
                          icon: Icons.notifications_active_outlined,
                          title: "Ativar Notificações",
                          trailing: Switch(
                            value: true,
                            activeColor: primaryColor,
                            onChanged: (val) {},
                          ),
                        ),
                        _buildSettingsTile(
                          icon: Icons.volume_up_outlined,
                          title: "Sons de Alerta",
                          trailing: Switch(
                            value: false,
                            activeColor: primaryColor,
                            onChanged: (val) {},
                          ),
                        ),

                        _buildDivider(),
                        _buildSectionHeader('GERAL', primaryColor),

                        _buildSettingsTile(
                          icon: Icons.language,
                          title: "Idioma",
                          subtitle: "Português (Brasil)",
                          onTap: () {},
                        ),
                        _buildSettingsTile(
                          icon: Icons.headset_mic_outlined,
                          title: "Suporte e Ajuda",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SuportePage()),
                          ),
                        ),

                        _buildDivider(),
                        _buildSectionHeader('SOBRE', primaryColor),

                        _buildSettingsTile(
                          icon: Icons.info_outline_rounded,
                          title: "Versão do App",
                          subtitle: "1.0.0 (Beta)",
                        ),
                        _buildSettingsTile(
                          icon: Icons.privacy_tip_outlined,
                          title: "Política de Privacidade",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PoliticaPrivacidadePage()),
                          ),
                        ),
                        _buildSettingsTile(
                          icon: Icons.description_outlined,
                          title: "Termos de Uso",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TermosUsoPage()),
                          ),
                        ),

                        const SizedBox(height: 30),
                        
                        Center(
                          child: Column(
                            children: [
                              Text(
                                "Desenvolvido por",
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Bruno • Maria Vitoria • Rafaela",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Text(
        title,
        style: TextStyle(
          color: color.withOpacity(0.8),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF8C0010), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xFF333333),
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13))
          : null,
      trailing: trailing ?? (onTap != null 
          ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey) 
          : null),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Divider(color: Colors.grey[200], height: 1),
    );
  }
}