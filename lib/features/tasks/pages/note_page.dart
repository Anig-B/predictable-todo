import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/data/seed_data.dart';
import '../../../core/utils/responsive_scale.dart';
import '../providers/note_provider.dart';
import '../models/note_model.dart';

class NotePage extends ConsumerStatefulWidget {
  const NotePage({super.key});

  @override
  ConsumerState<NotePage> createState() => _NotePageState();
}

class _NotePageState extends ConsumerState<NotePage> {
  final TextEditingController _ctrl = TextEditingController();
  NoteModel? _editingNote;

  void _save() {
    if (_ctrl.text.trim().isEmpty) return;

    if (_editingNote != null) {
      ref.read(noteProvider.notifier).updateNote(_editingNote!.id, _ctrl.text);
    } else {
      ref.read(noteProvider.notifier).addNote(_ctrl.text);
    }

    setState(() {
      _ctrl.clear();
      _editingNote = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _edit(NoteModel note) {
    setState(() {
      _editingNote = note;
      _ctrl.text = note.content;
    });
  }

  void _cancel() {
    setState(() {
      _ctrl.clear();
      _editingNote = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _showImportPicker() {
    final rs = ResponsiveScale(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: rs.only(t: 20, b: 40),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(rs.p(24))),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: rs.s(40),
              height: rs.s(4),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(rs.p(2)),
              ),
            ),
            SizedBox(height: rs.p(20)),
            Text('CHOOSE MISSION PACK',
                style: AppTheme.mono(size: rs.f(12), weight: FontWeight.w900)
                    .copyWith(letterSpacing: 2)),
            SizedBox(height: rs.p(10)),
            Text('Import strategic scrolls into your wisdom wall',
                style: AppTheme.sans(size: rs.f(11), color: AppColors.subtle)),
            SizedBox(height: rs.p(24)),
            ...SeedData.demoSets.map((demo) => ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: rs.p(24)),
                  leading:
                      Text(demo.icon, style: const TextStyle(fontSize: 24)),
                  title: Text(demo.name,
                      style: AppTheme.sans(size: rs.f(14), weight: FontWeight.w700)),
                  subtitle: Text('${demo.notes.length} scrolls available',
                      style: AppTheme.sans(size: rs.f(11), color: AppColors.muted)),
                  trailing: const Icon(Icons.download_rounded,
                      size: 20, color: AppColors.muted),
                  onTap: () {
                    final base = DateTime.now().millisecondsSinceEpoch;
                    final notes = demo.notes.asMap().entries.map((e) {
                      return e.value.copyWith(
                        id: 'demo-${base + e.key}',
                        createdAt: DateTime.now()
                            .subtract(Duration(minutes: e.key * 5)),
                      );
                    }).toList();
                    ref.read(noteProvider.notifier).loadDemo(notes);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('IMPORTED ${notes.length} SCROLLS',
                            style:
                                AppTheme.mono(size: rs.f(10), color: AppColors.bg)),
                        backgroundColor: AppColors.purple,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(noteProvider);
    final rs = ResponsiveScale(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('SCROLLS OF WISDOM',
            style: AppTheme.mono(size: rs.f(14), weight: FontWeight.w900)
                .copyWith(letterSpacing: 2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded,
                size: 20, color: AppColors.purple),
            tooltip: 'Import Wisdom',
            onPressed: _showImportPicker,
          ),
          SizedBox(width: rs.p(8)),
        ],
      ),
      body: LayoutBuilder(
        builder: (_, __) => rs.tabletCenter(600)(
          Column(
            children: [
              Expanded(
                child: notes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📜', style: TextStyle(fontSize: 48)),
                            SizedBox(height: rs.p(16)),
                            Text('NO SCROLLS ETCHED',
                                style: AppTheme.mono(
                                        size: rs.f(14),
                                        weight: FontWeight.w900,
                                        color: AppColors.accent)
                                    .copyWith(letterSpacing: 2)),
                            SizedBox(height: rs.p(8)),
                            Text('Record your strategic thoughts here',
                                style: AppTheme.sans(
                                    size: rs.f(12), color: AppColors.subtle)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: rs.fromLTRB(16, 8, 16, 20),
                        itemCount: notes.length,
                        itemBuilder: (_, i) {
                          final note = notes[i];
                          return Dismissible(
                            key: Key(note.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) =>
                                ref.read(noteProvider.notifier).deleteNote(note.id),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: rs.p(20)),
                              decoration: BoxDecoration(
                                color: AppColors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(rs.p(16)),
                              ),
                              child: const Icon(Icons.delete_outline_rounded,
                                  color: AppColors.red),
                            ),
                            child: GestureDetector(
                              onTap: () => _edit(note),
                              child: Container(
                                margin: EdgeInsets.only(bottom: rs.p(12)),
                                padding: EdgeInsets.all(rs.p(16)),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(rs.p(16)),
                                  border: Border.all(
                                    color: _editingNote?.id == note.id
                                        ? AppColors.accent
                                        : AppColors.border,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDate(note.createdAt),
                                          style: AppTheme.mono(
                                              size: rs.f(9), color: AppColors.subtle),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              visualDensity: VisualDensity.compact,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              icon: const Icon(Icons.copy_rounded,
                                                  size: 14, color: AppColors.muted),
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: note.content));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'SCROLL CONTENT COPIED',
                                                        style: AppTheme.mono(
                                                            size: rs.f(10),
                                                            color: AppColors.bg)),
                                                    backgroundColor:
                                                        AppColors.accent,
                                                    duration:
                                                        const Duration(seconds: 1),
                                                    behavior:
                                                        SnackBarBehavior.floating,
                                                    width: 200,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: rs.p(8)),
                                    Text(
                                      note.content,
                                      style: AppTheme.sans(
                                              size: rs.f(14), color: AppColors.text)
                                          .copyWith(height: 1.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildInputBar(),
    );
  }

  Widget _buildInputBar() {
    final rs = ResponsiveScale(context);
    return Container(
      padding: EdgeInsets.only(
        left: rs.p(16),
        right: rs.p(16),
        top: rs.p(16),
        bottom: MediaQuery.of(context).viewInsets.bottom + rs.p(16),
      ),
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border(
            top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
      ),
      child: Container(
        padding: EdgeInsets.all(rs.p(12)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(rs.p(20)),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _ctrl,
              maxLines: null,
              minLines: 1,
              style: AppTheme.sans(
                  size: rs.f(15), weight: FontWeight.w500, color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Etch your thoughts...',
                hintStyle: AppTheme.sans(size: rs.f(14), color: AppColors.muted),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
            SizedBox(height: rs.p(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_editingNote != null)
                  TextButton(
                    onPressed: _cancel,
                    child: Text('CANCEL',
                        style: AppTheme.mono(size: rs.f(12), color: AppColors.muted)),
                  ),
                SizedBox(width: rs.p(8)),
                IconButton(
                  onPressed: _save,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.bg,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rs.p(12))),
                  ),
                  icon: Icon(
                    _editingNote != null
                        ? Icons.check_rounded
                        : Icons.send_rounded,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
