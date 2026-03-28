import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_page1.dart';
import 'emergency_info_screen.dart';
import 'home_dashboard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey            = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading       = false;
  bool _obscurePassword = true;

  // Emergency data loaded from last logged-in user
  Map<String, String>? _emergencyData;

  static const _blue      = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF1E88E5);

  @override
  void initState() {
    super.initState();
    _loadLastUserEmergencyData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Load last logged-in user's emergency data ─────────────────────────────
  Future<void> _loadLastUserEmergencyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('last_user_uid');
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) return;
      final data = doc.data()!;

      if (!mounted) return;
      setState(() {
        _emergencyData = {
          'name':                 data['name']                  ?? 'Unknown',
          'age':                  data['age']                   ?? 'N/A',
          'gender':               data['gender']                ?? 'N/A',
          'bloodGroup':           data['bloodGroup']            ?? 'N/A',
          'allergies':            data['allergies']             ?? '',
          'conditions':           data['conditions']            ?? '',
          'medications':          data['medications']           ?? '',
          'surgeries':            data['surgeries']             ?? '',
          'emergencyContactName': data['emergencyContactName']  ?? '',
          'emergencyContactPhone':data['emergencyContactPhone'] ?? '',
        };
      });
    } catch (_) {
      // Silently fail — emergency button will just not show
    }
  }

  // ── Sign In ───────────────────────────────────────────────────────────────
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email:    _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) {
        _showError('Something went wrong. Please try again.');
        return;
      }

      // Fetch user data from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        _showError('No account found. Please sign up first.');
        return;
      }

      // ── Save UID for emergency info on login screen ──────────────────────
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_user_uid', user.uid);

      final data = doc.data()!;
      setState(() => _isLoading = false);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeDashboard(
            userName:              data['name']                  ?? 'User',
            userEmail:             user.email                    ?? '',
            age:                   data['age']                   ?? '—',
            gender:                data['gender']                ?? '—',
            bloodGroup:            data['bloodGroup']            ?? '—',
            allergies:             data['allergies']             ?? '',
            conditions:            data['conditions']            ?? '',
            medications:           data['medications']           ?? '',
            surgeries:             data['surgeries']             ?? '',
            emergencyContactName:  data['emergencyContactName']  ?? '',
            emergencyContactPhone: data['emergencyContactPhone'] ?? '',
          ),
        ),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showError(switch (e.code) {
        'user-not-found'     => 'No account found for this email. Please sign up.',
        'wrong-password'     => 'Incorrect password. Please try again.',
        'invalid-email'      => 'Please enter a valid email address.',
        'user-disabled'      => 'This account has been disabled.',
        'invalid-credential' => 'Incorrect email or password. Please try again.',
        _                    => e.message ?? 'Sign in failed. Please try again.',
      });
    }
  }

  // ── Forgot Password ───────────────────────────────────────────────────────
  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email address first.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $email'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(12),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Failed to send reset email.');
    }
  }

  void _showError(String message) {
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ── Open Emergency Info ───────────────────────────────────────────────────
  void _openEmergencyInfo() {
    final d = _emergencyData;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmergencyInfoScreen(
          name:                 d?['name']                  ?? 'Unknown',
          age:                  d?['age']                   ?? 'N/A',
          gender:               d?['gender']                ?? 'N/A',
          bloodGroup:           d?['bloodGroup']            ?? 'N/A',
          allergies:            d?['allergies']             ?? '',
          conditions:           d?['conditions']            ?? '',
          medications:          d?['medications']           ?? '',
          surgeries:            d?['surgeries']             ?? '',
          emergencyContactName: d?['emergencyContactName']  ?? '',
          emergencyContactPhone:d?['emergencyContactPhone'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_blue, _blueLight],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // ── Logo ──────────────────────────────────────────────────
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.local_hospital,
                              size: 48, color: _blue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('MediVault',
                      style: TextStyle(
                          color: Colors.white, fontSize: 30,
                          fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 6),
                  const Text('Welcome back!',
                      style: TextStyle(color: Colors.white70,
                          fontSize: 15, letterSpacing: 0.3)),

                  const SizedBox(height: 36),

                  // ── Sign In Card ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sign In',
                            style: TextStyle(color: Color(0xFF1A1A2E),
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Enter your credentials to continue',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 13)),
                        const SizedBox(height: 24),

                        // Email
                        _buildLabel('Email Address'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                              color: Color(0xFF1A1A2E), fontSize: 15),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(v.trim())) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          decoration: _inputDecoration(
                              hint: 'you@example.com',
                              icon: Icons.email_outlined),
                        ),
                        const SizedBox(height: 18),

                        // Password
                        _buildLabel('Password'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                              color: Color(0xFF1A1A2E), fontSize: 15),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your password';
                            }
                            if (v.trim().length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          decoration: _inputDecoration(
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey.shade400, size: 20,
                              ),
                              onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            child: const Text('Forgot password?',
                                style: TextStyle(color: _blue,
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ),

                        // Sign In button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                height: 22, width: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                                : const Text('Sign In',
                                style: TextStyle(fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Sign Up link ──────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ",
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14)),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpPage1())),
                        child: const Text('Sign Up',
                            style: TextStyle(
                                color: Colors.white, fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Divider ───────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: Colors.white.withValues(alpha: 0.4),
                              thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('or',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14)),
                      ),
                      Expanded(
                          child: Divider(
                              color: Colors.white.withValues(alpha: 0.4),
                              thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Emergency Info Button ─────────────────────────────────
                  // Only show if we have a previously logged-in user's data
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openEmergencyInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.emergency_rounded,
                          size: 22, color: Colors.white),
                      label: const Text('Emergency Info',
                          style: TextStyle(fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _emergencyData != null
                        ? 'Showing emergency info for ${_emergencyData!['name']}'
                        : 'Access critical medical info without login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(color: Color(0xFF1A1A2E),
            fontSize: 14, fontWeight: FontWeight.w600));
  }

  InputDecoration _inputDecoration(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: _blue, size: 20),
      filled: true,
      fillColor: const Color(0xFFF5F8FF),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _blue.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _blue.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}