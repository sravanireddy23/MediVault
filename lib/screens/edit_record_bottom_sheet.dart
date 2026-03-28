import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditRecordBottomSheet extends StatefulWidget {
  final Map<String, dynamic> record;
  final VoidCallback onSaved;

  const EditRecordBottomSheet({
    super.key,
    required this.record,
    required this.onSaved,
  });

  // ── Static launcher helper ─────────────────────────────────────────────────
  static Future<void> show(
      BuildContext context, {
        required Map<String, dynamic> record,
        required VoidCallback onSaved,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditRecordBottomSheet(record: record, onSaved: onSaved),
    );
  }

  @override
  State<EditRecordBottomSheet> createState() => _EditRecordBottomSheetState();
}

class _EditRecordBottomSheetState extends State<EditRecordBottomSheet> {
  static const Color kPrimaryBlue = Color(0xFF1565C0);
  static const Color kLightBlueBg = Color(0xFFE3F2FD);
  static const Color kDarkText    = Color(0xFF1A1A2E);

  static const List<String> _departments = [
    'Cardiology', 'Pathology', 'Radiology', 'Orthopedics', 'Neurology',
    'Dermatology', 'Gastroenterology', 'ENT', 'Ophthalmology', 'Gynecology',
    'Pediatrics', 'Urology', 'Oncology', 'Endocrinology', 'Pulmonology',
    'Nephrology', 'Psychiatry', 'General', 'Dentistry', 'Other',
  ];

  late TextEditingController _titleCtrl;
  late TextEditingController _doctorCtrl;
  late TextEditingController _hospitalCtrl;
  late TextEditingController _notesCtrl;

  String?  _selectedDept;
  DateTime? _selectedDate;
  bool     _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.record;

    _titleCtrl    = TextEditingController(text: r['title']    ?? '');
    _doctorCtrl   = TextEditingController(text: r['doctor']   ?? '');
    _hospitalCtrl = TextEditingController(text: r['hospital'] ?? '');
    _notesCtrl    = TextEditingController(text: r['notes']    ?? '');

    _selectedDept = _departments.contains(r['department'])
        ? r['department']
        : 'Other';

    // Parse date
    final raw = r['date'] ?? r['uploadedAt'];
    if (raw is Timestamp) {
      _selectedDate = raw.toDate();
    } else if (raw is String) {
      _selectedDate = DateTime.tryParse(raw);
    }
    _selectedDate ??= DateTime.now();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _doctorCtrl.dispose();
    _hospitalCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Date picker ────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ── Save to Firestore ──────────────────────────────────────────────────────
  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not logged in');

      final recordId = widget.record['id'];
      if (recordId == null) throw Exception('Record ID missing');

      final updates = <String, dynamic>{
        'title':      title,
        'department': _selectedDept ?? 'Other',
        'notes':      _notesCtrl.text.trim(),
      };

      // Only update doctor/hospital if they were originally set
      // (i.e. it's a doctor-visit record)
      final uploadType = widget.record['uploadType'] ?? 'direct_upload';
      if (uploadType == 'new_visit' || uploadType == 'existing_visit') {
        updates['doctor']   = _doctorCtrl.text.trim();
        updates['hospital'] = _hospitalCtrl.text.trim();
      }

      // Update date
      if (_selectedDate != null) {
        final iso = '${_selectedDate!.year}-'
            '${_selectedDate!.month.toString().padLeft(2, '0')}-'
            '${_selectedDate!.day.toString().padLeft(2, '0')}';
        updates['date'] = iso;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('records')
          .doc(recordId)
          .update(updates);

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record updated successfully'),
            backgroundColor: Color(0xFF388E3C),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final uploadType = widget.record['uploadType'] ?? 'direct_upload';
    final isDoctorVisit =
        uploadType == 'new_visit' || uploadType == 'existing_visit';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle ───────────────────────────────────────────────────────
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Title row ─────────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: kLightBlueBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: kPrimaryBlue, size: 18),
                ),
                const SizedBox(width: 10),
                const Text('Edit Record',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kDarkText)),
              ],
            ),
            const SizedBox(height: 20),

            // ── Title ─────────────────────────────────────────────────────────
            _fieldLabel('TITLE'),
            const SizedBox(height: 6),
            _textField(
              controller: _titleCtrl,
              hint: 'e.g. ECG Report, Blood Test - CBC',
              icon: Icons.description_outlined,
            ),
            const SizedBox(height: 16),

            // ── Department ────────────────────────────────────────────────────
            _fieldLabel('DEPARTMENT'),
            const SizedBox(height: 6),
            _departmentDropdown(),
            const SizedBox(height: 16),

            // ── Doctor & Hospital (only for doctor visits) ────────────────────
            if (isDoctorVisit) ...[
              _fieldLabel('DOCTOR'),
              const SizedBox(height: 6),
              _textField(
                controller: _doctorCtrl,
                hint: 'e.g. Dr. Raghav Menon',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),

              _fieldLabel('HOSPITAL'),
              const SizedBox(height: 6),
              _textField(
                controller: _hospitalCtrl,
                hint: 'e.g. Apollo Hospital',
                icon: Icons.local_hospital_outlined,
              ),
              const SizedBox(height: 16),
            ],

            // ── Date ──────────────────────────────────────────────────────────
            _fieldLabel('DATE OF RECORD'),
            const SizedBox(height: 6),
            _datePicker(),
            const SizedBox(height: 16),

            // ── Notes ─────────────────────────────────────────────────────────
            _fieldLabel('NOTES'),
            const SizedBox(height: 6),
            _textField(
              controller: _notesCtrl,
              hint: 'e.g. Fasting test, follow-up needed...',
              icon: Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // ── Save button ───────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white)),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Save Changes',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Field helpers ──────────────────────────────────────────────────────────
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
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: kDarkText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: maxLines == 1
              ? Icon(icon, color: kPrimaryBlue.withValues(alpha: 0.6), size: 18)
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: maxLines > 1 ? 14 : 0,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _departmentDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDept,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: kPrimaryBlue),
          style: const TextStyle(fontSize: 14, color: kDarkText),
          items: _departments.map((dept) {
            return DropdownMenuItem(value: dept, child: Text(dept));
          }).toList(),
          onChanged: (val) => setState(() => _selectedDept = val),
        ),
      ),
    );
  }

  Widget _datePicker() {
    final formatted = _selectedDate == null
        ? 'Select date'
        : '${_monthName(_selectedDate!.month)} ${_selectedDate!.day}, ${_selectedDate!.year}';

    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                color: kPrimaryBlue.withValues(alpha: 0.7), size: 18),
            const SizedBox(width: 10),
            Text(formatted,
                style: TextStyle(
                    fontSize: 14,
                    color: _selectedDate == null
                        ? Colors.grey[400]
                        : kDarkText)),
            const Spacer(),
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