import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/seed_data_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserModel?>();

    if (userProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Avatar with gradient initials ─────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _initials(userProfile.displayName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    userProfile.displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  Text(
                    userProfile.email,
                    style: const TextStyle(
                      color: AppTheme.greyColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── 3-stat row ────────────────────────────────────────────────────
            Row(
              children: [
                _StatCell(value: '12', label: 'Day Streak'),
                _StatCell(value: '94%', label: 'Completion'),
                _StatCell(value: '#2', label: 'Rank'),
              ],
            ),

            const SizedBox(height: 24),

            // Team Management Section
            if (userProfile.currentTeamId != null)
              _TeamManagementCard(
                teamId: userProfile.currentTeamId!,
                userId: userProfile.uid,
              )
            else
              _buildSettingsItem(
                context,
                icon: Icons.group_add_rounded,
                title: 'No Team Yet',
                subtitle: 'Go back and create or join a team',
                onTap: () {},
              ),

            const SizedBox(height: 16),
            _buildSettingsItem(
              context,
              icon: Icons.notifications_active_rounded,
              title: 'Notifications',
              subtitle: 'Configure daily reminders',
              onTap: () {},
            ),
            _buildSettingsItem(
              context,
              icon: Icons.security_rounded,
              title: 'Privacy & Security',
              subtitle: 'Manage your data and account',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _SeedDataButton(userProfile: userProfile),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppTheme.greyColor, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppTheme.greyColor,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;

  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.greyColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamManagementCard extends StatelessWidget {
  final String teamId;
  final String userId;

  const _TeamManagementCard({required this.teamId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();

    return StreamBuilder<Map<String, dynamic>?>(
      stream: firebaseService.getTeamStream(teamId),
      builder: (context, snapshot) {
        final teamData = snapshot.data;
        final teamName = teamData?['name'] as String? ?? 'Your Team';
        final inviteCode = teamData?['inviteCode'] as String? ?? '---';
        final memberCount = (teamData?['members'] as Map?)?.length ?? 1;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teamName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '$memberCount member${memberCount == 1 ? '' : 's'}',
                            style: const TextStyle(
                              color: AppTheme.greyColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Colors.white24),

              // Invite Code Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INVITE CODE',
                      style: TextStyle(
                        color: AppTheme.greyColor,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            inviteCode,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              color: AppTheme.primaryColor,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: inviteCode),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invite code copied!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.copy_rounded,
                              color: AppTheme.primaryColor,
                            ),
                            tooltip: 'Copy Code',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Share this code with teammates to let them join.',
                      style: TextStyle(color: AppTheme.greyColor, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Colors.white24),

              // Leave Team
              ListTile(
                onTap: () => _confirmLeaveTeam(context, firebaseService),
                leading: const Icon(
                  Icons.exit_to_app_rounded,
                  color: AppTheme.errorColor,
                ),
                title: const Text(
                  'Leave Team',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmLeaveTeam(
    BuildContext context,
    FirebaseService firebaseService,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Team?'),
        content: const Text(
          'You will lose access to this team\'s tasks and data. You can rejoin using the invite code.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await firebaseService.leaveTeam(userId, teamId);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error leaving team: $e')),
                  );
                }
              }
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

class _SeedDataButton extends StatefulWidget {
  final UserModel userProfile;
  const _SeedDataButton({required this.userProfile});

  @override
  State<_SeedDataButton> createState() => _SeedDataButtonState();
}

class _SeedDataButtonState extends State<_SeedDataButton> {
  bool _loading = false;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.amber),
        ),
        title: Text(
          _done ? 'Demo Data Loaded! ✅' : 'Load Demo Sales Data',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _done
              ? 'Tasks, completions & pipeline metrics added.'
              : '7 recurring tasks + 7 days of history',
          style: const TextStyle(color: AppTheme.greyColor, fontSize: 12),
        ),
        trailing: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppTheme.greyColor,
              ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onTap: _loading || _done ? null : _seed,
      ),
    );
  }

  Future<void> _seed() async {
    final teamId = widget.userProfile.currentTeamId;
    if (teamId == null) return;

    setState(() => _loading = true);
    try {
      await SeedDataService().seed(
        userId: widget.userProfile.uid,
        teamId: teamId,
      );
      if (mounted) setState(() => _done = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Seed error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
