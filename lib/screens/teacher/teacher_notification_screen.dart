import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/teacher_notification_service.dart';
import '../../../services/attendance_service.dart';

class TeacherNotificationScreen extends StatefulWidget {
  const TeacherNotificationScreen({super.key});

  @override
  State<TeacherNotificationScreen> createState() => _TeacherNotificationScreenState();
}

class _TeacherNotificationScreenState extends State<TeacherNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = 'Announcement';
  bool _isLoading = false;
  bool _sendToAll = true;
  final Set<String> _selectedIds = {};
  List<Map<String, dynamic>> _allStudents = [];

  final List<String> _notificationTypes = ['Announcement', 'Attendance', 'General'];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final teacher = authService.teacherProfile;
      if (teacher == null) return;

      final teacherClass = teacher['CLASS']?.toString();
      final teacherDiv = teacher['DIV'];
      
      String grade = 'grade5';
      if (teacherClass == '5' || teacherClass == 'V') grade = 'grade5';
      else if (teacherClass == '6' || teacherClass == 'VI') grade = 'grade6';
      else if (teacherClass == '7' || teacherClass == 'VII') grade = 'grade7';
      else if (teacherClass == '8' || teacherClass == 'VIII') grade = 'grade8';

      final students = await AttendanceService().fetchStudentsForClass(grade, teacherDiv!);
      setState(() => _allStudents = students);
    } catch (e) {
      debugPrint("Error fetching students for notification: $e");
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Additional validation for selected students
    if (!_sendToAll && _selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one student'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final notificationService = Provider.of<TeacherNotificationService>(context, listen: false);
      
      final teacherEmail = authService.currentUser?.email;
      if (teacherEmail == null) throw "Teacher session not found. Please log in again.";

      await notificationService.sendNotificationToClass(
        teacherEmail: teacherEmail,
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        type: _selectedType,
        specificStudentIds: _sendToAll ? null : _selectedIds.toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Send Notification', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTeacherInfo(),
                  const SizedBox(height: 24),
                  
                  _buildSendToSection(),
                  const SizedBox(height: 24),
                  
                  const Text('Notification Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: _notificationTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (value) => setState(() => _selectedType = value!),
                  ),
                  const SizedBox(height: 20),

                  const Text('Title', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter notification title',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 20),

                  const Text('Message', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Enter your message here...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please enter a message' : null,
                  ),
                  const SizedBox(height: 32),

                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _messageController,
                    builder: (context, value, child) {
                      return Text(
                        '${value.text.length} characters',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _sendNotification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Send Notification', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

   Widget _buildSendToSection() {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         const Text('Send To', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
         const SizedBox(height: 12),
         Row(
           children: [
             _selectionTab('All Students', _sendToAll, () => setState(() => _sendToAll = true)),
             const SizedBox(width: 12),
             _selectionTab('Select Students', !_sendToAll, () => setState(() => _sendToAll = false)),
           ],
         ),
         if (!_sendToAll) ...[
           const SizedBox(height: 16),
           _buildStudentPicker(),
         ],
       ],
     );
   }

   Widget _selectionTab(String label, bool active, VoidCallback onTap) {
     return Expanded(
       child: GestureDetector(
         onTap: onTap,
         child: Container(
           padding: const EdgeInsets.symmetric(vertical: 12),
           decoration: BoxDecoration(
             color: active ? AppColors.primary : Colors.white,
             borderRadius: BorderRadius.circular(10),
             border: Border.all(color: active ? AppColors.primary : AppColors.border),
             boxShadow: active ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))] : null,
           ),
           child: Center(
             child: Text(label, style: TextStyle(color: active ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
           ),
         ),
       ),
     );
   }

   Widget _buildStudentPicker() {
     return Container(
       width: double.infinity,
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: AppColors.border),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text('${_selectedIds.length} students selected', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
               TextButton.icon(
                 onPressed: _showStudentSelectionDialog,
                 icon: const Icon(Icons.add_circle_outline, size: 18),
                 label: const Text('Add/Edit'),
               ),
             ],
           ),
           if (_selectedIds.isNotEmpty) ...[
             const SizedBox(height: 12),
             Wrap(
               spacing: 8,
               runSpacing: 8,
               children: _selectedIds.map((id) {
                 final student = _allStudents.firstWhere((s) => s['id'] == id, orElse: () => {'name': 'Unknown'});
                 return InputChip(
                   label: Text(student['name'] ?? student['NAME'] ?? 'Unknown', style: const TextStyle(fontSize: 11)),
                   onDeleted: () => setState(() => _selectedIds.remove(id)),
                   deleteIconColor: AppColors.statusAbsent,
                   backgroundColor: AppColors.primary.withOpacity(0.05),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                   side: BorderSide.none,
                 );
               }).toList(),
             ),
           ] else
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 8),
               child: Text('Please select at least one student', style: TextStyle(color: AppColors.statusAbsent, fontSize: 12)),
             ),
         ],
       ),
     );
   }

   void _showStudentSelectionDialog() {
     showModalBottomSheet(
       context: context,
       isScrollControlled: true,
       backgroundColor: Colors.transparent,
       builder: (context) => StatefulBuilder(
         builder: (context, setModalState) {
           return Container(
             height: MediaQuery.of(context).size.height * 0.8,
             decoration: const BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
             ),
             child: Column(
               children: [
                 Padding(
                   padding: const EdgeInsets.all(20),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text('Select Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
                     ],
                   ),
                 ),
                 Expanded(
                   child: ListView.builder(
                     itemCount: _allStudents.length,
                     itemBuilder: (context, index) {
                       final s = _allStudents[index];
                       final id = s['id'];
                       final isSelected = _selectedIds.contains(id);
                       return CheckboxListTile(
                         value: isSelected,
                         title: Text(s['name'] ?? s['NAME'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.w500)),
                         subtitle: Text('Roll: ${s['rollNo'] ?? 'N/A'}'),
                         onChanged: (val) {
                           setModalState(() {
                             if (val == true) _selectedIds.add(id);
                             else _selectedIds.remove(id);
                           });
                           setState(() {}); // Update the main screen Chip list
                         },
                         activeColor: AppColors.primary,
                       );
                     },
                   ),
                 ),
               ],
             ),
           );
         }
       ),
     );
   }


  Widget _buildTeacherInfo() {
    final authService = Provider.of<AuthService>(context);
    final teacher = authService.teacherProfile;
    
    if (teacher == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(teacher['name'] ?? 'Teacher', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Class: ${teacher['CLASS']} | Div: ${teacher['DIV']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
