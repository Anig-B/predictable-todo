import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/rainbow_glimmer.dart';
import '../../../core/data/seed_data.dart';
import '../providers/task_provider.dart';
import '../../gamification/providers/gamification_provider.dart';
import '../../gamification/providers/effects_provider.dart';
import '../../gamification/providers/challenge_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../../core/utils/xp_calculator.dart';
import '../widgets/task_filter_bar.dart';
import '../widgets/task_card.dart';
import '../../gamification/widgets/boss_card.dart';
import '../../gamification/widgets/combo_banner.dart';
import '../widgets/proof_modal.dart';
import 'add_task_page.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/task_repository.dart';
import '../../gamification/widgets/spin_wheel_modal.dart';
import '../../gamification/widgets/loot_box_modal.dart';
import '../models/task_model.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  TaskFilter _activeFilter = TaskFilter.today;
  bool _selectMode = false;
  final Set<String> _selectedIds = {};

  void _enterSelectMode() {
    setState(() {
      _selectMode = true;
      _selectedIds.clear();
    });
  }

  void _exitSelectMode() {
    setState(() {
      _selectMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tState = ref.watch(taskProvider);
    final gState = ref.watch(gamificationProvider);
    final unread = ref.watch(unreadCountProvider);
    final pendingChallenges =
        ref.watch(challengeProvider).where((c) => !c.done).length;

    final totalXp = gState.totalXp;
    final level = XpCalculator.level(totalXp);
    final lvlProgress = XpCalculator.levelProgress(totalXp);

    if (gState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: _selectMode
          ? Container(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedIds.length == _filteredTasks(tState.tasks).length) {
                          _selectedIds.clear();
                        } else {
                          _selectedIds.addAll(
                            _filteredTasks(tState.tasks).map((t) => t.id),
                          );
                        }
                      });
                    },
                    child: Text(
                      _selectedIds.length == _filteredTasks(tState.tasks).length
                          ? 'Deselect All' : 'Select All',
                      style: AppTheme.sans(size: 11, color: AppColors.accent, weight: FontWeight.w700),
                    ),
                  ),
                  Text('${_selectedIds.length}',
                      style: AppTheme.mono(size: 10, color: AppColors.subtle)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _selectedIds.isEmpty ? null : () async {
                      final tasks = _selectedIds
                          .map((id) => tState.tasks.firstWhere((t) => t.id == id))
                          .where((t) => t.done)
                          .toList();
                      if (tasks.isEmpty) return;

                      final needConfirm = tasks.any((t) =>
                          !_isRecent(t.lastCompletedAt) ||
                          t.proofNotes != null ||
                          t.proofImage != null);
                      if (needConfirm) {
                        final confirmed = await _confirmBulkUndo(context, tasks);
                        if (!confirmed) return;
                      }

                      for (final task in tasks) {
                        ref.read(taskProvider.notifier).uncompleteTask(task.id);
                        ref.read(gamificationProvider.notifier)
                            .onTaskUncompleted(task.points, task.bonusEarned);
                      }
                      _exitSelectMode();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedIds.isEmpty ? AppColors.surface2 : AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Undo',
                          style: AppTheme.sans(size: 12, weight: FontWeight.w700,
                              color: _selectedIds.isEmpty ? AppColors.muted : Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _selectedIds.isEmpty ? null : () {
                      final count = _selectedIds.length;
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surface,
                          title: Text('Delete $count quests?',
                              style: AppTheme.sans(size: 15, weight: FontWeight.w700, color: AppColors.text)),
                          content: Text('This cannot be undone.',
                              style: AppTheme.sans(size: 12, color: AppColors.muted)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text('Cancel',
                                  style: AppTheme.sans(size: 11, color: AppColors.subtle)),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.read(taskProvider.notifier).deleteTasks(_selectedIds.toList());
                                _exitSelectMode();
                                Navigator.of(ctx).pop();
                              },
                              child: Text('Delete All',
                                  style: AppTheme.sans(size: 11, color: AppColors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedIds.isEmpty ? AppColors.surface2 : AppColors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Delete',
                          style: AppTheme.sans(size: 12, weight: FontWeight.w700,
                              color: _selectedIds.isEmpty ? AppColors.muted : Colors.white)),
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              level: level,
              lvlProgress: lvlProgress,
              unread: unread,
              pendingChallenges: pendingChallenges,
              onNotif: () => context.push('/notifications'),
              onChallenges: () => context.push('/challenges'),
              isSpinAvailable: gState.isSpinAvailable,
              onSpin: () {
                if (gState.isSpinAvailable) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    useSafeArea: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => SpinWheelModal(
                      onResult: (seg) => ref
                          .read(gamificationProvider.notifier)
                          .applySpinResult(seg),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Come back tomorrow for your next spin!',
                          style: AppTheme.sans(size: 12)),
                      backgroundColor: AppColors.surface2,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            TaskFilterBar(
              selected: _activeFilter,
              onChanged: (v) => setState(() {
                _activeFilter = v;
                _selectedIds.clear();
                _selectMode = false;
              }),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.read(taskProvider.notifier).refresh();
                  setState(() {});
                },
                color: AppColors.accent,
                backgroundColor: AppColors.surface,
                child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 130),
                children: [
                  // Combo & multiplier banners
                  if (gState.comboPoints >= 100) ...[
                    ComboBanner(
                        comboPoints: gState.comboPoints,
                        comboMulti: gState.comboMulti),
                    const SizedBox(height: 7),
                  ],
                  if (gState.multiplier > 1) ...[
                    MultiplierBanner(multiplier: gState.multiplier),
                    const SizedBox(height: 7),
                  ],

                  // Boss card
                  BossCard(boss: gState.boss),
                  const SizedBox(height: 10),

                  // Counter row
                  // Counter row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${tState.doneCount}/${tState.totalCount} DONE',
                          style:
                              AppTheme.mono(size: 10, color: AppColors.subtle)),
                      Text('+$totalXp XP',
                          style:
                              AppTheme.mono(size: 10, color: AppColors.accent)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Task list
                  ..._filteredTasks(tState.tasks).map((task) => TaskCard(
                        task: task,
                        effectiveMulti: gState.effectiveMulti,
                        onToggle: () => _handleToggle(context, ref, task),
                        onQuickToggle: () =>
                            _handleQuickToggle(context, ref, task),
                        onLongPress: _selectMode
                            ? null
                            : () => _handleLongPress(context, ref, task),
                        selectMode: _selectMode,
                        isSelected: _selectedIds.contains(task.id),
                        onSelect: () => _toggleSelect(task.id),
                      )),

                  if (_filteredTasks(tState.tasks).isEmpty)
                    _EmptyState(filter: _activeFilter, ref: ref),
                ],
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isRecent(DateTime? date) {
    if (date == null) return false;
    // Clears after exact 24 hours from completion
    return DateTime.now().difference(date).inHours < 24;
  }

  List<TaskModel> _filteredTasks(List<TaskModel> tasks) {
    final now = DateTime.now();
    switch (_activeFilter) {
      case TaskFilter.today:
        return tasks.where((t) {
          if (t.done && !_isRecent(t.lastCompletedAt)) return false;
          if (t.done && _isRecent(t.lastCompletedAt)) return true;

          if (t.recurring == TaskRecurring.none) return true;
          if (t.recurring == TaskRecurring.daily) return true;
          if (t.recurring == TaskRecurring.weekly) {
            return t.weeklyDay == now.weekday;
          }
          if (t.recurring == TaskRecurring.monthly) {
            return t.monthlyDay == now.day ||
                (t.monthlyDay == 0 &&
                    now.day == DateTime(now.year, now.month + 1, 0).day);
          }
          return false;
        }).toList();
      case TaskFilter.weekly:
        return tasks.where((t) => t.recurring == TaskRecurring.weekly).toList();
      case TaskFilter.monthly:
        return tasks
            .where((t) => t.recurring == TaskRecurring.monthly)
            .toList();
      case TaskFilter.cleared:
        return tasks
            .where((t) => t.done && !_isRecent(t.lastCompletedAt))
            .toList();
      case TaskFilter.notes:
        return [];
    }
  }

  Future<bool> _confirmUndo(BuildContext context, TaskModel task) async {
    if (!task.done) return true;

    // If task is "old" (more than 24h), show warning
    final isOld = !_isRecent(task.lastCompletedAt);
    final hasProof = task.proofNotes != null || task.proofImage != null;

    if (!isOld && !hasProof) return true;

    final warningMsg = isOld
        ? 'This task was cleared over 24 hours ago. Reverting it will remove it from your history and deduct XP.'
        : 'This task has proof notes or a photo attached. Unchecking will remove them and revert the bonus XP.';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(isOld ? 'Undo Old Task?' : 'Undo Completion?',
            style: AppTheme.mono(size: 14)),
        content: Text(warningMsg,
            style: AppTheme.sans(size: 13, color: AppColors.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTheme.sans(size: 13)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Uncheck',
                style: AppTheme.sans(size: 13, color: AppColors.red)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<bool> _confirmBulkUndo(BuildContext context, List<TaskModel> tasks) async {
    final hasOld = tasks.any((t) => !_isRecent(t.lastCompletedAt));
    final hasProof = tasks.any((t) => t.proofNotes != null || t.proofImage != null);

    final parts = <String>[];
    if (hasOld) parts.add('${tasks.where((t) => !_isRecent(t.lastCompletedAt)).length} cleared quest(s)');
    if (hasProof) parts.add('${tasks.where((t) => t.proofNotes != null || t.proofImage != null).length} quest(s) with proof');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Undo Multiple?',
            style: AppTheme.mono(size: 14)),
        content: Text(
          '${parts.join(' and ')} will be reverted, removing them from history and deducting XP.',
          style: AppTheme.sans(size: 13, color: AppColors.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTheme.sans(size: 13)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Uncheck All',
                style: AppTheme.sans(size: 13, color: AppColors.red)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _handleLongPress(BuildContext context, WidgetRef ref, TaskModel task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: AppColors.accent, size: 20),
              title: Text('Edit Quest',
                  style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.text)),
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTaskPage(existingTask: task),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.checklist_rounded, color: AppColors.blue, size: 20),
              title: Text('Select Multiple',
                  style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.text)),
              onTap: () {
                Navigator.of(ctx).pop();
                _enterSelectMode();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: AppColors.red, size: 20),
              title: Text('Delete Quest',
                  style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.red)),
              onTap: () {
                Navigator.of(ctx).pop();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: Text('Delete Quest',
                        style: AppTheme.sans(size: 15, weight: FontWeight.w700, color: AppColors.text)),
                    content: Text('Delete "${task.title}" permanently?',
                        style: AppTheme.sans(size: 12, color: AppColors.muted)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('Cancel',
                            style: AppTheme.sans(size: 11, color: AppColors.subtle)),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(taskProvider.notifier).deleteTask(task.id);
                          Navigator.of(ctx).pop();
                        },
                        child: Text('Delete',
                            style: AppTheme.sans(size: 11, color: AppColors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleQuickToggle(
      BuildContext context, WidgetRef ref, TaskModel task) async {
    if (task.done) {
      if (!await _confirmUndo(context, task)) return;

      ref.read(taskProvider.notifier).uncompleteTask(task.id);
      ref
          .read(gamificationProvider.notifier)
          .onTaskUncompleted(task.points, task.bonusEarned);
    } else {
      // Basic points, no rating/proof
      _completeTask(context, ref, task, 0, 3, isQuick: true);
    }
  }

  Future<void> _handleToggle(
      BuildContext context, WidgetRef ref, TaskModel task) async {
    if (task.done) {
      if (!await _confirmUndo(context, task)) return;

      ref.read(taskProvider.notifier).uncompleteTask(task.id);
      ref
          .read(gamificationProvider.notifier)
          .onTaskUncompleted(task.points, task.bonusEarned);
    } else {
      // Show proof modal
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: false,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ProofModal(
          task: task,
          onSubmit: (bonusXp, rating, notes, imageFile) async {
            String? imageUrl;
            if (imageFile != null) {
              final user = ref.read(currentUserProvider);
              if (user != null) {
                final bytes = await imageFile.readAsBytes();
                final ext = imageFile.name.split('.').last;
                imageUrl = await ref
                    .read(taskRepositoryProvider)
                    .uploadProofImage(user.id, bytes, ext);
              }
            }
            if (context.mounted) {
              _completeTask(context, ref, task, bonusXp, rating,
                  notes: notes, imageUrl: imageUrl);
            }
          },
        ),
      );
    }
  }

  void _completeTask(BuildContext context, WidgetRef ref, TaskModel task,
      int proofBonus, int rating,
      {bool isQuick = false, String? notes, String? imageUrl}) {
    final gNotifier = ref.read(gamificationProvider.notifier);
    final tNotifier = ref.read(taskProvider.notifier);
    final effects = ref.read(effectsProvider.notifier);
    final challenges = ref.read(challengeProvider.notifier);

    // Capture boss state BEFORE mutation to detect defeat transition
    final bossWasAlive = !ref.read(gamificationProvider).boss.isDefeated;

    final multiBonus = gNotifier.onTaskCompleted(task.points);
    final totalBonus = multiBonus + proofBonus;
    tNotifier.completeTask(task.id, totalBonus,
        rating: rating, notes: notes, imageUrl: imageUrl);
    final hasProof = notes != null || imageUrl != null;
    challenges.onTaskCompleted(task, ref.read(gamificationProvider).comboCount, hasProof);
    
    if (bossWasAlive) {
      challenges.onBossDamaged(1);
    }

    // Effects
    if (!isQuick) {
      final size = MediaQuery.of(context).size;
      effects.spawnXpFloat(
        x: size.width * 0.2 + (size.width * 0.5),
        y: size.height * 0.4,
        value: task.points + totalBonus,
        multiplier: ref.read(gamificationProvider).effectiveMulti,
      );
    }

    // Toast + notification for combos
    final comboMulti = ref.read(gamificationProvider).comboMulti;
    final gState = ref.read(gamificationProvider);
    if (comboMulti == 3) {
      effects.showToast(
          icon: '🔥', title: '3× Combo!', desc: "You're on fire!");
    } else if (comboMulti == 4) {
      effects.showToast(
          icon: '⚡', title: 'ULTRA COMBO!', desc: '4× XP multiplier!');
    }

    // Streak milestone toasts (optional? They are handled somewhere else)
    final streak = gState.currentStreak;
    if (streak == 3 || streak == 7 || streak == 14 || streak == 30) {
      // Could show toast here if we want
    }

    // Boss defeated toast + notification — only fires when boss transitions alive → defeated
    final boss = ref.read(gamificationProvider).boss;
    if (bossWasAlive && boss.isDefeated) {
      effects.triggerConfetti();
      effects.showToast(
          icon: '🐉',
          title: 'Boss Defeated!',
          desc: '+${boss.reward} XP earned!');
    }

    // Loot box — capture before delay to avoid race with next task completion
    final showLoot = ref.read(gamificationProvider.notifier).shouldShowLoot;
    if (showLoot) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (context.mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: false,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (_) => LootBoxModal(
              onCollect: (item) => ref
                  .read(gamificationProvider.notifier)
                  .applyLootItem(item.name),
            ),
          );
        }
      });
    }
  }
}

class _EmptyState extends StatelessWidget {
  final TaskFilter filter;
  final WidgetRef ref;

  const _EmptyState({required this.filter, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        const Text('🎉', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(
          filter == TaskFilter.notes
              ? 'NO SCROLLS ETCHED'
              : (filter == TaskFilter.cleared
                  ? 'NO CLEARED QUESTS'
                  : 'ALL QUESTS CLEARED!'),
          style: AppTheme.mono(
                  size: 14, weight: FontWeight.w900, color: AppColors.accent)
              .copyWith(letterSpacing: 2),
        ),
        if (filter == TaskFilter.today) ...[
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5))),
            ),
            child: Text('OR IMPORT A MISSION PACK',
                textAlign: TextAlign.center,
                style: AppTheme.mono(
                        size: 10,
                        weight: FontWeight.w800,
                        color: AppColors.subtle)
                    .copyWith(letterSpacing: 1.5)),
          ),
          const SizedBox(height: 12),
          ...SeedData.demoSets.map((demo) => _DemoPackCard(
                demo: demo,
                onTap: () {
                  final base = DateTime.now().millisecondsSinceEpoch;
                  final tasks = demo.tasks.asMap().entries.map((e) {
                    return e.value.copyWith(
                        id: (base + e.key).toString(),
                        streak: 0,
                        done: false,
                        bonusEarned: 0,
                        clearLastCompleted: true);
                  }).toList();
                  ref.read(taskProvider.notifier).loadDemo(tasks);
                },
              )),
        ],
      ],
    );
  }
}

class _DemoPackCard extends StatelessWidget {
  final DemoSet demo;
  final VoidCallback onTap;

  const _DemoPackCard({required this.demo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: demo.color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: demo.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(demo.icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(demo.name,
                      style: AppTheme.sans(size: 14, weight: FontWeight.w800)),
                  Text(demo.desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sans(size: 10, color: AppColors.subtle)),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline_rounded,
                size: 20, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int level;
  final double lvlProgress;
  final int unread;
  final int pendingChallenges;
  final VoidCallback onNotif;
  final VoidCallback onChallenges;
  final VoidCallback? onSpin;
  final bool isSpinAvailable;

  const _Header({
    required this.level,
    required this.lvlProgress,
    required this.unread,
    required this.pendingChallenges,
    required this.onNotif,
    required this.onChallenges,
    this.onSpin,
    this.isSpinAvailable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bg, AppColors.bg.withValues(alpha: 0)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: Text(
                    _todayLabel(),
                    style: AppTheme.mono(
                        size: 20, weight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(
                      width: 96,
                      height: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: lvlProgress,
                          backgroundColor: AppColors.surface3,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('LVL $level',
                        style: AppTheme.mono(size: 9, color: AppColors.accent)),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons
          Row(
            children: [
              if (onSpin != null) ...[
                Builder(builder: (context) {
                  return _IconBtn(
                    onTap: onSpin!,
                    isRainbow: isSpinAvailable,
                    borderColor: isSpinAvailable
                        ? AppColors.gold.withValues(alpha: 0.35)
                        : AppColors.border,
                    child: ColorFiltered(
                      colorFilter: isSpinAvailable
                          ? const ColorFilter.mode(Colors.transparent, BlendMode.color)
                          : AppColors.grayscaleFilter,
                      child: Opacity(
                        opacity: isSpinAvailable ? 1.0 : 0.5,
                        child: const Text('🎰', style: TextStyle(fontSize: 15)),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 7),
              ],
              _IconBtn(
                onTap: onChallenges,
                borderColor: AppColors.purple.withValues(alpha: 0.35),
                badge: pendingChallenges > 0 ? pendingChallenges : null,
                badgeColor: AppColors.purple,
                child: const Text('📜', style: TextStyle(fontSize: 15)),
              ),
              const SizedBox(width: 7),
              _IconBtn(
                onTap: onNotif,
                badge: unread > 0 ? unread : null,
                child: const Icon(Icons.notifications_none,
                    size: 16, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

class _IconBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color borderColor;
  final int? badge;
  final Color badgeColor;
  final bool isRainbow;

  const _IconBtn({
    required this.child,
    required this.onTap,
    this.borderColor = AppColors.border,
    this.badge,
    this.badgeColor = AppColors.red,
    this.isRainbow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isRainbow)
            Positioned.fill(
              child: RainbowGlimmer(
                duration: const Duration(milliseconds: 2000),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: isRainbow ? Colors.transparent : borderColor),
            ),
            alignment: Alignment.center,
            child: child,
          ),
          if (badge != null)
            Positioned(
              top: -3,
              right: -3,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  constraints:
                      const BoxConstraints(minWidth: 15, minHeight: 15),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text('$badge',
                      style: AppTheme.mono(
                          size: 8,
                          color: Colors.white,
                          weight: FontWeight.w800)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
