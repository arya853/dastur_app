import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../models/announcement.dart';
import '../../services/admin_announcement_service.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';

class AdminCreateAnnouncementScreen extends StatefulWidget {
  const AdminCreateAnnouncementScreen({super.key});

  @override
  State<AdminCreateAnnouncementScreen> createState() => _AdminCreateAnnouncementScreenState();
}

class _AdminCreateAnnouncementScreenState extends State<AdminCreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  String _selectedType = 'notice'; // 'circular', 'notice', 'alert', 'event'
  String _selectedRole = 'all';    // 'all', 'students', 'teachers'
  String? _selectedClass;          // null for all classes

  bool _isConverting = false;

  final List<String> _types = ['notice', 'circular', 'alert', 'event'];
  final List<String> _roles = ['all', 'students', 'teachers'];
  final List<String> _classes = ['5', '6', '7', '8'];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isConverting = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final authorId = auth.currentUser?.email ?? 'admin';
      final authorName = auth.currentUser?.displayName ?? 'Administrator';

      final ann = Announcement(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Time-based ID
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        date: DateTime.now(),
        type: _selectedType,
        authorId: authorId,
        authorName: authorName,
        targetRole: _selectedRole,
        targetClass: _selectedRole == 'all' || _selectedRole == 'teachers' ? null : _selectedClass, // optionally limit teachers by class too, but typical is just students if selectedClass used
      );
      
      // Override targetClass if 'all' is explicitly requested
      if (_selectedClass == null && _selectedRole != 'all') {
         // This means all students or all teachers.
      }

      final Announcement finalAnn = Announcement(
        id: ann.id,
        title: ann.title,
        body: ann.body,
        date: ann.date,
        type: ann.type,
        authorId: ann.authorId,
        authorName: ann.authorName,
        targetRole: ann.targetRole,
        targetClass: _selectedClass, // Use explicit selection
        isActive: true,
      );

      final service = AdminAnnouncementService();
      await service.createAnnouncement(finalAnn);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement broadcasted successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isConverting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Announcement'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: _isConverting 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bodyController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Message Body',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Message body is required' : null,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Targeting & Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                        items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                        onChanged: (v) => setState(() => _selectedType = v!),
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(labelText: 'Target Audience', border: OutlineInputBorder()),
                        items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedRole = v!;
                            if (_selectedRole == 'all') _selectedClass = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      if (_selectedRole != 'all')
                        DropdownButtonFormField<String?>(
                          value: _selectedClass,
                          decoration: const InputDecoration(labelText: 'Target Class (Optional)', border: OutlineInputBorder()),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Classes')),
                            ..._classes.map((c) => DropdownMenuItem(value: c, child: Text('Grade $c'))),
                          ],
                          onChanged: (v) => setState(() => _selectedClass = v),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMd)),
                    ),
                    onPressed: _submit,
                    child: const Text('Broadcast Announcement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
