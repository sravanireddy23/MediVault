import 'package:flutter/material.dart';
import 'mobile_screen.dart';

class SignUpPage2 extends StatefulWidget {
  final String name;
  final String age;
  final String dob;
  final String gender;
  final String bloodGroup;

  const SignUpPage2({
    super.key,
    required this.name,
    required this.age,
    required this.dob,
    required this.gender,
    required this.bloodGroup,
  });

  @override
  State<SignUpPage2> createState() => _SignUpPage2State();
}

class _SignUpPage2State extends State<SignUpPage2> {
  final _formKey = GlobalKey<FormState>();
  final _allergiesController = TextEditingController();
  final _chronicController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _surgeriesController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  @override
  void dispose() {
    _allergiesController.dispose();
    _chronicController.dispose();
    _medicationsController.dispose();
    _surgeriesController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MobileScreen(userName: widget.name),
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
          'Medical Info',
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
              // ── Progress Indicator ─────────────────────────
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
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Step 2 of 2  —  Critical Medical Emergency Info',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 16),

              // ── Emergency banner ───────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.emergency_rounded,
                        color: Color(0xFFD32F2F), size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This info will be accessible during emergencies without login.',
                        style: TextStyle(
                          color: Color(0xFFD32F2F),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Known Allergies ────────────────────────────
              _buildLabel('Known Allergies'),
              const SizedBox(height: 4),
              _buildSubLabel('e.g. Penicillin, Peanuts, Dust'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _allergiesController,
                hint: 'Enter known allergies',
                icon: Icons.warning_amber_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: 22),

              // ── Chronic Conditions ─────────────────────────
              _buildLabel('Chronic Conditions'),
              const SizedBox(height: 4),
              _buildSubLabel('e.g. Diabetes, Hypertension, Asthma'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _chronicController,
                hint: 'Enter chronic conditions',
                icon: Icons.monitor_heart_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: 22),

              // ── Current Medications ────────────────────────
              _buildLabel('Current Medications'),
              const SizedBox(height: 4),
              _buildSubLabel('e.g. Metformin 500mg, Amlodipine 5mg'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _medicationsController,
                hint: 'Enter current medications',
                icon: Icons.medication_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: 22),

              // ── Past Surgeries ─────────────────────────────
              _buildLabel('Past Surgeries'),
              const SizedBox(height: 4),
              _buildSubLabel('e.g. Appendectomy 2019, Knee surgery 2021'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _surgeriesController,
                hint: 'Enter past surgeries (if any)',
                icon: Icons.local_hospital_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: 28),

              // ── Emergency Contact divider ──────────────────
              Row(
                children: [
                  const Icon(Icons.contact_phone_outlined,
                      color: Color(0xFF1565C0), size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Emergency Contact',
                    style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Divider(
                      color:
                      const Color(0xFF1565C0).withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Emergency Contact Name ─────────────────────
              _buildLabel('Contact Name'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emergencyNameController,
                hint: 'e.g. Parent, Spouse, Sibling',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter emergency contact name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              // ── Emergency Contact Phone ────────────────────
              _buildLabel('Contact Phone Number'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emergencyPhoneController,
                hint: 'Enter 10-digit mobile number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter emergency contact number';
                  }
                  if (value.trim().length != 10) {
                    return 'Enter a valid 10-digit number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // ── Submit Button ──────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
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
                        'Create Account',
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

  // ── Reusable sub label ───────────────────────────────────
  Widget _buildSubLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 12,
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
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
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