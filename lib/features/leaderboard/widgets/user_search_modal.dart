import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../social/providers/social_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../auth/providers/auth_provider.dart';

class UserSearchModal extends ConsumerStatefulWidget {
  const UserSearchModal({super.key});

  @override
  ConsumerState<UserSearchModal> createState() => _UserSearchModalState();
}

class _UserSearchModalState extends ConsumerState<UserSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final currentUserId = ref.read(currentUserProvider)?.id;

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('id, username, avatar_url, short_id')
          .or('username.ilike.%$query%,short_id.ilike.%$query%')
          .neq('id', currentUserId ?? '')
          .limit(10);
      
      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      // Handle error gently
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendChallenge(String targetId) async {
    try {
      await ref.read(socialProvider.notifier).sendChallenge(targetId);
    } catch (e) {
      // Handle gently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Challenge a Friend',
                  style: AppTheme.mono(size: 20, weight: FontWeight.w800)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.text),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: _searchUsers,
            style: AppTheme.sans(size: 14, color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Search by User ID or Name...',
              hintStyle: AppTheme.sans(size: 14, color: AppColors.muted),
              prefixIcon: const Icon(Icons.search, color: AppColors.muted),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.accent))
          else if (_searchResults.isEmpty)
            Expanded(
              child: Center(
                child: Text('No users found', style: AppTheme.sans(size: 14, color: AppColors.muted)),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, i) {
                  final u = _searchResults[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        AppAvatar(avatar: u['avatar_url'] ?? '', size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u['username'] ?? 'Unknown',
                                  style: AppTheme.sans(
                                      size: 14, weight: FontWeight.w700)),
                              Text('#${u['short_id']}',
                                  style: AppTheme.mono(
                                      size: 11, color: AppColors.accent)),
                            ],
                          ),
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final social = ref.watch(socialProvider);
                            final isSent = social.sentChallenges.contains(u['id']);
                            final isReceived = social.receivedChallenges.contains(u['id']);
                            final isFriend = social.friends.contains(u['id']);

                            if (isFriend) return const SizedBox.shrink(); // Hide if already friends

                            String label = 'Challenge';
                            bool disabled = false;
                            if (isSent) {
                              label = 'Sent';
                              disabled = true;
                            } else if (isReceived) {
                              label = 'Accept?';
                              // You could add logic here to accept directly
                            }

                            return InkWell(
                              onTap: disabled ? null : () => _sendChallenge(u['id']),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: disabled ? AppColors.surface : AppColors.accent.withValues(alpha: 0.1),
                                  border: Border.all(color: disabled ? AppColors.border : AppColors.accent),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  label,
                                  style: AppTheme.sans(
                                    size: 12,
                                    weight: FontWeight.w700,
                                    color: disabled ? AppColors.muted : AppColors.accent,
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
