import 'package:flutter/material.dart';
import '../../../../ui/theme/app_colors.dart';

class CnpjInput extends StatelessWidget {
  final TextEditingController controller;

  const CnpjInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontFamily: 'Nats'),
      decoration: InputDecoration(
        labelText: 'CNPJ',
        labelStyle: const TextStyle(
          fontFamily: 'Nats',
          color: AppColors.textDark,
        ),
        prefixIcon: const Icon(Icons.business, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
