import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../services/auth_service.dart';

/// Login Screen
///
/// School-branded login page that authenticates parents, teachers,
/// and admins. Uses a premium dark gradient with gold accents.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _grController = TextEditingController(); // Specific for Parents
  
  String? _selectedPortal; // 'admin', 'teacher', 'parent'
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _grController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMessage = null);

    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Construct email for parents automatically
    String email = _emailController.text.trim();
    if (_selectedPortal == 'parent') {
      email = '${_grController.text.trim()}@dastur.org';
    }

    try {
      final success = await authService.login(
        email,
        _passwordController.text.trim(),
        requiredRole: _selectedPortal,
      );

      if (success && mounted) {
        // We don't need to navigate manually if AuthWrapper is listening to AuthService
        // and switching the screen based on the logged in state.
        // However, we can still keep it as a fallback or if we want specific transitions.
        // In a reactive flow, simply reaching 'success' is enough.
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Image.asset(
                    'assets/images/school_logo.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  const Text(AppConstants.schoolShortName,
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  const Text('“Good Thoughts, Good Words, Good Deeds”', 
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.accent, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 40),
                  
                  if (_selectedPortal == null) _buildPortalSelection() else _buildLoginForm(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortalSelection() {
    return Column(
      children: [
        const Text('Select Your Portal', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 24),
        _portalCard('Admin Portal', Icons.admin_panel_settings, 'admin', AppColors.accent),
        _portalCard('Teacher Portal', Icons.assignment_ind, 'teacher', Colors.blueAccent),
        _portalCard('Parent Portal', Icons.family_restroom, 'parent', Colors.orangeAccent),
      ],
    );
  }

  Widget _portalCard(String title, IconData icon, String role, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        child: InkWell(
          onTap: () => setState(() => _selectedPortal = role),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusXl),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final title = _selectedPortal == 'admin' ? 'Admin Login' : (_selectedPortal == 'teacher' ? 'Teacher Login' : 'Parent Login');
    final authService = Provider.of<AuthService>(context);

    return Column(
      children: [
        Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white70), onPressed: () => setState(() { _selectedPortal = null; _errorMessage = null; })),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_selectedPortal == 'parent') ...[
                  TextFormField(
                    controller: _grController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('GR Number', Icons.numbers_outlined, hint: 'e.g. 2024001'),
                    validator: (v) => v!.isEmpty ? 'Enter GR Number' : null,
                  ),
                ] else ...[
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Email Address', Icons.email_outlined, hint: 'school@dastur.org'),
                    validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter a valid email' : null,
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter password' : null,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: authService.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: authService.isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark))
                      : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _showForgotPasswordDialog(context),
                  child: const Text('Forgot Password?', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label, hintText: hint,
      labelStyle: const TextStyle(color: Colors.white60),
      hintStyle: const TextStyle(color: Colors.white24),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      filled: true, fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent)),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your registered email.', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final success = await Provider.of<AuthService>(context, listen: false).resetPassword(emailCtrl.text.trim());
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Reset link sent!' : 'Error sending link.')));
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
