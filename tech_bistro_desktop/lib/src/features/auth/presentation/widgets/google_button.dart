import 'package:flutter/material.dart';
import '../../../../ui/theme/app_colors.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.login, color: AppColors.textLight),
        label: const Text(
          'Entrar com Google',
          style: TextStyle(
            fontFamily: 'Nats',
            fontSize: 16,
            color: AppColors.textLight,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
      ),
    );
  }
}
