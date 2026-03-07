import 'package:flutter/material.dart';
import 'home_dashboard.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
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
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _verifyOtp() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter the complete 6-digit OTP')),
      );
      return;
    }
    // TODO: Verify OTP with Firebase
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
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFF5F8FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: const Color(0xFF1565C0)
                                .withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: const Color(0xFF1565C0)
                                .withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF1565C0), width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            Center(
              child: _canResend
                  ? TextButton(
                onPressed: () {
                  _startResendTimer();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OTP resent!')),
                  );
                },
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
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