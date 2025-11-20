// import 'package:flutter/material.dart';
// import '../../../../ui/theme/app_colors.dart';
// import '../../controllers/auth_controller.dart';
// import '../widgets/cnpj_input.dart';
// import '../widgets/google_button.dart';

// class AuthPage extends StatefulWidget {
//   const AuthPage({super.key});

//   @override
//   State<AuthPage> createState() => _AuthPageState();
// }

// class _AuthPageState extends State<AuthPage> {
//   final controller = AuthController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: Center(
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           constraints: const BoxConstraints(maxWidth: 420),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.primaryDark.withOpacity(0.2),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'TECHBISTRO DESKTOP',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontFamily: 'Nats',
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primaryDark,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Acesse sua conta',
//                 style: TextStyle(
//                   fontFamily: 'Nats',
//                   fontSize: 18,
//                   color: AppColors.textDark,
//                 ),
//               ),
//               const SizedBox(height: 30),
//               CnpjInput(controller: controller.cnpjController),
//               const SizedBox(height: 25),
//               GoogleButton(onPressed: controller.signInWithGoogle),
//               const SizedBox(height: 20),
//               TextButton(
//                 onPressed: controller.loginWithCnpj,
//                 child: const Text(
//                   'Entrar com CNPJ',
//                   style: TextStyle(
//                     fontFamily: 'Nats',
//                     color: AppColors.primary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
