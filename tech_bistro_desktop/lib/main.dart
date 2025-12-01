import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tech_bistro_desktop/auth_screen.dart';
import 'package:tech_bistro_desktop/src/features/dashboard/data/dashboard_service_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hliczkulyvskjjbigvvk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhsaWN6a3VseXZza2pqYmlndnZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY4MzgyMTEsImV4cCI6MjA2MjQxNDIxMX0.qexOzbr1wBH6D07pk2wgAJTI1GidrAXrpMZSZzl-0NE',
    debug: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

void testFetch() async {
  final svc = DashboardServiceApi();
  final hist = await svc.fetchHistorico();
  print('registros: ${hist.length}');
  final pagamentos = await svc.fetchPagamentosResumo();
  print('pagamentos: $pagamentos');
  final ticket = await svc.fetchTicketMedio();
  print('ticket medio: $ticket');
}
