import 'package:flutter/material.dart';
import 'signup_page2.dart';

class SignUpPage1 extends StatefulWidget {
  const SignUpPage1({super.key});

  @override
  State<SignUpPage1> createState() => _SignUpPage1State();
}

class _SignUpPage1State extends State<SignUpPage1> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedBloodGroup;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
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
        // Auto calculate age
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
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your gender')),
        );
        return;
      }
      if (_selectedBloodGroup == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your blood group')),
        );
        return;
      }
      // Navigate to Sign Up Page 2
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpPage2(
            name: _nameController.text.trim(),
            age: _ageController.text.trim(),
            dob: _selectedDate != null
                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                : '',
            gender: _selectedGender!,
            bloodGroup: _selectedBloodGroup!,
          ),
        ),
      );
    }
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
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Progress indicator ─────────────────────────
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
                        color: const Color(0xFF1565C0).withValues(alpha: 0.2),
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
                  color: Colors.grey.shade500,
                  fontSize: 13,
                ),
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
                      color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: Color(0xFF1565C0), size: 20),
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
                      onTap: () => setState(() => _selectedGender = gender),
                      child: Container(
                        margin: EdgeInsets.only(
                          right: gender != _genders.last ? 10 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1565C0)
                              : const Color(0xFFF5F8FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1565C0)
                                : const Color(0xFF1565C0)
                                .withValues(alpha: 0.3),
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
                    onTap: () =>
                        setState(() => _selectedBloodGroup = group),
                    child: Container(
                      width: 68,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1565C0)
                            : const Color(0xFFF5F8FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1565C0)
                              : const Color(0xFF1565C0)
                              .withValues(alpha: 0.3),
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

              const SizedBox(height: 40),

              // ── Next Button ────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToNext,
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
                        'Next',
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

  // ── Reusable label ───────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ── Reusable text field ──────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      style: const TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        prefixIcon: Icon(icon, color: const Color(0xFF1565C0), size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F8FF),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}