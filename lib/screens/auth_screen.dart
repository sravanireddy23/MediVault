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

  Map<String, String>? _emergencyData;
  bool _loadingEmergency = true;

  static const _blue      = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF1E88E5);

  @override
  void initState() {
    super.initState();
    _loadEmergencyDataFromPrefs();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Read emergency data directly from shared_preferences ─────────────────
  Future<void> _loadEmergencyDataFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('em_name');

      if (name != null && name.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _emergencyData = {
            'name':                  name,
            'age':                   prefs.getString('em_age')           ?? 'N/A',
            'gender':                prefs.getString('em_gender')        ?? 'N/A',
            'bloodGroup':            prefs.getString('em_bloodGroup')    ?? 'N/A',
            'allergies':             prefs.getString('em_allergies')     ?? '',
            'conditions':            prefs.getString('em_conditions')    ?? '',
            'medications':           prefs.getString('em_medications')   ?? '',
            'surgeries':             prefs.getString('em_surgeries')     ?? '',
            'emergencyContactName':  prefs.getString('em_contactName')  ?? '',
            'emergencyContactPhone': prefs.getString('em_contactPhone') ?? '',
          };
          _loadingEmergency = false;
        });
      } else {
        if (mounted) setState(() => _loadingEmergency = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingEmergency = false);
    }
  }

  // ── Save all emergency fields to shared_preferences ───────────────────────
  static Future<void> saveEmergencyDataToPrefs(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('em_name',         data['name']?.toString()                  ?? '');
    await prefs.setString('em_age',          data['age']?.toString()                   ?? 'N/A');
    await prefs.setString('em_gender',       data['gender']?.toString()                ?? 'N/A');
    await prefs.setString('em_bloodGroup',   data['bloodGroup']?.toString()            ?? 'N/A');
    await prefs.setString('em_allergies',    data['allergies']?.toString()             ?? '');
    await prefs.setString('em_conditions',   data['conditions']?.toString()            ?? '');
    await prefs.setString('em_medications',  data['medications']?.toString()           ?? '');
    await prefs.setString('em_surgeries',    data['surgeries']?.toString()             ?? '');
    await prefs.setString('em_contactName',  data['emergencyContactName']?.toString()  ?? '');
    await prefs.setString('em_contactPhone', data['emergencyContactPhone']?.toString() ?? '');
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

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        _showError('No account found. Please sign up first.');
        return;
      }

      final data = doc.data()!;

      // Save ALL emergency fields to shared_preferences
      await saveEmergencyDataToPrefs(data);

      setState(() => _isLoading = false);
      if (!mounted) return;

      // ── KEY FIX: Clear any lingering snackbars before navigating ─────────
      ScaffoldMessenger.of(context).clearSnackBars();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeDashboard(
            userName:              data['name']?.toString()                  ?? 'User',
            userEmail:             user.email                                ?? '',
            age:                   data['age']?.toString()                   ?? '—',
            gender:                data['gender']?.toString()                ?? '—',
            bloodGroup:            data['bloodGroup']?.toString()            ?? '—',
            allergies:             data['allergies']?.toString()             ?? '',
            conditions:            data['conditions']?.toString()            ?? '',
            medications:           data['medications']?.toString()           ?? '',
            surgeries:             data['surgeries']?.toString()             ?? '',
            emergencyContactName:  data['emergencyContactName']?.toString()  ?? '',
            emergencyContactPhone: data['emergencyContactPhone']?.toString() ?? '',
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password reset email sent to $email'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ));
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Failed to send reset email.');
    }
  }

  void _showError(String message) {
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    ));
  }

  // ── Open Emergency Info ───────────────────────────────────────────────────
  void _openEmergencyInfo() {
    if (_emergencyData == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.info_outline_rounded, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text('Please sign in once to enable Emergency Info.')),
        ]),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ));
      return;
    }

    final d = _emergencyData!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmergencyInfoScreen(
          name:                  d['name']                  ?? 'Unknown',
          age:                   d['age']                   ?? 'N/A',
          gender:                d['gender']                ?? 'N/A',
          bloodGroup:            d['bloodGroup']            ?? 'N/A',
          allergies:             d['allergies']             ?? '',
          conditions:            d['conditions']            ?? '',
          medications:           d['medications']           ?? '',
          surgeries:             d['surgeries']             ?? '',
          emergencyContactName:  d['emergencyContactName']  ?? '',
          emergencyContactPhone: d['emergencyContactPhone'] ?? '',
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
                          blurRadius: 20, offset: const Offset(0, 8),
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
                          const Icon(Icons.local_hospital, size: 48, color: _blue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('MediVault',
                      style: TextStyle(color: Colors.white, fontSize: 30,
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
                          blurRadius: 20, offset: const Offset(0, 8),
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

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            child: const Text('Forgot password?',
                                style: TextStyle(color: _blue,
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ),

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
                                ? const SizedBox(height: 22, width: 22,
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
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpPage1())),
                        child: const Text('Sign Up',
                            style: TextStyle(color: Colors.white, fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Divider ───────────────────────────────────────────────
                  Row(children: [
                    Expanded(child: Divider(
                        color: Colors.white.withValues(alpha: 0.4), thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text('or',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14)),
                    ),
                    Expanded(child: Divider(
                        color: Colors.white.withValues(alpha: 0.4), thickness: 1)),
                  ]),

                  const SizedBox(height: 24),

                  // ── Emergency Info Button ─────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loadingEmergency ? null : _openEmergencyInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                        const Color(0xFFD32F2F).withValues(alpha: 0.7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      icon: _loadingEmergency
                          ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                          : const Icon(Icons.emergency_rounded,
                          size: 22, color: Colors.white),
                      label: const Text('Emergency Info',
                          style: TextStyle(fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _loadingEmergency
                        ? 'Loading emergency data...'
                        : _emergencyData != null
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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