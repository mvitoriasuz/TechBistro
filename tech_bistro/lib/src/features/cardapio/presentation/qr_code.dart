import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:techbistro/src/features/settings/presentation/theme_controller.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
        if (context.mounted) _showError(context, 'Não foi possível abrir o link');
      }
    } catch (e) {
      if (context.mounted) _showError(context, 'Erro ao tentar abrir o navegador');
    }
  }

  void _shareURL(String url) {
    Share.share('Acesse nosso cardápio digital: $url');
  }

  Future<void> _printMenu(BuildContext context, String url) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final doc = pw.Document();

          doc.addPage(
            pw.Page(
              pageFormat: format,
              build: (pw.Context context) {
                return pw.Center(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'TechBistro',
                        style: pw.TextStyle(
                          fontSize: 40,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Acesse nosso Cardápio Digital',
                        style: const pw.TextStyle(fontSize: 20),
                      ),
                      pw.SizedBox(height: 40),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: url,
                        width: 250,
                        height: 250,
                      ),
                      pw.SizedBox(height: 40),
                      pw.Text(
                        url,
                        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                );
              },
            ),
          );

          return doc.save();
        },
      );
    } catch (e) {
      if (context.mounted) _showError(context, 'Erro ao gerar impressão: $e');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF840011),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ref.watch(themeControllerProvider);
    final isDark = themeProvider.isDarkMode;

    final menuUrl = _getMenuUrl();
    final displayUrl = _getDisplayUrl(menuUrl);
    
    final Color primaryRed = const Color(0xFF840011);
    final Color darkRed = const Color(0xFF510006);
    
    final List<Color> gradientColors = isDark 
        ? [Colors.black, const Color(0xFF300000)] 
        : [darkRed, primaryRed];

    final Color surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? const Color(0xFFEEEEEE) : const Color(0xFF2D2D2D);
    final Color linkBoxColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F1F2);
    final Color actionBtnColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200;
    final Color actionIconColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
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
                'Cardápio Digital',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nats',
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                ),
              ),
              Text(
                'Link público do restaurante',
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
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
            bottom: 100,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Compartilhe a experiência\nTechBistro',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white.withOpacity(0.95),
                                height: 1.3,
                                fontFamily: 'Nats',
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 300),
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 40,
                                    spreadRadius: -5,
                                    offset: const Offset(0, 20),
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
                                      eyeShape: QrEyeShape.circle, 
                                      color: Color(0xFF840011),
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.circle,
                                      color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: linkBoxColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: primaryRed.withOpacity(0.1)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.link_rounded,
                                          size: 18,
                                          color: Color(0xFF840011),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            displayUrl,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
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
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _ActionButton(
                            icon: Icons.share_rounded,
                            label: 'Enviar',
                            color: actionIconColor,
                            backgroundColor: actionBtnColor,
                            onTap: () => _shareURL(menuUrl),
                          ),
                          _ActionButton(
                            icon: Icons.open_in_browser_rounded,
                            label: 'Abrir',
                            color: Colors.white,
                            backgroundColor: primaryRed,
                            size: 70,
                            iconSize: 32,
                            hasGlow: true,
                            onTap: () => _launchURL(context, menuUrl),
                          ),
                          _ActionButton(
                            icon: Icons.print_rounded,
                            label: 'Imprimir',
                            color: actionIconColor,
                            backgroundColor: actionBtnColor,
                            onTap: () => _printMenu(context, menuUrl),
                          ),
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
  final bool hasGlow;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
    this.size = 55,
    this.iconSize = 24,
    this.hasGlow = false,
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
              gradient: hasGlow 
                  ? LinearGradient(
                      colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              boxShadow: hasGlow
                  ? [
                      BoxShadow(
                        color: backgroundColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
            ),
            child: Icon(
              icon,
              color: color,
              size: iconSize,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: 'Nats',
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}