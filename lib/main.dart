import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  
  await SupabaseService.initialize(
    url: 'https://bgryhkvorqgjlvmtbcht.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJncnloa3ZvcnFnamx2bXRiY2h0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ4NjQ4MDQsImV4cCI6MjA5MDQ0MDgwNH0.vyWYG8EAIG72TYmfAE23hOyomv6PT52P9LgzKWS2hcQ',
  );

  runApp(const ProviderScope(child: QuestLogApp()));
}

class QuestLogApp extends ConsumerWidget {
  const QuestLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'QuestLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
