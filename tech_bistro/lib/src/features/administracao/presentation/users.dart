import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techbistro/src/constants/app_colors.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  String _getMenuUrl() {
    final user = Supabase.instance.client.auth.currentUser;
    final cnpj = user?.userMetadata?['cnpj']?.toString() ?? '';
    if (cnpj.isEmpty) return 'https://tech-bistro.vercel.app';
    return 'https://tech-bistro.vercel.app/cardapio/$cnpj';
  }

  String _getDisplayUrl(String fullUrl) {
    return fullUrl.replaceFirst('https://', '').replaceFirst('http://', '');
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          _showError(context, 'Não foi possível abrir o link');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Erro ao tentar abrir o navegador');
      }
    }
  }

  void _shareURL(String url) {
    Share.share('Acesse nosso cardápio digital: $url');
  }

  Future<void> _printMenu(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Erro ao abrir para impressão');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuUrl = _getMenuUrl();
    final displayUrl = _getDisplayUrl(menuUrl);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Cardápio Digital',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Nats',
            fontWeight: FontWeight.bold,
            fontSize: 30,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF510006),
                  Color(0xFF8C0010),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        top: kToolbarHeight + 20, left: 24, right: 24, bottom: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Compartilhe a experiência\nTechBistro',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                            letterSpacing: 0.5,
                            fontFamily: 'Nats',
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 320),
                          padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              QrImageView(
                                data: menuUrl,
                                version: QrVersions.auto,
                                size: 220.0,
                                padding: EdgeInsets.zero,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: AppColors.primary,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.circle,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              const SizedBox(height: 28),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.link_rounded,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        displayUrl,
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ActionButton(
                      icon: Icons.share_rounded,
                      label: 'Compartilhar',
                      color: AppColors.secondary,
                      backgroundColor: const Color(0xFFFFF3E0),
                      onTap: () => _shareURL(menuUrl),
                    ),
                    _ActionButton(
                      icon: Icons.open_in_browser_rounded,
                      label: 'Abrir Link',
                      color: Colors.white,
                      backgroundColor: AppColors.primary,
                      size: 72,
                      iconSize: 32,
                      hasShadow: true,
                      onTap: () => _launchURL(context, menuUrl),
                    ),
                    _ActionButton(
                      icon: Icons.print_rounded,
                      label: 'Imprimir',
                      color: AppColors.secondary,
                      backgroundColor: const Color(0xFFF5F5F5),
                      onTap: () => _printMenu(context, menuUrl),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final bool hasShadow;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
    this.size = 60,
    this.iconSize = 26,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: hasShadow
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: color,
              size: iconSize,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: hasShadow ? AppColors.primary : Colors.grey[700],
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}