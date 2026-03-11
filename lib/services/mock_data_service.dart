import '../models/app_user.dart';
import '../models/student.dart';
import '../models/parent.dart';
import '../models/teacher.dart';
import '../models/announcement.dart';
import '../models/attendance_record.dart';
import '../models/fee_record.dart';
import '../models/timetable_entry.dart';
import '../models/subject.dart';
import '../models/ebook.dart';
import '../models/quiz.dart';
import '../models/calendar_event.dart';

/// Mock Data Service
///
/// Provides realistic demo data so the app works immediately without
/// a Firebase backend. Contains sample accounts for all 3 roles.
class MockDataService {
  MockDataService._();

  // ─── DEMO USERS ───────────────────────────────────────────────────
  static final AppUser adminUser = AppUser(
    uid: 'admin-001',
    email: 'admin@dasturschool.in',
    role: 'admin',
    displayName: 'Dr. Meher Irani',
  );

  static final AppUser teacherUser = AppUser(
    uid: 'teacher-001',
    email: 'teacher@dasturschool.in',
    role: 'teacher',
    displayName: 'Mrs. Priya Sharma',
  );

  static final AppUser parentUser = AppUser(
    uid: 'parent-001',
    email: 'parent@dasturschool.in',
    role: 'parent',
    displayName: 'Mr. Rohan Mehta',
  );

  // ─── STUDENT ──────────────────────────────────────────────────────
  static final Student demoStudent = Student(
    id: 'student-001',
    name: 'Aryan Mehta',
    className: 'VIII',
    section: 'A',
    rollNumber: '24',
    email: 'aryan.mehta@dasturschool.in',
    parentId: 'parent-001',
  );

  static final List<Student> allStudents = [
    demoStudent,
    Student(id: 'student-002', name: 'Priya Deshmukh', className: 'VIII', section: 'A', rollNumber: '12', email: 'priya.d@dasturschool.in', parentId: 'parent-002'),
    Student(id: 'student-003', name: 'Rishi Kapoor', className: 'VIII', section: 'A', rollNumber: '15', email: 'rishi.k@dasturschool.in', parentId: 'parent-003'),
    Student(id: 'student-004', name: 'Ananya Singh', className: 'VIII', section: 'B', rollNumber: '03', email: 'ananya.s@dasturschool.in', parentId: 'parent-004'),
    Student(id: 'student-005', name: 'Karan Joshi', className: 'IX', section: 'A', rollNumber: '18', email: 'karan.j@dasturschool.in', parentId: 'parent-005'),
    Student(id: 'student-006', name: 'Sneha Patil', className: 'IX', section: 'A', rollNumber: '22', email: 'sneha.p@dasturschool.in', parentId: 'parent-006'),
    Student(id: 'student-007', name: 'Aditya Kulkarni', className: 'VII', section: 'A', rollNumber: '08', email: 'aditya.k@dasturschool.in', parentId: 'parent-007'),
    Student(id: 'student-008', name: 'Meera Nair', className: 'X', section: 'A', rollNumber: '31', email: 'meera.n@dasturschool.in', parentId: 'parent-008'),
  ];

  // ─── PARENT ───────────────────────────────────────────────────────
  static final Parent demoParent = Parent(
    id: 'parent-001',
    name: 'Mr. Rohan Mehta',
    linkedStudentId: 'student-001',
    parentId: 'DSHH-P-2024-0024',
    qrCodeId: 'DASTUR-QR-P001-2024',
    phone: '+91 98765 43210',
    email: 'parent@dasturschool.in',
  );

  // ─── TEACHER ──────────────────────────────────────────────────────
  static final Teacher demoTeacher = Teacher(
    id: 'teacher-001',
    name: 'Mrs. Priya Sharma',
    email: 'teacher@dasturschool.in',
    phone: '+91 99887 76655',
    assignedClasses: ['VIII-A', 'VIII-B', 'IX-A'],
    subjects: ['Mathematics', 'Science'],
  );

  static final List<Teacher> allTeachers = [
    demoTeacher,
    Teacher(id: 'teacher-002', name: 'Mr. Rajesh Patel', email: 'rajesh.p@dasturschool.in', phone: '+91 98765 11111', assignedClasses: ['VIII-A', 'IX-A'], subjects: ['English', 'Hindi']),
    Teacher(id: 'teacher-003', name: 'Mrs. Sunita Deshpande', email: 'sunita.d@dasturschool.in', phone: '+91 98765 22222', assignedClasses: ['VII-A', 'VIII-A'], subjects: ['Social Science', 'Marathi']),
    Teacher(id: 'teacher-004', name: 'Mr. Vikram Rao', email: 'vikram.r@dasturschool.in', phone: '+91 98765 33333', assignedClasses: ['X-A', 'IX-A'], subjects: ['Mathematics', 'Physics']),
  ];

  // ─── ANNOUNCEMENTS ────────────────────────────────────────────────
  static final List<Announcement> announcements = [
    Announcement(
      id: 'ann-001',
      title: 'Annual Sports Day 2026',
      body: 'We are excited to announce the Annual Sports Day on 15th March 2026. All students are requested to participate in at least one event. Parents are cordially invited to witness the events. Reporting time: 8:00 AM at the school ground.',
      date: DateTime(2026, 3, 5),
      type: 'event',
      authorId: 'admin-001',
      authorName: 'Dr. Meher Irani',
    ),
    Announcement(
      id: 'ann-002',
      title: 'Unit Test 2 Schedule Released',
      body: 'The schedule for Unit Test 2 (March 2026) has been released. Please check the Exam Timetable section for date-wise subject allocation. Students are advised to begin preparation.',
      date: DateTime(2026, 3, 3),
      type: 'notice',
      authorId: 'admin-001',
      authorName: 'Dr. Meher Irani',
    ),
    Announcement(
      id: 'ann-003',
      title: 'PTM Notice – March 2026',
      body: 'A Parent-Teacher Meeting is scheduled for 22nd March 2026 (Saturday). Timings: 9:00 AM to 12:00 PM. Parents are requested to attend without fail. Please carry the PTM slip provided.',
      date: DateTime(2026, 3, 1),
      type: 'circular',
      authorId: 'teacher-001',
      authorName: 'Mrs. Priya Sharma',
      targetClass: 'VIII-A',
    ),
    Announcement(
      id: 'ann-004',
      title: 'School Closed – Holi Festival',
      body: 'The school will remain closed on 14th March 2026 (Friday) on account of Holi. Regular classes will resume on Monday, 17th March 2026. Wishing all a Happy Holi!',
      date: DateTime(2026, 2, 28),
      type: 'alert',
      authorId: 'admin-001',
      authorName: 'Dr. Meher Irani',
    ),
    Announcement(
      id: 'ann-005',
      title: 'Science Exhibition – Registrations Open',
      body: 'Registrations are now open for the Inter-School Science Exhibition to be held on 28th March 2026. Interested students may register through their Science teacher. Last date: 20th March.',
      date: DateTime(2026, 2, 25),
      type: 'event',
      authorId: 'admin-001',
      authorName: 'Dr. Meher Irani',
    ),
  ];

  // ─── ATTENDANCE (for demo student - March 2026) ───────────────────
  static List<AttendanceRecord> getAttendanceRecords() {
    final List<AttendanceRecord> records = [];
    // Generate attendance for the current month demo
    final now = DateTime(2026, 3, 10);
    for (int day = 1; day <= now.day; day++) {
      final date = DateTime(2026, 3, day);
      // Skip Sundays
      if (date.weekday == DateTime.sunday) continue;
      // Skip 2nd and 4th Saturdays
      if (date.weekday == DateTime.saturday) {
        final weekOfMonth = ((day - 1) / 7).floor() + 1;
        if (weekOfMonth == 2 || weekOfMonth == 4) continue;
      }

      String status = 'present';
      if (day == 4) status = 'absent';
      if (day == 7) status = 'leave';

      records.add(AttendanceRecord(
        id: 'att-$day',
        studentId: 'student-001',
        date: date,
        status: status,
        markedBy: 'teacher-001',
      ));
    }
    return records;
  }

  // ─── FEES ─────────────────────────────────────────────────────────
  static final FeeRecord demoFeeRecord = FeeRecord(
    id: 'fee-001',
    studentId: 'student-001',
    totalFees: 45000,
    paidFees: 30000,
    pendingFees: 15000,
    payments: [
      PaymentEntry(amount: 15000, date: DateTime(2025, 6, 15), method: 'online', receiptId: 'RCPT-2025-001'),
      PaymentEntry(amount: 15000, date: DateTime(2025, 10, 10), method: 'online', receiptId: 'RCPT-2025-002'),
    ],
  );

  // ─── TIMETABLE ────────────────────────────────────────────────────
  static final List<TimetableEntry> timetable = [
    // Monday
    TimetableEntry(id: 'tt-01', classId: 'VIII-A', day: 'Monday', period: 1, subject: 'Mathematics', teacherName: 'Mrs. Priya Sharma', time: '8:00 - 8:40'),
    TimetableEntry(id: 'tt-02', classId: 'VIII-A', day: 'Monday', period: 2, subject: 'English', teacherName: 'Mr. Rajesh Patel', time: '8:40 - 9:20'),
    TimetableEntry(id: 'tt-03', classId: 'VIII-A', day: 'Monday', period: 3, subject: 'Science', teacherName: 'Mrs. Priya Sharma', time: '9:20 - 10:00'),
    TimetableEntry(id: 'tt-04', classId: 'VIII-A', day: 'Monday', period: 4, subject: 'Hindi', teacherName: 'Mr. Rajesh Patel', time: '10:20 - 11:00'),
    TimetableEntry(id: 'tt-05', classId: 'VIII-A', day: 'Monday', period: 5, subject: 'Social Science', teacherName: 'Mrs. Sunita Deshpande', time: '11:00 - 11:40'),
    TimetableEntry(id: 'tt-06', classId: 'VIII-A', day: 'Monday', period: 6, subject: 'Marathi', teacherName: 'Mrs. Sunita Deshpande', time: '11:40 - 12:20'),
    TimetableEntry(id: 'tt-07', classId: 'VIII-A', day: 'Monday', period: 7, subject: 'Physical Education', teacherName: 'Mr. Vikram Rao', time: '1:00 - 1:40'),
    // Tuesday
    TimetableEntry(id: 'tt-08', classId: 'VIII-A', day: 'Tuesday', period: 1, subject: 'Science', teacherName: 'Mrs. Priya Sharma', time: '8:00 - 8:40'),
    TimetableEntry(id: 'tt-09', classId: 'VIII-A', day: 'Tuesday', period: 2, subject: 'Mathematics', teacherName: 'Mrs. Priya Sharma', time: '8:40 - 9:20'),
    TimetableEntry(id: 'tt-10', classId: 'VIII-A', day: 'Tuesday', period: 3, subject: 'English', teacherName: 'Mr. Rajesh Patel', time: '9:20 - 10:00'),
    TimetableEntry(id: 'tt-11', classId: 'VIII-A', day: 'Tuesday', period: 4, subject: 'Marathi', teacherName: 'Mrs. Sunita Deshpande', time: '10:20 - 11:00'),
    TimetableEntry(id: 'tt-12', classId: 'VIII-A', day: 'Tuesday', period: 5, subject: 'Hindi', teacherName: 'Mr. Rajesh Patel', time: '11:00 - 11:40'),
    TimetableEntry(id: 'tt-13', classId: 'VIII-A', day: 'Tuesday', period: 6, subject: 'Art', teacherName: 'Mrs. Sunita Deshpande', time: '11:40 - 12:20'),
    TimetableEntry(id: 'tt-14', classId: 'VIII-A', day: 'Tuesday', period: 7, subject: 'Computer Science', teacherName: 'Mr. Vikram Rao', time: '1:00 - 1:40'),
    // Wednesday
    TimetableEntry(id: 'tt-15', classId: 'VIII-A', day: 'Wednesday', period: 1, subject: 'English', teacherName: 'Mr. Rajesh Patel', time: '8:00 - 8:40'),
    TimetableEntry(id: 'tt-16', classId: 'VIII-A', day: 'Wednesday', period: 2, subject: 'Science', teacherName: 'Mrs. Priya Sharma', time: '8:40 - 9:20'),
    TimetableEntry(id: 'tt-17', classId: 'VIII-A', day: 'Wednesday', period: 3, subject: 'Mathematics', teacherName: 'Mrs. Priya Sharma', time: '9:20 - 10:00'),
    TimetableEntry(id: 'tt-18', classId: 'VIII-A', day: 'Wednesday', period: 4, subject: 'Social Science', teacherName: 'Mrs. Sunita Deshpande', time: '10:20 - 11:00'),
    TimetableEntry(id: 'tt-19', classId: 'VIII-A', day: 'Wednesday', period: 5, subject: 'Marathi', teacherName: 'Mrs. Sunita Deshpande', time: '11:00 - 11:40'),
    TimetableEntry(id: 'tt-20', classId: 'VIII-A', day: 'Wednesday', period: 6, subject: 'Hindi', teacherName: 'Mr. Rajesh Patel', time: '11:40 - 12:20'),
    TimetableEntry(id: 'tt-21', classId: 'VIII-A', day: 'Wednesday', period: 7, subject: 'Library', teacherName: 'Mrs. Sunita Deshpande', time: '1:00 - 1:40'),
    // Thursday
    TimetableEntry(id: 'tt-22', classId: 'VIII-A', day: 'Thursday', period: 1, subject: 'Hindi', teacherName: 'Mr. Rajesh Patel', time: '8:00 - 8:40'),
    TimetableEntry(id: 'tt-23', classId: 'VIII-A', day: 'Thursday', period: 2, subject: 'Mathematics', teacherName: 'Mrs. Priya Sharma', time: '8:40 - 9:20'),
    TimetableEntry(id: 'tt-24', classId: 'VIII-A', day: 'Thursday', period: 3, subject: 'Social Science', teacherName: 'Mrs. Sunita Deshpande', time: '9:20 - 10:00'),
    TimetableEntry(id: 'tt-25', classId: 'VIII-A', day: 'Thursday', period: 4, subject: 'English', teacherName: 'Mr. Rajesh Patel', time: '10:20 - 11:00'),
    TimetableEntry(id: 'tt-26', classId: 'VIII-A', day: 'Thursday', period: 5, subject: 'Science', teacherName: 'Mrs. Priya Sharma', time: '11:00 - 11:40'),
    TimetableEntry(id: 'tt-27', classId: 'VIII-A', day: 'Thursday', period: 6, subject: 'Computer Science', teacherName: 'Mr. Vikram Rao', time: '11:40 - 12:20'),
    TimetableEntry(id: 'tt-28', classId: 'VIII-A', day: 'Thursday', period: 7, subject: 'Physical Education', teacherName: 'Mr. Vikram Rao', time: '1:00 - 1:40'),
    // Friday
    TimetableEntry(id: 'tt-29', classId: 'VIII-A', day: 'Friday', period: 1, subject: 'Science', teacherName: 'Mrs. Priya Sharma', time: '8:00 - 8:40'),
    TimetableEntry(id: 'tt-30', classId: 'VIII-A', day: 'Friday', period: 2, subject: 'English', teacherName: 'Mr. Rajesh Patel', time: '8:40 - 9:20'),
    TimetableEntry(id: 'tt-31', classId: 'VIII-A', day: 'Friday', period: 3, subject: 'Hindi', teacherName: 'Mr. Rajesh Patel', time: '9:20 - 10:00'),
    TimetableEntry(id: 'tt-32', classId: 'VIII-A', day: 'Friday', period: 4, subject: 'Mathematics', teacherName: 'Mrs. Priya Sharma', time: '10:20 - 11:00'),
    TimetableEntry(id: 'tt-33', classId: 'VIII-A', day: 'Friday', period: 5, subject: 'Marathi', teacherName: 'Mrs. Sunita Deshpande', time: '11:00 - 11:40'),
    TimetableEntry(id: 'tt-34', classId: 'VIII-A', day: 'Friday', period: 6, subject: 'Art', teacherName: 'Mrs. Sunita Deshpande', time: '11:40 - 12:20'),
    TimetableEntry(id: 'tt-35', classId: 'VIII-A', day: 'Friday', period: 7, subject: 'Social Science', teacherName: 'Mrs. Sunita Deshpande', time: '1:00 - 1:40'),
    // Saturday (condensed)
    TimetableEntry(id: 'tt-36', classId: 'VIII-A', day: 'Saturday', period: 1, subject: 'Mathematics', teacherName: 'Mrs. Priya Sharma', time: '8:00 - 8:40'),
    TimetableEntry(id: 'tt-37', classId: 'VIII-A', day: 'Saturday', period: 2, subject: 'Science', teacherName: 'Mrs. Priya Sharma', time: '8:40 - 9:20'),
    TimetableEntry(id: 'tt-38', classId: 'VIII-A', day: 'Saturday', period: 3, subject: 'English', teacherName: 'Mr. Rajesh Patel', time: '9:20 - 10:00'),
    TimetableEntry(id: 'tt-39', classId: 'VIII-A', day: 'Saturday', period: 4, subject: 'Social Science', teacherName: 'Mrs. Sunita Deshpande', time: '10:20 - 11:00'),
  ];

  // ─── EXAM TIMETABLE ───────────────────────────────────────────────
  static final List<ExamTimetableEntry> examTimetable = [
    ExamTimetableEntry(id: 'et-01', classId: 'VIII-A', examName: 'Unit Test 2', date: DateTime(2026, 3, 17), subject: 'Mathematics', time: '10:00 AM - 11:30 AM'),
    ExamTimetableEntry(id: 'et-02', classId: 'VIII-A', examName: 'Unit Test 2', date: DateTime(2026, 3, 18), subject: 'Science', time: '10:00 AM - 11:30 AM'),
    ExamTimetableEntry(id: 'et-03', classId: 'VIII-A', examName: 'Unit Test 2', date: DateTime(2026, 3, 19), subject: 'English', time: '10:00 AM - 11:30 AM'),
    ExamTimetableEntry(id: 'et-04', classId: 'VIII-A', examName: 'Unit Test 2', date: DateTime(2026, 3, 20), subject: 'Hindi', time: '10:00 AM - 11:30 AM'),
    ExamTimetableEntry(id: 'et-05', classId: 'VIII-A', examName: 'Unit Test 2', date: DateTime(2026, 3, 21), subject: 'Social Science', time: '10:00 AM - 11:30 AM'),
    ExamTimetableEntry(id: 'et-06', classId: 'VIII-A', examName: 'Unit Test 2', date: DateTime(2026, 3, 22), subject: 'Marathi', time: '10:00 AM - 11:30 AM'),
  ];

  // ─── SUBJECTS / SYLLABUS ──────────────────────────────────────────
  static final List<Subject> subjects = [
    Subject(id: 'sub-01', name: 'Mathematics', classId: 'VIII-A', chapters: [
      Chapter(name: 'Rational Numbers', completed: true),
      Chapter(name: 'Linear Equations in One Variable', completed: true),
      Chapter(name: 'Understanding Quadrilaterals', completed: true),
      Chapter(name: 'Data Handling', completed: false),
      Chapter(name: 'Squares and Square Roots', completed: false),
      Chapter(name: 'Cubes and Cube Roots', completed: false),
      Chapter(name: 'Comparing Quantities', completed: false),
      Chapter(name: 'Algebraic Expressions', completed: false),
    ]),
    Subject(id: 'sub-02', name: 'Science', classId: 'VIII-A', chapters: [
      Chapter(name: 'Crop Production and Management', completed: true),
      Chapter(name: 'Microorganisms', completed: true),
      Chapter(name: 'Synthetic Fibres and Plastics', completed: false),
      Chapter(name: 'Materials: Metals and Non-Metals', completed: false),
      Chapter(name: 'Coal and Petroleum', completed: false),
      Chapter(name: 'Combustion and Flame', completed: false),
    ]),
    Subject(id: 'sub-03', name: 'English', classId: 'VIII-A', chapters: [
      Chapter(name: 'The Best Christmas Present', completed: true),
      Chapter(name: 'The Tsunami', completed: true),
      Chapter(name: 'Glimpses of the Past', completed: true),
      Chapter(name: 'Bepin Choudhury\'s Lapse of Memory', completed: false),
      Chapter(name: 'The Summit Within', completed: false),
    ]),
    Subject(id: 'sub-04', name: 'Hindi', classId: 'VIII-A', chapters: [
      Chapter(name: 'ध्वनि', completed: true),
      Chapter(name: 'लाख की चूड़ियाँ', completed: true),
      Chapter(name: 'बस की यात्रा', completed: false),
      Chapter(name: 'दीवानों की हस्ती', completed: false),
    ]),
    Subject(id: 'sub-05', name: 'Social Science', classId: 'VIII-A', chapters: [
      Chapter(name: 'How, When and Where', completed: true),
      Chapter(name: 'From Trade to Territory', completed: true),
      Chapter(name: 'Ruling the Countryside', completed: false),
      Chapter(name: 'Tribals, Dikus and the Vision of a Golden Age', completed: false),
    ]),
    Subject(id: 'sub-06', name: 'Marathi', classId: 'VIII-A', chapters: [
      Chapter(name: 'माझा अभ्यास', completed: true),
      Chapter(name: 'आमची शाळा', completed: true),
      Chapter(name: 'निसर्ग सौंदर्य', completed: false),
    ]),
  ];

  // ─── E-BOOKS ──────────────────────────────────────────────────────
  static final List<Ebook> ebooks = [
    Ebook(id: 'eb-01', title: 'Mathematics Textbook', subject: 'Mathematics', classId: 'VIII-A', pdfUrl: 'https://ncert.nic.in/textbook/pdf/hemh1dd.zip'),
    Ebook(id: 'eb-02', title: 'Science Textbook', subject: 'Science', classId: 'VIII-A', pdfUrl: 'https://ncert.nic.in/textbook/pdf/hesc1dd.zip'),
    Ebook(id: 'eb-03', title: 'English - Honeydew', subject: 'English', classId: 'VIII-A', pdfUrl: 'https://ncert.nic.in/textbook/pdf/heen1dd.zip'),
    Ebook(id: 'eb-04', title: 'Hindi - Vasant', subject: 'Hindi', classId: 'VIII-A', pdfUrl: 'https://ncert.nic.in/textbook/pdf/hhvs1dd.zip'),
    Ebook(id: 'eb-05', title: 'Social Science - Our Pasts III', subject: 'Social Science', classId: 'VIII-A', pdfUrl: 'https://ncert.nic.in/textbook/pdf/hess1dd.zip'),
    Ebook(id: 'eb-06', title: 'Mathematics Workbook', subject: 'Mathematics', classId: 'VIII-A', pdfUrl: 'https://ncert.nic.in/textbook/pdf/hemh1dd.zip'),
  ];

  // ─── QUIZZES ──────────────────────────────────────────────────────
  static final List<Quiz> quizzes = [
    Quiz(
      id: 'quiz-01',
      classId: 'VIII-A',
      subject: 'Mathematics',
      title: 'Rational Numbers Quick Test',
      createdBy: 'teacher-001',
      questions: [
        QuizQuestion(text: 'Which of the following is a rational number?', options: ['√2', '√3', '3/4', 'π'], correctIndex: 2),
        QuizQuestion(text: 'What is the additive inverse of -7/3?', options: ['7/3', '-7/3', '3/7', '-3/7'], correctIndex: 0),
        QuizQuestion(text: 'Which property states a + b = b + a?', options: ['Associative', 'Commutative', 'Distributive', 'Identity'], correctIndex: 1),
        QuizQuestion(text: '0 is the _____ identity for rational numbers.', options: ['Multiplicative', 'Additive', 'Both', 'Neither'], correctIndex: 1),
        QuizQuestion(text: 'The multiplicative inverse of -1 is:', options: ['1', '-1', '0', 'Undefined'], correctIndex: 1),
      ],
    ),
    Quiz(
      id: 'quiz-02',
      classId: 'VIII-A',
      subject: 'Science',
      title: 'Microorganisms Chapter Test',
      createdBy: 'teacher-001',
      questions: [
        QuizQuestion(text: 'Which of the following is a unicellular organism?', options: ['Mushroom', 'Amoeba', 'Fern', 'Moss'], correctIndex: 1),
        QuizQuestion(text: 'Penicillin is obtained from:', options: ['Bacteria', 'Virus', 'Fungus', 'Algae'], correctIndex: 2),
        QuizQuestion(text: 'Which disease is caused by a virus?', options: ['Cholera', 'Typhoid', 'Common Cold', 'Malaria'], correctIndex: 2),
        QuizQuestion(text: 'Pasteurization was invented by:', options: ['Edward Jenner', 'Louis Pasteur', 'Alexander Fleming', 'Robert Koch'], correctIndex: 1),
      ],
    ),
    Quiz(
      id: 'quiz-03',
      classId: 'VIII-A',
      subject: 'English',
      title: 'Grammar – Tenses Quiz',
      createdBy: 'teacher-002',
      questions: [
        QuizQuestion(text: 'She ___ to school every day.', options: ['go', 'goes', 'going', 'went'], correctIndex: 1),
        QuizQuestion(text: 'They ___ playing cricket since morning.', options: ['have been', 'has been', 'are', 'were'], correctIndex: 0),
        QuizQuestion(text: 'The past participle of "write" is:', options: ['writed', 'wrote', 'written', 'writing'], correctIndex: 2),
      ],
    ),
  ];

  // ─── PRACTICE PAPERS ──────────────────────────────────────────────
  static final List<PracticePaper> practicePapers = [
    PracticePaper(id: 'pp-01', title: 'Unit Test 1 - Question Paper', subject: 'Mathematics', classId: 'VIII-A', examType: 'unit_test', pdfUrl: 'https://example.com/math_ut1.pdf'),
    PracticePaper(id: 'pp-02', title: 'Mid-Term Practice Paper', subject: 'Mathematics', classId: 'VIII-A', examType: 'midterm', pdfUrl: 'https://example.com/math_mid.pdf'),
    PracticePaper(id: 'pp-03', title: 'Unit Test 1 - Question Paper', subject: 'Science', classId: 'VIII-A', examType: 'unit_test', pdfUrl: 'https://example.com/sci_ut1.pdf'),
    PracticePaper(id: 'pp-04', title: 'Previous Year Final Exam', subject: 'Science', classId: 'VIII-A', examType: 'final', pdfUrl: 'https://example.com/sci_final.pdf'),
    PracticePaper(id: 'pp-05', title: 'Grammar Practice Sheet', subject: 'English', classId: 'VIII-A', examType: 'practice', pdfUrl: 'https://example.com/eng_practice.pdf'),
    PracticePaper(id: 'pp-06', title: 'Previous Year Final Exam', subject: 'English', classId: 'VIII-A', examType: 'final', pdfUrl: 'https://example.com/eng_final.pdf'),
  ];

  // ─── PTM ──────────────────────────────────────────────────────────
  static final List<Ptm> ptmSchedule = [
    Ptm(
      id: 'ptm-01',
      classId: 'VIII-A',
      date: DateTime(2026, 3, 22),
      teacherName: 'Mrs. Priya Sharma',
      instructions: 'Please carry the PTM slip and previous report card. Discussion topics: Unit Test 2 preparation, attendance, and overall progress.',
    ),
    Ptm(
      id: 'ptm-02',
      classId: 'VIII-A',
      date: DateTime(2026, 5, 10),
      teacherName: 'Mrs. Priya Sharma',
      instructions: 'Mid-year progress review. Results of Mid-Term exams will be discussed. Please bring the signed report card.',
    ),
  ];

  // ─── CALENDAR EVENTS ──────────────────────────────────────────────
  static final List<CalendarEvent> calendarEvents = [
    CalendarEvent(id: 'ce-01', date: DateTime(2026, 1, 26), title: 'Republic Day', type: 'holiday'),
    CalendarEvent(id: 'ce-02', date: DateTime(2026, 2, 15), title: 'Mid-Term Exams Begin', type: 'exam'),
    CalendarEvent(id: 'ce-03', date: DateTime(2026, 2, 22), title: 'Mid-Term Exams End', type: 'exam'),
    CalendarEvent(id: 'ce-04', date: DateTime(2026, 3, 8), title: 'International Women\'s Day Celebration', type: 'event'),
    CalendarEvent(id: 'ce-05', date: DateTime(2026, 3, 14), title: 'Holi Holiday', type: 'holiday'),
    CalendarEvent(id: 'ce-06', date: DateTime(2026, 3, 15), title: 'Annual Sports Day', type: 'event'),
    CalendarEvent(id: 'ce-07', date: DateTime(2026, 3, 17), title: 'Unit Test 2 Begins', type: 'exam'),
    CalendarEvent(id: 'ce-08', date: DateTime(2026, 3, 22), title: 'Parent-Teacher Meeting', type: 'ptm'),
    CalendarEvent(id: 'ce-09', date: DateTime(2026, 3, 28), title: 'Science Exhibition', type: 'event'),
    CalendarEvent(id: 'ce-10', date: DateTime(2026, 4, 6), title: 'Gudi Padwa', type: 'holiday'),
    CalendarEvent(id: 'ce-11', date: DateTime(2026, 4, 14), title: 'Ambedkar Jayanti', type: 'holiday'),
    CalendarEvent(id: 'ce-12', date: DateTime(2026, 5, 1), title: 'Maharashtra Day', type: 'holiday'),
    CalendarEvent(id: 'ce-13', date: DateTime(2026, 5, 15), title: 'Summer Vacation Begins', type: 'holiday'),
    CalendarEvent(id: 'ce-14', date: DateTime(2026, 6, 15), title: 'School Reopens', type: 'event'),
    CalendarEvent(id: 'ce-15', date: DateTime(2026, 8, 15), title: 'Independence Day', type: 'holiday'),
    CalendarEvent(id: 'ce-16', date: DateTime(2026, 9, 5), title: 'Teacher\'s Day', type: 'event'),
    CalendarEvent(id: 'ce-17', date: DateTime(2026, 10, 2), title: 'Gandhi Jayanti', type: 'holiday'),
    CalendarEvent(id: 'ce-18', date: DateTime(2026, 11, 14), title: 'Children\'s Day', type: 'event'),
  ];
}
