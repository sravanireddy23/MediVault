import 'package:flutter/material.dart';
import 'signup_page2.dart';

class SignUpPage1 extends StatefulWidget {
  const SignUpPage1({super.key});

  @override
  State<SignUpPage1> createState() => _SignUpPage1State();
}

class _SignUpPage1State extends State<SignUpPage1> {
  final _formKey          = GlobalKey<FormState>();
  final _nameController   = TextEditingController();
  final _ageController    = TextEditingController();
  final _emailController  = TextEditingController();
  final _passwordController   = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _selectedDate;
  String?   _selectedGender;
  String?   _selectedBloodGroup;

  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;

  bool _showDobError        = false;
  bool _showGenderError     = false;
  bool _showBloodGroupError = false;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1565C0),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1565C0),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _showDobError = false;
        final today = DateTime.now();
        int age = today.year - picked.year;
        if (today.month < picked.month ||
            (today.month == picked.month && today.day < picked.day)) {
          age--;
        }
        _ageController.text = age.toString();
      });
    }
  }

  void _goToNext() {
    setState(() {
      _showDobError        = _selectedDate == null;
      _showGenderError     = _selectedGender == null;
      _showBloodGroupError = _selectedBloodGroup == null;
    });

    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid ||
        _showDobError ||
        _showGenderError ||
        _showBloodGroupError) {return;}

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpPage2(
          name: _nameController.text.trim(),
          age: _ageController.text.trim(),
          dob: '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
          gender: _selectedGender!,
          bloodGroup: _selectedBloodGroup!,
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      ),
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
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF1565C0)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Progress ───────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Step 1 of 2  —  Personal Details',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 13),
              ),
              const SizedBox(height: 28),

              // ── Full Name ──────────────────────────────────
              _buildLabel('Full Name'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'Enter your full name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  if (!RegExp(r"^[a-zA-Z\s]+$")
                      .hasMatch(value.trim())) {
                    return 'Name must contain letters only';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              // ── Date of Birth ──────────────────────────────
              _buildLabel('Date of Birth'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F8FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _showDobError
                          ? Colors.red
                          : const Color(0xFF1565C0)
                          .withValues(alpha: 0.3),
                      width: _showDobError ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: _showDobError
                            ? Colors.red
                            : const Color(0xFF1565C0),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select date of birth',
                        style: TextStyle(
                          color: _selectedDate != null
                              ? const Color(0xFF1A1A2E)
                              : Colors.grey.shade400,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showDobError)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 6),
                  child: Text(
                    'Please select your date of birth',
                    style: TextStyle(
                        color: Colors.red.shade700, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 22),

              // ── Age (auto filled) ──────────────────────────
              _buildLabel('Age'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _ageController,
                hint: 'Auto-filled from date of birth',
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                readOnly: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select date of birth first';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              // ── Gender ─────────────────────────────────────
              _buildLabel('Gender'),
              const SizedBox(height: 8),
              Row(
                children: _genders.map((gender) {
                  final isSelected = _selectedGender == gender;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedGender = gender;
                        _showGenderError = false;
                      }),
                      child: Container(
                        margin: EdgeInsets.only(
                            right: gender != _genders.last ? 10 : 0),
                        padding:
                        const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1565C0)
                              : const Color(0xFFF5F8FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _showGenderError
                                ? Colors.red
                                : isSelected
                                ? const Color(0xFF1565C0)
                                : const Color(0xFF1565C0)
                                .withValues(alpha: 0.3),
                            width: _showGenderError ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          gender,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1565C0),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_showGenderError)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 6),
                  child: Text(
                    'Please select your gender',
                    style: TextStyle(
                        color: Colors.red.shade700, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 22),

              // ── Blood Group ────────────────────────────────
              _buildLabel('Blood Group'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _bloodGroups.map((group) {
                  final isSelected = _selectedBloodGroup == group;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedBloodGroup = group;
                      _showBloodGroupError = false;
                    }),
                    child: Container(
                      width: 68,
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1565C0)
                            : const Color(0xFFF5F8FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showBloodGroupError
                              ? Colors.red
                              : isSelected
                              ? const Color(0xFF1565C0)
                              : const Color(0xFF1565C0)
                              .withValues(alpha: 0.3),
                          width: _showBloodGroupError ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        group,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1565C0),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_showBloodGroupError)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 6),
                  child: Text(
                    'Please select your blood group',
                    style: TextStyle(
                        color: Colors.red.shade700, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 22),

              // ── Email ──────────────────────────────────────
              _buildLabel('Email Address'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: 'you@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value.trim())) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              // ── Password ───────────────────────────────────
              _buildLabel('Password'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _passwordController,
                hint: 'Min. 6 characters',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              // ── Confirm Password ───────────────────────────
              _buildLabel('Confirm Password'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _confirmPasswordController,
                hint: 'Re-enter your password',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () => setState(() =>
                  _obscureConfirmPassword =
                  !_obscureConfirmPassword),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value.trim() !=
                      _passwordController.text.trim()) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // ── Next Button ────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 15,
          fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
          color: Color(0xFF1A1A2E), fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        TextStyle(color: Colors.grey.shade400, fontSize: 15),
        prefixIcon:
        Icon(icon, color: const Color(0xFF1565C0), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F8FF),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color:
              const Color(0xFF1565C0).withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color:
              const Color(0xFF1565C0).withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFF1565C0), width: 2),
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
    );
  }
}