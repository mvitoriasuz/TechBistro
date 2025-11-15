import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signIn() async {
    try {
      final result = await _googleSignIn.signIn();
      if (result != null) {
        debugPrint('Usuário logado: ${result.displayName}');
      } else {
        debugPrint('Login cancelado.');
      }
    } catch (e) {
      debugPrint('Erro no login Google: $e');
    }
  }
}
