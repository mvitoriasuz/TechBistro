import 'package:flutter/material.dart';
import 'package:tech_bistro_desktop/src/features/cardapio/presentation/prato_list.dart';
import 'package:tech_bistro_desktop/src/features/usuario/presentation/usuario_list_view.dart';
import 'package:tech_bistro_desktop/src/ui/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<String> menuItems = [
    'Usuário',
    'Cardápio',
    'Relatório',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: AppColors.primaryDark,
            child: Column(
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'assets/images/logo.png',
                  height: 60,
                  width: 60,
                  errorBuilder: (context, error, stackTrace) {
                    print(error);
                    return const Text("ERRO AO CARREGAR IMAGEM");
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'Admin TechBistro',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 40),

                // Menu lateral
                Expanded(
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedIndex;
                      return InkWell(
                        onTap: () => setState(() => selectedIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.2)
                              : Colors.transparent,
                          child: Row(
                            children: [
                              Icon(
                                _getIconForIndex(index),
                                color: isSelected
                                    ? AppColors.secondary
                                    : AppColors.textLight.withOpacity(0.7),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                menuItems[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.secondary
                                      : AppColors.textLight.withOpacity(0.7),
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent, size: 22),
                  title: const Text('Sair', style: TextStyle(color: Colors.redAccent, fontSize: 15)),
                  onTap: () => Navigator.pushReplacementNamed(context, '/'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // Conteúdo principal
          Expanded(
            child: Container(
              color: AppColors.background,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  /// Troca de tela conforme clique no menu
  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return const UsuarioListView();
      case 1:
        return const PratoListPage(idEstabelecimento: '39555038000166');  
      case 2:
        return const Center(child: Text("Tela de Relatório", style: TextStyle(fontSize: 28)));
      default:
        return const Center(child: Text("Bem-vindo!", style: TextStyle(fontSize: 28)));
    }
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.person;
      case 1:
        return Icons.restaurant;
      case 2:
        return Icons.bar_chart;
      default:
        return Icons.circle;
    }
  }
}
