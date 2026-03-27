import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';
import '../../services/teacher_notification_service.dart';
import '../../services/auth_service.dart';


import '../../services/attendance_service.dart';
import 'package:intl/intl.dart';

/// Mark Attendance Screen – teacher selects class and marks each student.
class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});
  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

// UI Color Constants to match screenshot
class _UIColors {
  static const Color present = Color(0xFF00C853);
  static const Color absent = Color(0xFFFF5252);
  static const Color leave = Color(0xFFFFC107);
  static const Color total = Color(0xFF9E9E9E);
  
  static const Color presentBG = Color(0xFFE8F5E9);
  static const Color absentBG = Color(0xFFFFEBEE);
  static const Color leaveBG = Color(0xFFFFF8E1);
  static const Color totalBG = Color(0xFFF5F5F5);
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final Map<String, String> _attendance = {}; // studentId -> status
  bool _initialized = false;
  bool _isSubmitting = false;
  String? _grade;
  String? _teacherClass;
  String? _teacherDiv;
  List<Map<String, dynamic>> _students = [];
  
  // New State variables
  String _attendanceStatus = 'not_marked'; // 'not_marked' | 'submitted' | 'editing'
  DateTime _selectedDate = DateTime.now();
  String? _submittedAt;
  String? _submittedBy;
  String? _errorBanner;

  Future<void> _initialize(BuildContext context) async {
    if (_initialized) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final teacher = authService.teacherProfile;

    if (teacher != null) {
      _teacherClass = teacher['CLASS']?.toString();
      _teacherDiv = teacher['DIV'];
      
      if (_teacherClass == '5' || _teacherClass == 'V') _grade = 'grade5';
      else if (_teacherClass == '6' || _teacherClass == 'VI') _grade = 'grade6';
      else if (_teacherClass == '7' || _teacherClass == 'VII') _grade = 'grade7';
      else if (_teacherClass == '8' || _teacherClass == 'VIII') _grade = 'grade8';
      else _grade = 'grade5';

      if (_grade != null && _teacherDiv != null) {
        await _fetchStudents();
      }
    }
    
    setState(() => _initialized = true);
  }

  Future<void> _fetchStudents() async {
    try {
      final attendanceService = AttendanceService();
      final dateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      final students = await attendanceService.fetchStudentsForClass(_grade!, _teacherDiv!);
      
      // Fetch existing attendance summary and detailed records
      final summary = await attendanceService.fetchAttendanceSummary(_grade!, _teacherDiv!, dateId);
      final existingAttendance = await attendanceService.fetchClassAttendance(_grade!, _teacherDiv!, dateId);

      setState(() {
        _students = students;
        _attendance.clear();
        
        if (summary != null) {
          _attendanceStatus = 'submitted';
          _submittedBy = summary['submittedBy'];
          if (summary['submittedAt'] != null) {
            final dt = (summary['submittedAt'] as Timestamp).toDate();
            _submittedAt = DateFormat('hh:mm a').format(dt);
          }
          for (var s in _students) {
            _attendance[s['id']] = existingAttendance[s['id']] ?? 'present';
          }
        } else {
          _attendanceStatus = 'not_marked';
          _submittedBy = null;
          _submittedAt = null;
          for (var s in _students) {
            _attendance[s['id']] = 'present';
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialize(context);
  }

  void _validateAndSubmit() {
    if (_attendanceStatus == 'submitted') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already submitted. Tap Edit to make changes.'))
      );
      return;
    }

    final unmarkedStudents = _students.where((s) => !_attendance.containsKey(s['id'])).toList();
    if (unmarkedStudents.isNotEmpty) {
      _showUnmarkedDialog(unmarkedStudents.length);
    } else {
      _showConfirmationDialog();
    }
  }

  void _showUnmarkedDialog(int count) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$count students not marked yet', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back to List'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _autoMarkPresentAndSubmit();
                    },
                    child: const Text('Auto-mark Present'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _autoMarkPresentAndSubmit() {
    setState(() {
      for (var s in _students) {
        if (!_attendance.containsKey(s['id'])) {
          _attendance[s['id']] = 'present';
        }
      }
    });
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    int p = 0, a = 0, l = 0;
    for (var v in _attendance.values) {
      if (v == 'present') p++;
      else if (v == 'absent') a++;
      else if (v == 'leave') l++;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Attendance?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _confirmRow('Present:', '$p', AppColors.statusPresent),
            _confirmRow('Absent:', '$a', AppColors.statusAbsent),
            _confirmRow('Leave:', '$l', AppColors.statusLeave),
            const Divider(height: 24),
            Text('Date: ${DateFormat('d MMMM yyyy').format(_selectedDate)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text('Class: Class $_teacherClass — Division $_teacherDiv', style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitAttendance();
            }, 
            child: const Text('Confirm Submit')
          ),
        ],
      ),
    );
  }

  Widget _confirmRow(String label, String val, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _submitAttendance() async {
    if (_students.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorBanner = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final notificationService = Provider.of<TeacherNotificationService>(context, listen: false);
      final attendanceService = AttendanceService();
      
      final teacherEmail = authService.currentUser?.email ?? '';
      final now = DateTime.now();
      final dateId = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // Batch submit
      for (var s in _students) {
        final studentId = s['id'];
        final status = _attendance[studentId] ?? 'present';
        
        await attendanceService.markAttendance(
          grade: _grade!,
          div: _teacherDiv!,
          grNo: studentId,
          dateId: dateId,
          status: status,
          teacherEmail: teacherEmail,
        );
      }

      final teacherName = authService.teacherProfile?['NAME'] ?? 'Teacher';
      await attendanceService.saveAttendanceSummary(
        grade: _grade!,
        div: _teacherDiv!,
        dateId: dateId,
        teacherName: teacherName,
        teacherEmail: teacherEmail,
      );

      await notificationService.sendNotificationToClass(
        teacherEmail: teacherEmail,
        title: 'Attendance Updated',
        message: 'Attendance for Class $_teacherClass-$_teacherDiv has been marked for today.',
        type: 'attendance',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_attendanceStatus == 'editing' ? 'Attendance Updated ✓' : 'Attendance submitted & parents notified!'), backgroundColor: Colors.green)
        );
        setState(() {
          _attendanceStatus = 'submitted';
          _submittedAt = DateFormat('hh:mm a').format(now);
          _submittedBy = teacherName;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorBanner = 'Submission failed. Check your connection.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget build(BuildContext context) {
    if (!_initialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_teacherClass == null) return const Scaffold(body: Center(child: Text('Teacher class not assigned.')));

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(children: [
            _buildErrorBanner(),
            _buildSummaryBar(),
            const SizedBox(height: 4),
            _buildAttendancePercentage(),
            const SizedBox(height: 16),
            // Header for list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 24, child: Text('#', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                  const Expanded(child: Text('Student', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                  Text('Status', style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 100), // Space over buttons
                ],
              ),
            ),
            // Student list
            Expanded(
              child: _students.isEmpty 
                ? const EmptyState(icon: Icons.people_outline, message: 'No students found for your class.')
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 130),
                    itemCount: _students.length,
                    itemBuilder: (context, i) {
                      final s = _students[i];
                      final studentId = s['id'];
                      final name = s['NAME'] ?? s['name'] ?? 'No Name';
                      final roll = s['rollNo'] ?? s['ROLL NO.'] ?? 'N/A';
                      final status = _attendance[studentId] ?? 'unmarked';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            // Index #
                            SizedBox(
                              width: 24,
                              child: Text('${i + 1}', style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
                            ),
                            // Avatar
                            CircleAvatar(
                              radius: 18, 
                              backgroundColor: AppColors.primary.withOpacity(0.08),
                              child: Text(name.isNotEmpty ? name[0] : 'S', 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14)),
                            ),
                            const SizedBox(width: 12),
                            // Name & Roll
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, 
                                children: [
                                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text('Roll: $roll', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ]
                              ),
                            ),
                            // Status Buttons
                            _statusBtn('P', 'present', status, studentId, _UIColors.present),
                            const SizedBox(width: 8),
                            _statusBtn('A', 'absent', status, studentId, _UIColors.absent),
                            const SizedBox(width: 8),
                            _statusBtn('L', 'leave', status, studentId, _UIColors.leave),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ]),
          // Bottom area (Submit button or Submitted card)
          _attendanceStatus == 'submitted' 
            ? _buildSubmittedBottomCard() 
            : _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool isEditing = _attendanceStatus == 'editing';
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEditing) 
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Editing mode — changes not saved yet', style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            SizedBox(width: double.infinity, height: 46,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing ? AppColors.warning : AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isEditing ? 'Save Changes' : 'Submit Attendance', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmittedBottomCard() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, -5))],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _UIColors.present.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: _UIColors.present, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Attendance Submitted', style: TextStyle(color: _UIColors.present, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Submitted at $_submittedAt • Teacher', 
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: OutlinedButton(
                  onPressed: () => setState(() => _attendanceStatus = 'editing'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _UIColors.present),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Edit', style: TextStyle(color: _UIColors.present, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    if (_errorBanner == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.red.shade600,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(child: Text('Submission failed. Check your connection.', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500))),
          TextButton(
            onPressed: _submitAttendance,
            child: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  /// REDESIGNED APPBAR (Section 1 & 2)
  PreferredSizeWidget _buildAppBar() {
    final dateStr = DateFormat('EEEE • d MMMM yyyy').format(_selectedDate);
    final isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) == DateFormat('yyyy-MM-dd').format(DateTime.now());

    return PreferredSize(
      preferredSize: const Size.fromHeight(160),
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top row: Back button, Title, Calendar icon
              Row(
                children: [
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text('Mark Attendance', 
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white),
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month, color: Colors.white),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                        _fetchStudents();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              // Class & Division Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Builder(builder: (context) {
                      String suffix = 'th';
                      if (_teacherClass == '1') suffix = 'st';
                      else if (_teacherClass == '2') suffix = 'nd';
                      else if (_teacherClass == '3') suffix = 'rd';
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Class $_teacherClass$suffix $_teacherDiv', 
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      );
                    }),
                    _buildStatusBadge(),
                  ],
                ),
              ),
              const Spacer(),
              // Date Navigation row (Section 2)
              _buildDateNav(isToday),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;
    switch (_attendanceStatus) {
      case 'submitted':
        color = AppColors.statusPresent;
        label = 'Submitted';
        break;
      case 'editing':
        color = AppColors.info;
        label = 'Editing';
        break;
      default:
        color = AppColors.statusAbsent;
        label = 'Not Marked';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateNav(bool isToday) {
    final prevDate = _selectedDate.subtract(const Duration(days: 1));
    final nextDate = _selectedDate.add(const Duration(days: 1));
    final isNextDisabled = DateFormat('yyyy-MM-dd').format(_selectedDate) == DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _dateNavBtn('‹ ${DateFormat('d MMM').format(prevDate)}', () {
            setState(() => _selectedDate = prevDate);
            _fetchStudents();
          }, true),
          // Today/Date centered
          _dateNavBtn(DateFormat('d MMM').format(_selectedDate), () async {
             // Optional: show picker on center tap too?
          }, true, isCenter: true),
          _dateNavBtn('${DateFormat('d MMM').format(nextDate)} ›', () {
            if (!isNextDisabled) {
              setState(() => _selectedDate = nextDate);
              _fetchStudents();
            }
          }, !isNextDisabled),
        ],
      ),
    );
  }

  Widget _dateNavBtn(String label, VoidCallback onTap, bool enabled, {bool isCenter = false}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isCenter ? 24 : 16, vertical: 8),
        decoration: BoxDecoration(
          color: isCenter ? Colors.transparent : Colors.white.withOpacity(0.1),
          border: Border.all(color: Colors.white.withOpacity(enabled ? 0.3 : 0.1)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(color: Colors.white.withOpacity(enabled ? 1 : 0.4), fontSize: 13, fontWeight: isCenter ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildSummaryBar() {
    int present = 0, absent = 0, leave = 0;
    for (var status in _attendance.values) {
      if (status == 'present') present++;
      else if (status == 'absent') absent++;
      else if (status == 'leave') leave++;
    }
    final total = _students.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _summaryCard(present.toString(), 'Present', _UIColors.present, _UIColors.presentBG),
          const SizedBox(width: 10),
          _summaryCard(absent.toString(), 'Absent', _UIColors.absent, _UIColors.absentBG),
          const SizedBox(width: 10),
          _summaryCard(leave.toString(), 'Leave', _UIColors.leave, _UIColors.leaveBG),
          const SizedBox(width: 10),
          _summaryCard(total.toString(), 'Total', _UIColors.total, _UIColors.totalBG),
        ],
      ),
    );
  }

  Widget _summaryCard(String value, String label, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }


  Widget _buildAttendancePercentage() {
    int present = 0;
    for (var status in _attendance.values) {
      if (status == 'present') present++;
    }
    final total = _students.length;
    if (total == 0) return const SizedBox.shrink();
    
    final percent = ((present / total) * 100).toInt();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: _UIColors.present, size: 18),
          const SizedBox(width: 8),
          Text('Class attendance today: ', style: TextStyle(color: AppColors.textPrimary.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)),
          Text('$percent%', style: const TextStyle(color: _UIColors.present, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _statusBtn(String label, String status, String current, String studentId, Color color) {
    final selected = current == status;
    final bool isDisabled = _isSubmitting || _attendanceStatus == 'submitted';

    return GestureDetector(
      onTap: isDisabled ? null : () {
        final previousStatus = _attendance[studentId];
        setState(() {
          _attendance[studentId] = status;
          if (_attendanceStatus == 'submitted') _attendanceStatus = 'editing';
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked ${status[0].toUpperCase()}${status.substring(1)}'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  if (previousStatus == null) {
                    _attendance.remove(studentId);
                  } else {
                    _attendance[studentId] = previousStatus;
                  }
                });
              },
            ),
          ),
        );
      },
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(isDisabled ? 0.3 : 0.4), width: 1.5),
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: selected ? Colors.white : color.withOpacity(isDisabled ? 0.3 : 1)))),
      ),
    );
  }
}

/// Placeholder for Attendance History Screen
class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Attendance History', showBackButton: true),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: AppColors.textSubtle),
            SizedBox(height: 16),
            Text('Attendance History coming soon!', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

/// Teacher Students Screen – view students in assigned classes.
class TeacherStudentsScreen extends StatelessWidget {
  const TeacherStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final teacher = authService.teacherProfile;

    if (teacher == null) {
      return Scaffold(
        appBar: const GradientAppBar(title: 'Class Students', showBackButton: true),
        body: const Center(child: Text('Teacher profile not found.')),
      );
    }

    final teacherClass = teacher['CLASS']?.toString();
    final teacherDiv = teacher['DIV'];
    
    // Determine grade collection
    String grade = 'grade5';
    if (teacherClass == '5' || teacherClass == 'V') grade = 'grade5';
    if (teacherClass == '6' || teacherClass == 'VI') grade = 'grade6';
    if (teacherClass == '7' || teacherClass == 'VII') grade = 'grade7';
    if (teacherClass == '8' || teacherClass == 'VIII') grade = 'grade8';

    return Scaffold(
      appBar: const GradientAppBar(title: 'Class Students', showBackButton: true),
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .doc(grade)
            .collection('DIV_A')
            .where('CLASS', isEqualTo: teacherClass)
            .where('DIV', isEqualTo: teacherDiv)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const EmptyState(icon: Icons.people_outline, message: 'No students found in your assigned class.');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final s = docs[i].data() as Map<String, dynamic>;
              final name = s['NAME'] ?? s['name'] ?? 'No Name';
              final grNo = s['GR NO.'] ?? s['grNo'] ?? docs[i].id;
              final roll = s['rollNo'] ?? s['ROLL NO.'] ?? 'N/A';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                      child: Text(name.isNotEmpty ? name[0] : 'S', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent, fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text('GR: $grNo • Roll: $roll', style: const TextStyle(fontSize: 12, color: AppColors.textSubtle)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Teacher Quizzes Screen – manage and create quizzes.
class TeacherQuizzesScreen extends StatelessWidget {
  const TeacherQuizzesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final quizzes = MockDataService.quizzes;
    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Quizzes', showBackButton: true),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
          title: const Text('Create Quiz'),
          content: const Text('In production, this opens a form to add MCQ questions with options and correct answers.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        )),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: quizzes.length, itemBuilder: (context, i) {
        final q = quizzes[i];
        return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusMd)),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.tileIconColors[5].withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.quiz, color: AppColors.tileIconColors[5], size: 22)),
            title: Text(q.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('${q.subject} • ${q.totalQuestions} Qs', style: const TextStyle(fontSize: 12, color: AppColors.textSubtle)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.edit, size: 18, color: AppColors.accent), onPressed: () {}),
              IconButton(icon: const Icon(Icons.delete, size: 18, color: AppColors.error), onPressed: () {}),
            ]),
          ),
        );
      }),
    );
  }
}

/// Teacher Profile Screen.
class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final teacher = authService.teacherProfile;
    final displayName = user?.displayName ?? 'Teacher';
    final email = user?.email ?? '-';
    final assignedClass = teacher != null ? '${teacher['CLASS'] ?? 'N/A'}-${teacher['DIV'] ?? 'A'}' : 'N/A';

    return Scaffold(
      appBar: const GradientAppBar(title: 'My Profile', showBackButton: true),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(AppConstants.radiusXl)),
          child: Column(children: [
            CircleAvatar(radius: 40, backgroundColor: AppColors.accent.withValues(alpha: 0.2),
              child: Text(displayName.isNotEmpty ? displayName[0] : 'T', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.accent))),
            const SizedBox(height: 12),
            Text(displayName, style: const TextStyle(color: AppColors.textOnDark, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Teacher', style: TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w500)),
          ]),
        ),
        const SizedBox(height: 16),
        Container(width: double.infinity, padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusLg)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 12),
            _row(Icons.email, 'Email', email), 
            _row(Icons.book, 'Subjects', 'General'),
            _row(Icons.class_, 'Assigned Class', assignedClass),
          ]),
        ),
      ])),
    );
  }
  Widget _row(IconData i, String l, String v) => Padding(padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [Icon(i, size: 18, color: AppColors.accent), const SizedBox(width: 10),
      Text('$l: ', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Expanded(child: Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.right))]));
}
