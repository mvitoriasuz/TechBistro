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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações", style: TextStyle(color: Colors.white, fontFamily: 'Nats')),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.white,
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Conta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: primaryColor.withOpacity(0.2),
              child: const Icon(Icons.person, size: 28, color: Colors.black87),
            ),
            title: const Text('Nome do Usuário', style: TextStyle(fontSize: 16, color: Colors.black87)),
            subtitle: const Text('usuario@restaurante.com', style: TextStyle(fontSize: 14, color: Colors.grey)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Informações do usuário.')),
              );
            },
          ),
          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Tema',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text("Modo Escuro"),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              ref.read(themeControllerProvider.notifier).toggleTheme(value);
            },
          ),
          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Notificações',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text("Ativar Notificações"),
            trailing: Switch(
              value: true,
              onChanged: (bool value) {},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.volume_up_outlined),
            title: const Text("Sons de Notificação"),
            trailing: Switch(
              value: false,
              onChanged: (bool value) {},
            ),
          ),
          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Geral',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text("Idioma"),
            subtitle: const Text("Português (Brasil)"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.contact_support_outlined),
            title: const Text("Contato e Suporte"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SuportePage()),
              );
            },
          ),
          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Sobre',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("Versão do Aplicativo"),
            subtitle: const Text("1.0.0"),
          ),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text("Política de Privacidade"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PoliticaPrivacidadePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text("Termos de Serviço"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermosUsoPage()),
              );
            },
          ),
          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Desenvolvedores do Projeto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bruno Campagnol',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Maria Vitoria',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Rafaela de Jesus',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}