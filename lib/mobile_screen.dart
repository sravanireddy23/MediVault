import 'package:flutter/material.dart';
import 'otp_screen.dart';

class MobileScreen extends StatefulWidget {
  final String? userName;
  final String? age;
  final String? bloodGroup;
  final String? allergies;
  final String? conditions;
  final String? medications;
  final String? surgeries;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  const MobileScreen({
    super.key,
    this.userName,
    this.age,
    this.bloodGroup,
    this.allergies,
    this.conditions,
    this.medications,
    this.surgeries,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  @override
  State<MobileScreen> createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(
            mobileNumber: _mobileController.text.trim(),
            userName: widget.userName,
            age: widget.age,
            bloodGroup: widget.bloodGroup,
            allergies: widget.allergies,
            conditions: widget.conditions,
            medications: widget.medications,
            surgeries: widget.surgeries,
            emergencyContactName: widget.emergencyContactName,
            emergencyContactPhone: widget.emergencyContactPhone,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isNewUser = widget.userName != null;

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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Greeting ───────────────────────────────────
              Text(
                isNewUser
                    ? 'Hi, ${widget.userName}!'
                    : 'Hi, Welcome Back!',
                style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isNewUser
                    ? 'Your account is ready.\nEnter your mobile number to continue.'
                    : 'Please sign in to continue.',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // ── Mobile illustration ────────────────────────
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.phone_android_rounded,
                    color: Color(0xFF1565C0),
                    size: 50,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── Mobile Number ──────────────────────────────
              const Text(
                'Mobile Number',
                style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your mobile number';
                  }
                  if (value.trim().length != 10) {
                    return 'Enter a valid 10-digit mobile number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Enter 10-digit mobile number',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 15,
                    letterSpacing: 0,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    child: const Text(
                      '+91',
                      style: TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
                  filled: true,
                  fillColor: const Color(0xFFF5F8FF),
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Text(
                'We will send a 6-digit OTP to verify your number.',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 40),

              // ── Send OTP Button ────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sendOtp,
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
                        'Send OTP',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}