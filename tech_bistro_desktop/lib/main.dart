import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:tech_bistro_desktop/src/features/home/presentation/home.dart';
import 'src/features/dashboard/presentation/dashboard.dart';
import 'src/features/hierarquia/presentation/hierarquia.dart';
import 'src/features/usuario/presentation/usuario.dart';
import 'auth_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // url: 'https://hliczkulyvskjjbigvvk.supabase.co',
    url: 'https://hvlpbzivywqfhpsonbrj.supabase.co',
    // anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhsaWN6a3VseXZza2pqYmlndnZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY4MzgyMTEsImV4cCI6MjA2MjQxNDIxMX0.qexOzbr1wBH6D07pk2wgAJTI1GidrAXrpMZSZzl-0NE',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh2bHBieml2eXdxZmhwc29uYnJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2NDIyNjMsImV4cCI6MjA3OTIxODI2M30.4XMGrEtej8amw1DacuGiRUMHurOnFCawkXXaiEMui4k',
  );
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      //depois precisa alterar para a tela de autenticação
      // home: AuthScreen(),
      home: HomePage(),
    );
  }
}