import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/features/startup/presentation/splash_screen.dart';
import 'src/features/settings/presentation/theme_controller.dart';

final themeControllerProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  return ThemeProvider();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hliczkulyvskjjbigvvk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhsaWN6a3VseXZza2pqYmlndnZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY4MzgyMTEsImV4cCI6MjA2MjQxNDIxMX0.qexOzbr1wBH6D07pk2wgAJTI1GidrAXrpMZSZzl-0NE',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = ref.watch(themeControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeController.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}