import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/presentation/login_screen.dart';
import '../../salao/presentation/salao.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SalaoPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'TECHBISTRO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontFamily: 'Nats',
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}