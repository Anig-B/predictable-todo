import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../models/pipeline_metric_model.dart';

class PipelineTrackerScreen extends StatefulWidget {
  const PipelineTrackerScreen({super.key});

  @override
  State<PipelineTrackerScreen> createState() => _PipelineTrackerScreenState();
}

class _PipelineTrackerScreenState extends State<PipelineTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _callsController = TextEditingController();
  final _connectsController = TextEditingController();
  final _meetingsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _callsController.dispose();
    _connectsController.dispose();
    _meetingsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // TODO: Fetch existing data for this date and populate fields
    }
  }

  Future<void> _saveMetrics() async {
    if (_formKey.currentState!.validate()) {
      final userProfile = context.read<UserModel?>();
      if (userProfile == null || userProfile.currentTeamId == null) return;

      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final metric = PipelineMetricModel(
        id: '${userProfile.uid}_$dateStr',
        userId: userProfile.uid,
        teamId: userProfile.currentTeamId!,
        date: dateStr,
        calls: int.tryParse(_callsController.text) ?? 0,
        connects: int.tryParse(_connectsController.text) ?? 0,
        meetingsBooked: int.tryParse(_meetingsController.text) ?? 0,
        timestamp: DateTime.now(),
      );

      try {
        await context.read<FirebaseService>().savePipelineMetric(metric);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Metrics saved successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving metrics: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Pipeline Tracker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateSelector(),
              const SizedBox(height: 30),
              Text(
                'Daily Activity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Log your sales activity to track conversion rates.',
                style: TextStyle(color: AppTheme.greyColor),
              ),
              const SizedBox(height: 30),
              _buildNumberInput(
                controller: _callsController,
                label: 'Calls Made 📞',
                hint: 'e.g. 50',
              ),
              const SizedBox(height: 20),
              _buildNumberInput(
                controller: _connectsController,
                label: 'Connects / Conversations 🗣️',
                hint: 'e.g. 5',
              ),
              const SizedBox(height: 20),
              _buildNumberInput(
                controller: _meetingsController,
                label: 'Meetings Booked 📅',
                hint: 'e.g. 1',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: _saveMetrics,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            'Save Metrics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date',
                  style: TextStyle(color: AppTheme.greyColor, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMM d, y').format(_selectedDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.calendar_today_rounded,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.greyColor),
            filled: true,
            fillColor: AppTheme.secondaryColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value (0 if none)';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }
}
