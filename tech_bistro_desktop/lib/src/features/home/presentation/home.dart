import 'package:flutter/material.dart';
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
    'Grupo de Acesso',
    'Cardápio',
    'Relatório',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar fixa
          Container(
            width: 220,
            color: AppColors.primaryDark,
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Icon(
                  Icons.restaurant_menu,
                  color: AppColors.textLight,
                  size: 50,
                ),
                const SizedBox(height: 10),
                const Text(
                  'TechBistro',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 40),

                // Itens do menu
                Expanded(
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedIndex;
                      return InkWell(
                        onTap: () {
                          setState(() => selectedIndex = index);
                          // Navegação opcional com rotas nomeadas
                          switch (index) {
                            case 0:
                              Navigator.pushNamed(context, '/usuario');
                              break;
                            case 1:
                              Navigator.pushNamed(context, '/hierarquia');
                              break;
                            case 2:
                              Navigator.pushNamed(context, '/cardapio');
                              break;
                            case 3:
                              Navigator.pushNamed(context, '/relatorio');
                              break;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
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
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
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

                //Botão sair
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                  title: const Text(
                    'Sair',
                    style: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // Conteúdo principal
          Expanded(
            child: Container(
              color: AppColors.background,
              child: Center(
                child: Text(
                  'Bem-vindo ao ${menuItems[selectedIndex]}',
                  style: const TextStyle(
                    fontSize: 28,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.person;
      case 1:
        return Icons.security;
      case 2:
        return Icons.restaurant;
      case 3:
        return Icons.bar_chart;
      default:
        return Icons.circle;
    }
  }
}
