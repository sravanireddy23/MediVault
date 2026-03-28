import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditEmergencyScreen extends StatefulWidget {
  final String initialName;
  final String initialPhone;

  const EditEmergencyScreen({
    super.key,
    required this.initialName,
    required this.initialPhone,
  });

  @override
  State<EditEmergencyScreen> createState() => _EditEmergencyScreenState();
}

class _EditEmergencyScreenState extends State<EditEmergencyScreen> {
  static const Color kPrimaryBlue = Color(0xFF1565C0);
  static const Color kAppBg       = Color(0xFFF5F8FF);
  static const Color kDarkText    = Color(0xFF1A1A2E);
  static const Color kRed         = Color(0xFFE53935);

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.initialName);
    _phoneCtrl = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name  = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      _showSnack('Contact name cannot be empty', isError: true);
      return;
    }
    if (phone.isEmpty) {
      _showSnack('Phone number cannot be empty', isError: true);
      return;
    }
    if (phone.length < 10) {
      _showSnack('Enter a valid phone number', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not logged in');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'emergencyContactName':  name,
        'emergencyContactPhone': phone,
      });

      if (mounted) {
        Navigator.pop(context, true); // true = saved
        _showSnack('Emergency contact updated', isError: false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _showSnack('Failed to save: $e', isError: true);
      }
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? kRed : const Color(0xFF388E3C),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kRed.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kRed.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.emergency_rounded,
                            color: kRed, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This contact will be shown on your Emergency Info screen and can be called in case of emergency.',
                            style: TextStyle(
                                fontSize: 13,
                                color: kRed.withValues(alpha: 0.85),
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Contact Name
                  _fieldLabel('CONTACT NAME'),
                  const SizedBox(height: 8),
                  _textField(
                    controller: _nameCtrl,
                    hint: 'e.g. Ramesh Kumar',
                    icon: Icons.person_outline_rounded,
                    inputType: TextInputType.name,
                  ),
                  const SizedBox(height: 20),

                  // Phone Number
                  _fieldLabel('PHONE NUMBER'),
                  const SizedBox(height: 8),
                  _textField(
                    controller: _phoneCtrl,
                    hint: 'e.g. +91 98765 43210',
                    icon: Icons.phone_outlined,
                    inputType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[\d\+\-\s]')),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Save Emergency Contact',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryBlue, kRed],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
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
                    Text('Edit Emergency Contact',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Text('Shown on Emergency Info screen',
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
                child: const Icon(Icons.emergency_rounded,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 15, color: kDarkText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon,
              color: kPrimaryBlue.withValues(alpha: 0.6), size: 20),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}