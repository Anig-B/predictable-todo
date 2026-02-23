import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';

class TeamSelectionScreen extends StatefulWidget {
  const TeamSelectionScreen({super.key});

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  final _teamNameController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Almost there!',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'To get started, create a new team or join an existing one.',
                    style: TextStyle(color: AppTheme.greyColor, fontSize: 16),
                  ),
                  const SizedBox(height: 60),
                  _buildOptionCard(
                    context,
                    title: 'Create a Team',
                    subtitle: 'Start a new workspace for your pod.',
                    icon: Icons.group_add_rounded,
                    color: AppTheme.primaryColor,
                    onTap: _showCreateTeamDialog,
                  ),
                  const SizedBox(height: 20),
                  _buildOptionCard(
                    context,
                    title: 'Join a Team',
                    subtitle: 'Enter an invite code from your manager.',
                    icon: Icons.door_front_door_rounded,
                    color: AppTheme.successColor,
                    onTap: _showJoinTeamDialog,
                  ),
                  const Spacer(),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          context.read<FirebaseService>().signOut(),
                      child: const Text(
                        'Sign out',
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.greyColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.greyColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTeamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Team'),
        content: TextField(
          controller: _teamNameController,
          decoration: const InputDecoration(
            hintText: 'e.g. Outbound Sales Pod',
            labelText: 'Team Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(onPressed: _createTeam, child: const Text('Create')),
        ],
      ),
    );
  }

  void _showJoinTeamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Team'),
        content: TextField(
          controller: _inviteCodeController,
          decoration: const InputDecoration(
            hintText: 'Enter code',
            labelText: 'Invite Code',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(onPressed: _joinTeam, child: const Text('Join')),
        ],
      ),
    );
  }

  Future<void> _createTeam() async {
    if (_teamNameController.text.isEmpty) return;

    setState(() => _isLoading = true);
    Navigator.pop(context); // Close dialog

    try {
      final user = context.read<UserModel?>();
      if (user == null) throw Exception('User not logged in');

      await context.read<FirebaseService>().createTeam(
        user.uid,
        _teamNameController.text.trim(),
      );

      if (!mounted) return;
      // Success is handled by auth state change -> dashboard redirect
    } catch (e) {
      if (!mounted) return;
      debugPrint('CREATE_TEAM_ERROR_DUMP: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinTeam() async {
    if (_inviteCodeController.text.isEmpty) return;

    setState(() => _isLoading = true);
    Navigator.pop(context); // Close dialog

    try {
      final user = context.read<UserModel?>();
      if (user == null) throw Exception('User not logged in');

      await context.read<FirebaseService>().joinTeam(
        _inviteCodeController.text.trim(),
        user.uid,
      );

      // Success is handled by auth state change -> dashboard redirect
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
