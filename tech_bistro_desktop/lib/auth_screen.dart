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
    final supabase = Supabase.instance.client;

    final response = await supabase.auth.signInWithPassword(
      email: _emailCtrl.text.trim(),
      password: _senhaCtrl.text.trim(),
    );

    // LOGIN FUNCIONOU
    if (response.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
      return;
    }

    // FALHA DE LOGIN
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Credenciais inválidas")),
    );

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erro ao entrar: $e")),
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
                // TÍTULO
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
                  'Acesso ao sistema',
                  style: TextStyle(
                    fontFamily: 'Nats',
                    color: AppColors.secondary,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 40),

                // FORM
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(
                        controller: _emailCtrl,
                        label: "E-mail",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Digite seu e-mail";
                          if (!v.contains("@")) return "E-mail inválido";
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildField(
                        controller: _senhaCtrl,
                        label: "Senha",
                        icon: Icons.lock_outline,
                        obscureText: _obscure,
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Digite sua senha";
                          if (v.length < 3) return "Senha curta demais";
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.secondary,
                          ),
                          onPressed: () {
                            setState(() => _obscure = !_obscure);
                          },
                        ),
                      ),
                      const SizedBox(height: 30),

                      // BOTÃO ENTRAR
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  "Entrar",
                                  style: TextStyle(
                                    fontFamily: 'Nats',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
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

  // CAMPO ESTILIZADO
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(
        fontFamily: 'Nats',
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Nats',
          color: AppColors.secondary,
        ),
        prefixIcon: Icon(icon, color: AppColors.secondary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
