# Dastur School Parent Portal

A comprehensive cross-platform Flutter application serving parents, teachers, and administrators of Sardar Dastur Hormazdiar High School (Pune).

## Features

- **3 User Roles:** Admin, Teacher, and Parent with role-based routing.
- **Premium Design System:** Dark navy gradients, gold accents, styled dashboard tiles.
- **Mock Data Engine:** Pre-loaded with students, teachers, classes, quizzes, and attendance records for immediate testing without a backend.
- **30+ Screens:** Everything from attendance calendars and syllabus tracking to interactive quizzes and a Virtual Parent ID Card.

## Demo Credentials
Log into the app easily using the following credentials. All share the same password: `dastur123`

- **Admin Account:** `admin@dasturschool.in`
- **Teacher Account:** `teacher@dasturschool.in`
- **Parent Account:** `parent@dasturschool.in`

## Getting Started

1. **Install Dependencies:**
   Ensure you have Flutter installed. Then run:
   ```bash
   flutter pub get
   ```

2. **Run the App:**
   Connect a device or emulator and run:
   ```bash
   flutter run
   ```

## Project Structure

- `lib/core/`: Contains the design system, colors, constants, and global theme configurations.
- `lib/models/`: Contains the 12 data models (Student, Quiz, AppUser, etc.).
- `lib/services/`: Authentication and Mock Data services.
- `lib/widgets/`: Highly reusable UI widgets (DashboardTile, GradientAppBar, RoleBadge, etc.).
- `lib/screens/`: Divided into `/auth`, `/admin`, `/teacher`, `/parent`, and `/shared`.
- `lib/main.dart`: Standard app entry point handling initialized providers and all navigation routes.

## Deployment Notes
- Firebase integration is modeled out but currently utilizes the `MockDataService`. Run `flutterfire configure` to attach a live Firebase backend in production.
- Payment processing inside the Fees screen uses a placeholder dialog pending API key injection for a gateway like Razorpay.
