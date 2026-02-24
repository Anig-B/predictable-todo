import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/firebase_service.dart';
import 'core/theme/app_theme.dart';
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
    debugPrint('Firebase initialization failed: $e');
  }

  final firebaseService = FirebaseService();
  await firebaseService.initLocalUser();

  // Initialize notification service (sets up channels, no permissions yet)
  // await NotificationService().initialize();

  runApp(MyApp(firebaseService: firebaseService));
}

class MyApp extends StatelessWidget {
  final FirebaseService firebaseService;

  const MyApp({super.key, required this.firebaseService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseService>.value(value: firebaseService),
        StreamProvider<String?>(
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
        theme: AppTheme.lightTheme,
        home: Container(
          decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
          child: const WelcomeWrapper(),
        ),
      ),
    );
  }
}

class WelcomeWrapper extends StatelessWidget {
  const WelcomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserModel?>();

    if (userProfile == null) {
      // The user profile will load almost immediately because it is seeded
      // locally in `initLocalUser`, but just in case of a tiny delay, show a loader.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userProfile.currentTeamId == null ||
        userProfile.currentTeamId!.isEmpty) {
      return const TeamSelectionScreen();
    }

    return const DashboardScreen();
  }
}
