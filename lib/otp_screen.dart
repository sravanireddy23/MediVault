import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_dashboard.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  final String verificationId; // NEW — passed from MobileScreen
  final String? userName;
  final String? age;
  final String? gender;
  final String? bloodGroup;
  final String? allergies;
  final String? conditions;
  final String? medications;
  final String? surgeries;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  const OtpScreen({
    super.key,
    required this.mobileNumber,
    required this.verificationId, // NEW
    this.userName,
    this.age,
    this.gender,
    this.bloodGroup,
    this.allergies,
    this.conditions,
    this.medications,
    this.surgeries,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendSeconds = 30;
  bool _canResend = false;
  bool _showError = false;
  String _errorMessage = '';
  bool _isLoading = false; // NEW

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 30;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
        }
      });
      return _resendSeconds > 0;
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  bool _isBoxEmpty(int index) {
    return _showError && _controllers[index].text.isEmpty;
  }

  // ── Real Firebase OTP verification ──────────────────
  void _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length < 6) {
      setState(() {
        _showError = true;
        _errorMessage = 'Please enter the complete 6-digit OTP';
      });
      for (int i = 0; i < 6; i++) {
        if (_controllers[i].text.isEmpty) {
          _focusNodes[i].requestFocus();
          break;
        }
      }
      return;
    }

    setState(() {
      _showError = false;
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      // Create credential using verificationId + OTP entered by user
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      // Sign in with the credential
      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'phone': user.phoneNumber,
          'name': widget.userName ?? 'User',
          'age': widget.age ?? '',
          'gender': widget.gender ?? '',
          'bloodGroup': widget.bloodGroup ?? '',
          'allergies': widget.allergies ?? '',
          'conditions': widget.conditions ?? '',
          'medications': widget.medications ?? '',
          'surgeries': widget.surgeries ?? '',
          'emergencyContactName': widget.emergencyContactName ?? '',
          'emergencyContactPhone': widget.emergencyContactPhone ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      setState(() {
        _isLoading = false;
      });

      // Navigate to HomeDashboard on success
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeDashboard(
              userName: widget.userName ?? 'User',
              age: widget.age ?? '—',
              gender: widget.gender ?? '—',
              bloodGroup: widget.bloodGroup ?? '—',
              allergies: widget.allergies ?? '',
              conditions: widget.conditions ?? '',
              medications: widget.medications ?? '',
              surgeries: widget.surgeries ?? '',
              emergencyContactName: widget.emergencyContactName ?? '',
              emergencyContactPhone: widget.emergencyContactPhone ?? '',
            ),
          ),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _showError = true;
        _errorMessage = switch (e.code) {
          'invalid-verification-code' => 'Invalid OTP. Please try again.',
          'session-expired' => 'OTP expired. Please resend.',
          _ => e.message ?? 'Verification failed. Try again.',
        };
      });
      // Clear all boxes on wrong OTP
      for (var c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
    }
  }

  // ── Resend OTP ───────────────────────────────────────
  void _resendOtp() async {
    for (var c in _controllers) c.clear();
    setState(() {
      _showError = false;
      _errorMessage = '';
    });
    _startResendTimer();
    _focusNodes[0].requestFocus();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91${widget.mobileNumber}',
      timeout: const Duration(seconds: 60),
      codeSent: (String verificationId, int? resendToken) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully!'),
            backgroundColor: Color(0xFF1565C0),
          ),
        );
      },
        verificationCompleted: (PhoneAuthCredential credential) async {
          final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

          final user = userCredential.user;

          if (user != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'phone': user.phoneNumber,
              'name': widget.userName ?? 'User',
              'age': widget.age ?? '',
              'gender': widget.gender ?? '',
              'bloodGroup': widget.bloodGroup ?? '',
              'allergies': widget.allergies ?? '',
              'conditions': widget.conditions ?? '',
              'medications': widget.medications ?? '',
              'surgeries': widget.surgeries ?? '',
              'emergencyContactName': widget.emergencyContactName ?? '',
              'emergencyContactPhone': widget.emergencyContactPhone ?? '',
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }

          setState(() {
            _isLoading = false;
          });

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeDashboard(
                  userName: widget.userName ?? 'User',
                  age: widget.age ?? '—',
                  gender: widget.gender ?? '—',
                  bloodGroup: widget.bloodGroup ?? '—',
                  allergies: widget.allergies ?? '',
                  conditions: widget.conditions ?? '',
                  medications: widget.medications ?? '',
                  surgeries: widget.surgeries ?? '',
                  emergencyContactName: widget.emergencyContactName ?? '',
                  emergencyContactPhone: widget.emergencyContactPhone ?? '',
                ),
              ),
                  (route) => false,
            );
          }
        },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Failed to resend OTP.'),
            backgroundColor: Colors.red,
          ),
        );
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1565C0)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Verify Your Number',
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 15, height: 1.5),
                children: [
                  const TextSpan(text: 'We sent a 6-digit OTP to\n'),
                  TextSpan(
                    text: '+91 ${widget.mobileNumber}',
                    style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // ── OTP Boxes ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 48,
                  height: 56,
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: _isBoxEmpty(index)
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFF5F8FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _isBoxEmpty(index)
                              ? Colors.red
                              : const Color(0xFF1565C0).withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _isBoxEmpty(index)
                              ? Colors.red
                              : const Color(0xFF1565C0).withValues(alpha: 0.3),
                          width: _isBoxEmpty(index) ? 1.5 : 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _isBoxEmpty(index)
                              ? Colors.red
                              : const Color(0xFF1565C0),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (_showError && value.isNotEmpty) {
                        setState(() {
                          _showError = false;
                          _errorMessage = '';
                        });
                      }
                      if (value.isNotEmpty) {
                        if (index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else {
                          _focusNodes[index].unfocus();
                          // Auto verify on 6th digit with 300ms delay
                          Future.delayed(const Duration(milliseconds: 300), () {
                            final otp =
                            _controllers.map((c) => c.text).join();
                            if (otp.length == 6) _verifyOtp();
                          });
                        }
                      } else {
                        if (index > 0) _focusNodes[index - 1].requestFocus();
                      }
                    },
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  ),
                );
              }),
            ),

            // ── Error message ──────────────────────────────
            if (_showError)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style:
                        TextStyle(color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // ── Resend OTP ─────────────────────────────────
            Center(
              child: _canResend
                  ? TextButton(
                onPressed: _resendOtp,
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: Color(0xFF1565C0),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
                  : Text(
                'Resend OTP in $_resendSeconds seconds',
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 14),
              ),
            ),

            const SizedBox(height: 40),

            // ── Verify Button ──────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.check_circle_outline, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}