import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/custom_widgets.dart';
import '../attendance/live_attendance.dart';

class SectionsScreen extends StatefulWidget {
  final String teacherId;
  const SectionsScreen({super.key, required this.teacherId});

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  bool _isLoading = true;
  List<dynamic> _sections = [];

  @override
  void initState() {
    super.initState();
    _fetchSections();
  }

  Future<void> _fetchSections() async {
    try {
      final data = await ApiService.getSections();
      if (mounted) {
        setState(() {
          _sections = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching sections: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          CustomHeader(
            title: 'HANDLED SECTIONS',
            subtitle: 'Select a section to manage',
            showBackButton: true,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sections.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _sections.length,
                        itemBuilder: (context, index) {
                          final section = _sections[index];
                          final name = section['sectionName'] ?? 'Unknown Section';
                          final subject = section['subject'] ?? 'No Subject';
                          
                          return ActionCard(
                            icon: Icons.groups_rounded,
                            title: name,
                            subtitle: subject,
                            onTap: () => _showAttendanceAction(context, name, subject),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No sections assigned yet.',
            style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Contact Admin to assign sections.', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  void _showAttendanceAction(BuildContext context, String sectionName, String subject) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            Text(
              sectionName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(subject, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LiveAttendanceScreen(
                      targetName: subject,   // The Subject
                      section: sectionName,  // The Section (e.g. INF223)
                      isEvent: false,
                      teacherId: widget.teacherId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.fact_check_rounded),
              label: const Text('TAKE ATTENDANCE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
