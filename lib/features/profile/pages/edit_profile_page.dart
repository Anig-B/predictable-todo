import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_scale.dart';
import '../../../core/data/seed_data.dart';
import '../providers/profile_provider.dart';
import '../widgets/user_avatar.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _taglineCtrl;
  late String _selectedAvatar;


  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameCtrl = TextEditingController(text: profile.name);
    _taglineCtrl = TextEditingController(text: profile.tagline);
    _selectedAvatar = profile.avatar;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    await ref.read(profileProvider.notifier).updateProfile(
          name: _nameCtrl.text,
          tagline: _taglineCtrl.text,
          avatar: _selectedAvatar,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final rs = ResponsiveScale(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('MODIFY CHARACTER',
            style: AppTheme.mono(size: rs.f(14), weight: FontWeight.w900)
                .copyWith(letterSpacing: 2)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: rs.f(18)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('SAVE',
                style: AppTheme.mono(
                    size: rs.f(13),
                    weight: FontWeight.w900,
                    color: AppColors.accent)),
          ),
          SizedBox(width: rs.p(8)),
        ],
      ),
      body: rs.tabletCenter(600)(ListView(
        padding: rs.all(20),
        children: [
          // ── Avatar Selector ───────────────────────────
          Center(
            child: Stack(
              children: [
                UserAvatar(avatar: _selectedAvatar, size: rs.s(100), fontSize: rs.f(44)),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: rs.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit_rounded,
                        size: rs.f(14), color: AppColors.bg),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: rs.p(32)),

          // ── Tips ─────────────────────────────────────
          Container(
            padding: rs.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(rs.p(16)),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: rs.f(14), color: AppColors.accent),
                    SizedBox(width: rs.p(8)),
                    Text('RPG PRO TIP',
                        style: AppTheme.mono(
                            size: rs.f(10),
                            weight: FontWeight.w800,
                            color: AppColors.accent)),
                  ],
                ),
                SizedBox(height: rs.p(8)),
                Text(
                    'Your name and avatar appear in the leaderboard and notifications. Choose something that represents your leveling journey!',
                    style: AppTheme.sans(size: rs.f(11), color: AppColors.muted)),
              ],
            ),
          ),
          SizedBox(height: rs.p(32)),

          Text('SELECT AVATAR',
              style: AppTheme.mono(
                  size: rs.f(10), color: AppColors.subtle, weight: FontWeight.w800)),
          SizedBox(height: rs.p(12)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: rs.isTablet ? 8 : 5,
              crossAxisSpacing: rs.p(10),
              mainAxisSpacing: rs.p(10),
            ),
            itemCount: SeedData.avatarEmojis.length,
            itemBuilder: (_, i) {
              final avatar = SeedData.avatarEmojis[i];
              final active = _selectedAvatar == avatar;
              return GestureDetector(
                onTap: () => setState(() => _selectedAvatar = avatar),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.accent.withValues(alpha: 0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(rs.p(12)),
                    border: Border.all(
                      color: active ? AppColors.accent : AppColors.border,
                      width: active ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(avatar, style: TextStyle(fontSize: rs.f(24))),
                ),
              );
            },
          ),

          SizedBox(height: rs.p(32)),

          // ── Name Input ───────────────────────────────
          Text('CHARACTER NAME',
              style: AppTheme.mono(
                  size: rs.f(10), color: AppColors.subtle, weight: FontWeight.w800)),
          SizedBox(height: rs.p(12)),
          _InputField(
            controller: _nameCtrl,
            hint: 'Enter your hero name...',
            icon: Icons.person_outline_rounded,
          ),

          SizedBox(height: rs.p(24)),

          // ── Tagline Input ────────────────────────────
          Text('PERSONAL TAGLINE',
              style: AppTheme.mono(
                  size: rs.f(10), color: AppColors.subtle, weight: FontWeight.w800)),
          SizedBox(height: rs.p(12)),
          _InputField(
            controller: _taglineCtrl,
            hint: 'e.g. Master of Logic',
            icon: Icons.auto_awesome_outlined,
          ),

          SizedBox(height: rs.p(40)),
        ],
      )),
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
    final rs = ResponsiveScale(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(rs.p(14)),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        style: AppTheme.sans(size: rs.f(14), weight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.sans(size: rs.f(14), color: AppColors.muted),
          prefixIcon: Icon(icon, size: rs.f(20), color: AppColors.muted),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: rs.p(16), vertical: rs.p(14)),
        ),
      ),
    );
  }
}
