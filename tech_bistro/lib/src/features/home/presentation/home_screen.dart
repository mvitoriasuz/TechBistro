import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techbistro/src/features/salao/presentation/salao.dart';
import 'package:techbistro/src/features/salao/presentation/pedidos_prontos.dart';
import 'package:techbistro/src/features/settings/presentation/settings.dart';
import 'package:techbistro/src/features/cardapio/presentation/qr_code.dart';
import 'package:techbistro/src/features/settings/presentation/theme_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 1;
  int _readyOrdersCount = 0;
  StreamSubscription<List<Map<String, dynamic>>>? _readyOrdersSubscription;

  final List<Widget> _pages = [
    const UsersPage(),
    const SalaoPage(),
    const PedidosProntosPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _setupReadyOrdersRealtimeListener();
  }

  @override
  void dispose() {
    _readyOrdersSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchReadyOrdersCount() async {
    try {
      final response = await Supabase.instance.client
          .from('pedidos')
          .select('id')
          .eq('status_pedido', 'pronto');

      if (response is List && mounted) {
        setState(() {
          _readyOrdersCount = response.length;
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar contagem de pedidos: $e');
    }
  }

  void _setupReadyOrdersRealtimeListener() {
    _fetchReadyOrdersCount();
    _readyOrdersSubscription = Supabase.instance.client
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .listen(
          (List<Map<String, dynamic>> data) {
            _fetchReadyOrdersCount();
          },
          onError: (error) {
            debugPrint('Erro no listener de pedidos: $error');
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ref.watch(themeControllerProvider);
    final bool isDark = themeProvider.isDarkMode;
    
    final Color backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color activeColor = const Color(0xFF840011); 
    final Color inactiveColor = isDark ? Colors.grey[600]! : Colors.grey[400]!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildModernNavItem(
                icon: Icons.qr_code_scanner_rounded,
                label: "QR Code",
                index: 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              
              _buildModernNavItem(
                icon: Icons.table_restaurant_rounded,
                label: "Salão",
                index: 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),

              _buildModernNavItem(
                icon: Icons.notifications_none_rounded,
                activeIcon: Icons.notifications_active_rounded,
                label: "Pedidos",
                index: 2,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                badgeCount: _readyOrdersCount,
              ),

              _buildModernNavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: "Ajustes",
                index: 3,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Color activeColor,
    required Color inactiveColor,
    IconData? activeIcon,
    int badgeCount = 0,
  }) {
    final bool isSelected = _currentIndex == index;
    final IconData displayIcon = (isSelected && activeIcon != null) ? activeIcon : icon;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _currentIndex = index);
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              width: isSelected ? 40 : 0,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
              ),
            ),
            const Spacer(),

            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    displayIcon,
                    color: isSelected ? activeColor : inactiveColor,
                    size: 28,
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}