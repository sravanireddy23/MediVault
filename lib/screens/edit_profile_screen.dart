import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color kPrimaryBlue = Color(0xFF1565C0);
  static const Color kLightBlue   = Color(0xFF1E88E5);
  static const Color kLightBlueBg = Color(0xFFE3F2FD);
  static const Color kAppBg       = Color(0xFFF5F8FF);
  static const Color kDarkText    = Color(0xFF1A1A2E);
  static const Color kRed         = Color(0xFFD32F2F);

  static const List<String> _genders = [
    'Male', 'Female', 'Other', 'Prefer not to say'
  ];
  static const List<String> _bloodGroups = [
    'A+', 'A−', 'B+', 'B−', 'AB+', 'AB−', 'O+', 'O−', 'Unknown'
  ];

  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _allergiesCtrl;
  late TextEditingController _conditionsCtrl;
  late TextEditingController _medicationsCtrl;
  late TextEditingController _surgeriesCtrl;
  late TextEditingController _emailCtrl;

  String? _selectedGender;
  String? _selectedBloodGroup;
  DateTime? _selectedDob;

  bool _saving        = false;
  bool _emailChanged  = false;

  @override
  void initState() {
    super.initState();
    final d = widget.userData;

    _nameCtrl        = TextEditingController(text: d['name']        ?? '');
    _ageCtrl         = TextEditingController(text: d['age']?.toString() ?? '');
    _allergiesCtrl   = TextEditingController(text: d['allergies']   ?? '');
    _conditionsCtrl  = TextEditingController(text: d['conditions']  ?? '');
    _medicationsCtrl = TextEditingController(text: d['medications'] ?? '');
    _surgeriesCtrl   = TextEditingController(text: d['surgeries']   ?? '');
    _emailCtrl       = TextEditingController(
        text: FirebaseAuth.instance.currentUser?.email ?? '');

    _selectedGender = _genders.contains(d['gender']) ? d['gender'] : null;
    _selectedBloodGroup =
    _bloodGroups.contains(d['bloodGroup']) ? d['bloodGroup'] : null;

    // Parse DOB
    final dob = d['dob'];
    if (dob is String && dob.isNotEmpty) {
      _selectedDob = DateTime.tryParse(dob);
    }

    _emailCtrl.addListener(() {
      final current = FirebaseAuth.instance.currentUser?.email ?? '';
      setState(() => _emailChanged = _emailCtrl.text.trim() != current);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _allergiesCtrl.dispose();
    _conditionsCtrl.dispose();
    _medicationsCtrl.dispose();
    _surgeriesCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // ── Date picker ────────────────────────────────────────────────────────────
  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kPrimaryBlue,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: kDarkText,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        // Auto-calculate age
        final age = DateTime.now().year - picked.year;
        _ageCtrl.text = age.toString();
      });
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _showSnack('Name cannot be empty', isError: true);
      return;
    }

    // If email changed, ask for password re-auth
    if (_emailChanged) {
      final proceed = await _showReAuthDialog();
      if (!proceed) return;
      return; // _showReAuthDialog handles save after re-auth
    }

    await _saveToFirestore();
  }

  Future<void> _saveToFirestore() async {
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not logged in');

      final dobIso = _selectedDob == null
          ? (widget.userData['dob'] ?? '')
          : '${_selectedDob!.year}-'
          '${_selectedDob!.month.toString().padLeft(2, '0')}-'
          '${_selectedDob!.day.toString().padLeft(2, '0')}';

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name':        _nameCtrl.text.trim(),
        'age':         _ageCtrl.text.trim(),
        'gender':      _selectedGender ?? widget.userData['gender'] ?? '',
        'bloodGroup':  _selectedBloodGroup ?? widget.userData['bloodGroup'] ?? '',
        'dob':         dobIso,
        'allergies':   _allergiesCtrl.text.trim(),
        'conditions':  _conditionsCtrl.text.trim(),
        'medications': _medicationsCtrl.text.trim(),
        'surgeries':   _surgeriesCtrl.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context, true);
        _showSnack('Profile updated successfully', isError: false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _showSnack('Failed to save: $e', isError: true);
      }
    }
  }

  // ── Re-auth dialog for email change ───────────────────────────────────────
  Future<bool> _showReAuthDialog() async {
    final passwordCtrl = TextEditingController();
    bool result = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: kPrimaryBlue, size: 20),
            SizedBox(width: 8),
            Text('Confirm Password',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To change your email, please enter your current password.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Current password',
                prefixIcon: const Icon(Icons.lock_outline, size: 18),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              final password = passwordCtrl.text;
              if (password.isEmpty) return;
              try {
                final user = FirebaseAuth.instance.currentUser!;
                final cred = EmailAuthProvider.credential(
                    email: user.email!, password: password);
                await user.reauthenticateWithCredential(cred);
                await user.verifyBeforeUpdateEmail(
                    _emailCtrl.text.trim());
                result = true;
                if (mounted) Navigator.pop(context);
                _showSnack(
                    'Verification email sent to ${_emailCtrl.text.trim()}. '
                        'Please verify to complete email change.',
                    isError: false);
                // Save other fields even if email pending verification
                await _saveToFirestore();
              } catch (e) {
                if (mounted) {
                  _showSnack('Incorrect password. Try again.', isError: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result;
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? kRed : const Color(0xFF388E3C),
      duration: Duration(seconds: isError ? 3 : 4),
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Basic Info ───────────────────────────────────────────
                  _sectionHeader(Icons.person_rounded, 'Basic Information'),
                  const SizedBox(height: 12),
                  _card(Column(
                    children: [
                      _fieldLabel('FULL NAME'),
                      const SizedBox(height: 6),
                      _textField(
                          controller: _nameCtrl,
                          hint: 'e.g. Arjun Sharma',
                          icon: Icons.person_outline_rounded),
                      const SizedBox(height: 16),

                      _fieldLabel('DATE OF BIRTH'),
                      const SizedBox(height: 6),
                      _datePicker(),
                      const SizedBox(height: 16),

                      _fieldLabel('AGE'),
                      const SizedBox(height: 6),
                      _textField(
                          controller: _ageCtrl,
                          hint: 'e.g. 28',
                          icon: Icons.cake_outlined,
                          inputType: TextInputType.number),
                      const SizedBox(height: 16),

                      _fieldLabel('GENDER'),
                      const SizedBox(height: 6),
                      _dropdown(
                          value: _selectedGender,
                          items: _genders,
                          hint: 'Select gender',
                          icon: Icons.wc_outlined,
                          onChanged: (v) =>
                              setState(() => _selectedGender = v)),
                      const SizedBox(height: 16),

                      _fieldLabel('BLOOD GROUP'),
                      const SizedBox(height: 6),
                      _dropdown(
                          value: _selectedBloodGroup,
                          items: _bloodGroups,
                          hint: 'Select blood group',
                          icon: Icons.bloodtype_outlined,
                          onChanged: (v) =>
                              setState(() => _selectedBloodGroup = v)),
                    ],
                  )),
                  const SizedBox(height: 24),

                  // ── Medical Info ─────────────────────────────────────────
                  _sectionHeader(
                      Icons.medical_information_rounded, 'Medical Information'),
                  const SizedBox(height: 4),
                  Text(
                    'Separate multiple entries with commas',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 12),
                  _card(Column(
                    children: [
                      _fieldLabel('ALLERGIES'),
                      const SizedBox(height: 6),
                      _textField(
                          controller: _allergiesCtrl,
                          hint: 'e.g. Penicillin, Pollen, Dust',
                          icon: Icons.warning_amber_outlined,
                          maxLines: 2),
                      const SizedBox(height: 16),

                      _fieldLabel('MEDICAL CONDITIONS'),
                      const SizedBox(height: 6),
                      _textField(
                          controller: _conditionsCtrl,
                          hint: 'e.g. Hypertension, Diabetes Type 2',
                          icon: Icons.monitor_heart_outlined,
                          maxLines: 2),
                      const SizedBox(height: 16),

                      _fieldLabel('CURRENT MEDICATIONS'),
                      const SizedBox(height: 6),
                      _textField(
                          controller: _medicationsCtrl,
                          hint: 'e.g. Metformin 500mg, Aspirin 75mg',
                          icon: Icons.medication_outlined,
                          maxLines: 2),
                      const SizedBox(height: 16),

                      _fieldLabel('PAST SURGERIES'),
                      const SizedBox(height: 6),
                      _textField(
                          controller: _surgeriesCtrl,
                          hint: 'e.g. Appendectomy 2019, ACL repair 2021',
                          icon: Icons.local_hospital_outlined,
                          maxLines: 2),
                    ],
                  )),
                  const SizedBox(height: 24),

                  // ── Account ──────────────────────────────────────────────
                  _sectionHeader(Icons.manage_accounts_rounded, 'Account'),
                  const SizedBox(height: 12),
                  _card(Column(
                    children: [
                      _fieldLabel('EMAIL ADDRESS'),
                      const SizedBox(height: 6),
                      _textField(
                          controller: _emailCtrl,
                          hint: 'e.g. arjun@email.com',
                          icon: Icons.email_outlined,
                          inputType: TextInputType.emailAddress),
                      if (_emailChanged) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFFFB300)
                                    .withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: Color(0xFFFF8F00), size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You\'ll need to enter your password to change email. A verification link will be sent.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF5D4037)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  )),
                  const SizedBox(height: 32),

                  // ── Save Button ──────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding:
                            const EdgeInsets.symmetric(vertical: 15),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryBlue,
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: _saving
                              ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                    Colors.white)),
                          )
                              : const Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Save Profile',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                      FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryBlue, kLightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Edit Profile',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Text('Update your personal & medical info',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_rounded,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget helpers ─────────────────────────────────────────────────────────
  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: kLightBlueBg,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: kPrimaryBlue, size: 16),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: kDarkText)),
      ],
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _fieldLabel(String label) {
    return Text(label,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey[500],
            letterSpacing: 1.0));
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kAppBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: kDarkText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: maxLines == 1
              ? Icon(icon,
              color: kPrimaryBlue.withValues(alpha: 0.6), size: 18)
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              horizontal: maxLines > 1 ? 14 : 0, vertical: 12),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kAppBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryBlue.withValues(alpha: 0.6), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(hint,
                    style: TextStyle(
                        color: Colors.grey[400], fontSize: 13)),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: kPrimaryBlue),
                style: const TextStyle(fontSize: 14, color: kDarkText),
                items: items
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePicker() {
    final formatted = _selectedDob == null
        ? 'Select date of birth'
        : '${_monthName(_selectedDob!.month)} ${_selectedDob!.day}, ${_selectedDob!.year}';

    return GestureDetector(
      onTap: _pickDob,
      child: Container(
        decoration: BoxDecoration(
          color: kAppBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                color: kPrimaryBlue.withValues(alpha: 0.6), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(formatted,
                  style: TextStyle(
                      fontSize: 14,
                      color: _selectedDob == null
                          ? Colors.grey[400]
                          : kDarkText)),
            ),
            Icon(Icons.edit_calendar_outlined,
                color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[m];
  }
}