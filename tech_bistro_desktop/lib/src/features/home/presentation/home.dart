import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tech_bistro_desktop/src/features/cardapio/presentation/prato_list.dart';
import 'package:tech_bistro_desktop/src/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:tech_bistro_desktop/src/features/usuario/presentation/usuario.dart';
import 'package:tech_bistro_desktop/src/features/suporte/presentation/suporte_admin_page.dart'; 
import 'package:tech_bistro_desktop/src/ui/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  int _pendingSupportCount = 0;
  Timer? _notificationTimer;

  final List<String> menuItems = [
    'Usuário',
    'Cardápio',
    'Relatório',
    'Suporte',
  ];

  @override
  void initState() {
    super.initState();
    _fetchNotificationCount();
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchNotificationCount();
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchNotificationCount() async {
    try {
      final response = await Supabase.instance.client
          .from('suporte_chamados')
          .count(CountOption.exact)
          .eq('status', 'pendente');
      
      if (mounted) {
        setState(() {
          _pendingSupportCount = response;
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar notificações: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
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
                    return const Icon(Icons.error, color: Colors.white);
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

                Expanded(
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedIndex;
                      final itemName = menuItems[index];
                      
                      return InkWell(
                        onTap: () {
                          setState(() => selectedIndex = index);
                          if (itemName == 'Suporte') {
                            _fetchNotificationCount();
                          }
                        },
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
                                itemName,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.secondary
                                      : AppColors.textLight.withOpacity(0.7),
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              if (itemName == 'Suporte' && _pendingSupportCount > 0) ...[
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    _pendingSupportCount > 9 ? '9+' : '$_pendingSupportCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ]
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

  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return const UsuarioPage();
      case 1:
        return const PratoListPage(idEstabelecimento: '39555038000166');  
      case 2:
        return const DashboardPage();
      case 3:
        return const SuporteAdminPage();
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
      case 3:
        return Icons.headset_mic;
      default:
        return Icons.circle;
    }
  }
}