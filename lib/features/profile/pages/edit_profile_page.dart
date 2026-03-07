import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _taglineCtrl;
  late TextEditingController _projectCtrl;
  late String _selectedAvatar;

  final List<String> _avatars = [
    '🧑‍💻',
    '🥷',
    '🧙',
    '🦸',
    '🏹',
    '⚔️',
    '🛡️',
    '⚡',
    '🔥',
    '🐉',
    '👾',
    '🚀',
    '🎨',
    '📚',
    '🏃'
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameCtrl = TextEditingController(text: profile.name);
    _taglineCtrl = TextEditingController(text: profile.tagline);
    _projectCtrl = TextEditingController(text: profile.project);
    _selectedAvatar = profile.avatar;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    _projectCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    await ref.read(profileProvider.notifier).updateProfile(
          name: _nameCtrl.text,
          tagline: _taglineCtrl.text,
          avatar: _selectedAvatar,
          project: _projectCtrl.text,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('MODIFY CHARACTER',
            style: AppTheme.mono(size: 14, weight: FontWeight.w900)
                .copyWith(letterSpacing: 2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('SAVE',
                style: AppTheme.mono(
                    size: 13,
                    weight: FontWeight.w900,
                    color: AppColors.accent)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Avatar Selector ───────────────────────────
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(_selectedAvatar,
                        style: const TextStyle(fontSize: 44)),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_rounded,
                        size: 14, color: AppColors.bg),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Text('SELECT AVATAR',
              style: AppTheme.mono(
                  size: 10, color: AppColors.subtle, weight: FontWeight.w800)),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _avatars.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final avatar = _avatars[i];
                final active = _selectedAvatar == avatar;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = avatar),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.accent.withValues(alpha: 0.1)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: active ? AppColors.accent : AppColors.border,
                        width: active ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(avatar, style: const TextStyle(fontSize: 24)),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // ── Name Input ───────────────────────────────
          Text('CHARACTER NAME',
              style: AppTheme.mono(
                  size: 10, color: AppColors.subtle, weight: FontWeight.w800)),
          const SizedBox(height: 12),
          _InputField(
            controller: _nameCtrl,
            hint: 'Enter your hero name...',
            icon: Icons.person_outline_rounded,
          ),

          const SizedBox(height: 24),

          // ── Tagline Input ────────────────────────────
          Text('PERSONAL TAGLINE',
              style: AppTheme.mono(
                  size: 10, color: AppColors.subtle, weight: FontWeight.w800)),
          const SizedBox(height: 12),
          _InputField(
            controller: _taglineCtrl,
            hint: 'e.g. Master of Logic',
            icon: Icons.auto_awesome_outlined,
          ),

          const SizedBox(height: 24),

          // ── Project Input ────────────────────────────
          Text('JOIN #PROJECT',
              style: AppTheme.mono(
                  size: 10, color: AppColors.subtle, weight: FontWeight.w800)),
          const SizedBox(height: 12),
          _InputField(
            controller: _projectCtrl,
            hint: 'Enter #project name...',
            icon: Icons.tag_rounded,
          ),
          const SizedBox(height: 40),

          // ── Tips ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 14, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text('RPG PRO TIP',
                        style: AppTheme.mono(
                            size: 10,
                            weight: FontWeight.w800,
                            color: AppColors.accent)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                    'Your name and avatar appear in the leaderboard and notifications. Choose something that represents your leveling journey!',
                    style: AppTheme.sans(size: 11, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        style: AppTheme.sans(size: 14, weight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.sans(size: 14, color: AppColors.muted),
          prefixIcon: Icon(icon, size: 20, color: AppColors.muted),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
