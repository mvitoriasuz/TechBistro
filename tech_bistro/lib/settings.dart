import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    const Color primaryColor = Color(0xFF840011);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações", style: TextStyle(color: Colors.white)),
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
              themeProvider.toggleTheme(value);
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
              onChanged: (bool value) {
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.volume_up_outlined),
            title: const Text("Sons de Notificação"),
            trailing: Switch(
              value: false,
              onChanged: (bool value) {
              },
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
            onTap: () {
            },
          ),
          ListTile(
            leading: const Icon(Icons.cached_outlined),
            title: const Text("Limpar Cache"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache limpo!')),
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
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text("Termos de Serviço"),
            onTap: () {
            },
          ),
          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Desenvolvedores do Projeto - idioma ainda nao funciona',
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
