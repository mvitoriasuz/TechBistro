import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tech_bistro_desktop/src/features/home/presentation/home.dart';
import 'package:tech_bistro_desktop/src/ui/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _senhaCtrl.text.trim(),
      );

      if (response.user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro inesperado: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.textLight,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TECHBISTRO',
                  style: TextStyle(
                    fontFamily: 'Nats',
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    fontSize: 34,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Acesso Administrativo',
                  style: TextStyle(
                    fontFamily: 'Nats',
                    color: AppColors.secondary,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontFamily: 'Nats', color: AppColors.textDark),
                        decoration: InputDecoration(
                          labelText: "E-mail",
                          labelStyle: TextStyle(fontFamily: 'Nats', color: AppColors.secondary),
                          prefixIcon: Icon(Icons.email_outlined, color: AppColors.secondary),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Digite o e-mail";
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _senhaCtrl,
                        obscureText: _obscure,
                        style: TextStyle(fontFamily: 'Nats', color: AppColors.textDark),
                        decoration: InputDecoration(
                          labelText: "Senha",
                          labelStyle: TextStyle(fontFamily: 'Nats', color: AppColors.secondary),
                          prefixIcon: Icon(Icons.lock_outline, color: AppColors.secondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.secondary,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Digite a senha";
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Entrar",
                                  style: TextStyle(
                                    fontFamily: 'Nats',
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
    );
  }
}