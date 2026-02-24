import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../models/handoff_checklist_model.dart';
import 'package:uuid/uuid.dart';

class HandoffScreen extends StatefulWidget {
  const HandoffScreen({super.key});

  @override
  State<HandoffScreen> createState() => _HandoffScreenState();
}

class _HandoffScreenState extends State<HandoffScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _leadNameController = TextEditingController();
  final TextEditingController _newTemplateItemController =
      TextEditingController();

  // State for new handoff
  List<String> _templateItems = [];
  Map<String, bool> _currentChecks = {};
  bool _isLoadingTemplate = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTemplate();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _leadNameController.dispose();
    _newTemplateItemController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplate() async {
    final user = context.read<UserModel?>();
    if (user?.currentTeamId == null) return;

    final service = context.read<FirebaseService>();
    final stream = service.getChecklistTemplate(user!.currentTeamId!);

    stream.listen((template) {
      if (mounted) {
        setState(() {
          _templateItems =
              template?.items ??
              ['Lead Qualified', 'Notes Added in CRM', 'Meeting Invite Sent'];
          _isLoadingTemplate = false;
          // Reset checks
          _currentChecks = {for (var item in _templateItems) item: false};
        });
      }
    });
  }

  Future<void> _saveTemplate() async {
    final user = context.read<UserModel?>();
    if (user?.currentTeamId == null) return;

    final template = ChecklistTemplateModel(
      id: user!.currentTeamId!,
      teamId: user.currentTeamId!,
      items: _templateItems,
    );

    await context.read<FirebaseService>().saveChecklistTemplate(template);
  }

  Future<void> _submitHandoff() async {
    if (_leadNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a lead name')));
      return;
    }

    final user = context.read<UserModel?>();
    if (user?.currentTeamId == null) return;

    final checklist = HandoffChecklistModel(
      id: const Uuid().v4(),
      leadName: _leadNameController.text,
      sdrId: user!.uid,
      teamId: user.currentTeamId!,
      items: _currentChecks,
      timestamp: DateTime.now(),
    );

    await context.read<FirebaseService>().saveHandoffChecklist(checklist);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Handoff saved!')));
      _leadNameController.clear();
      setState(() {
        _currentChecks = {for (var item in _templateItems) item: false};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Handoff Checklists'),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'New Handoff'),
            Tab(text: 'History'),
            Tab(text: 'Edit Template'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewHandoffTab(),
          _buildHistoryTab(),
          _buildEditTemplateTab(),
        ],
      ),
    );
  }

  Widget _buildNewHandoffTab() {
    if (_isLoadingTemplate) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lead Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _leadNameController,
            decoration: InputDecoration(
              hintText: 'Enter Lead Name',
              filled: true,
              fillColor: AppTheme.secondaryColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Checklist',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ..._templateItems.map((item) {
            return CheckboxListTile(
              title: Text(item),
              value: _currentChecks[item] ?? false,
              activeColor: AppTheme.primaryColor,
              onChanged: (val) {
                setState(() {
                  _currentChecks[item] = val ?? false;
                });
              },
            );
          }),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitHandoff,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Complete Handoff',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final user = context.watch<UserModel?>();
    if (user?.currentTeamId == null) {
      return const Center(child: Text('No team selected'));
    }

    final service = context.read<FirebaseService>();
    return StreamBuilder<List<HandoffChecklistModel>>(
      stream: service.getTeamHandoffs(user!.currentTeamId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No handoffs yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final handoff = snapshot.data![index];
            final completedCount = handoff.items.values.where((v) => v).length;
            final totalCount = handoff.items.length;
            final percent = totalCount > 0
                ? (completedCount / totalCount) * 100
                : 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ExpansionTile(
                title: Text(
                  handoff.leadName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'SDR: ${user.uid == handoff.sdrId ? "Me" : "Unknown"} • $completedCount/$totalCount items',
                ),
                trailing: Text(
                  '${percent.toInt()}%',
                  style: TextStyle(
                    color: percent == 100 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                children: handoff.items.entries
                    .map(
                      (e) => ListTile(
                        dense: true,
                        title: Text(e.key),
                        leading: Icon(
                          e.value
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: e.value
                              ? AppTheme.primaryColor
                              : AppTheme.greyColor,
                          size: 20,
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEditTemplateTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newTemplateItemController,
                  decoration: const InputDecoration(
                    hintText: 'Add new item...',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () {
                  if (_newTemplateItemController.text.isNotEmpty) {
                    setState(() {
                      _templateItems.add(_newTemplateItemController.text);
                      _newTemplateItemController.clear();
                    });
                    _saveTemplate();
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView(
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _templateItems.removeAt(oldIndex);
                _templateItems.insert(newIndex, item);
              });
              _saveTemplate();
            },
            children: [
              for (int i = 0; i < _templateItems.length; i++)
                ListTile(
                  key: ValueKey(_templateItems[i]),
                  title: Text(_templateItems[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        _templateItems.removeAt(i);
                      });
                      _saveTemplate();
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
