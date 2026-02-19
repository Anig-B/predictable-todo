import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.bgColor,
              AppTheme.bgColor.withOpacity(0.8),
              AppTheme.primaryColor.withOpacity(0.2),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.trending_up_rounded,
              size: 100,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 20),
            Text(
              'Predictable Revenue',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Text(
              'Task Manager',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.greyColor,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final service = context.read<FirebaseService>();
                  await service.signInWithGoogle();
                },
                icon: const FaIcon(FontAwesomeIcons.google, size: 20),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Align your team with habits that drive growth.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.greyColor),
            ),
          ],
        ),
      ),
    );
  }
}
