import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/firebase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/team/team_selection_screen.dart';
import 'models/user_model.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseService>(create: (_) => FirebaseService()),
        StreamProvider<User?>(
          create: (context) => context.read<FirebaseService>().authStateChanges,
          initialData: null,
        ),
        StreamProvider<UserModel?>(
          create: (context) =>
              context.read<FirebaseService>().userProfileStream,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Predictable Revenue Task Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    if (user == null) {
      return const LoginScreen();
    }

    final userProfile = context.watch<UserModel?>();

    if (userProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userProfile.currentTeamId == null ||
        userProfile.currentTeamId!.isEmpty) {
      return const TeamSelectionScreen();
    }

    return const DashboardScreen();
  }
}
