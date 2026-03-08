import 'package:flutter/material.dart';

class UploadRecordScreen extends StatefulWidget {
  const UploadRecordScreen({super.key});

  @override
  State<UploadRecordScreen> createState() => _UploadRecordScreenState();
}

class _UploadRecordScreenState extends State<UploadRecordScreen>
    with SingleTickerProviderStateMixin {

  // ── Colors ───────────────────────────────────────────────────────────────────
  static const _blue      = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF1E88E5);
  static const _lightBlue = Color(0xFFE3F2FD);
  static const _lightBg   = Color(0xFFF5F8FF);
  static const _darkText  = Color(0xFF1A1A2E);

  // ── Form state ───────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _titleController    = TextEditingController();
  final _doctorController   = TextEditingController();
  final _hospitalController = TextEditingController();
  final _notesController    = TextEditingController();

  String? _selectedDept;
  String? _selectedFileType;
  DateTime? _selectedDate;
  String?  _uploadedFileName; // simulates a picked file
  bool _isUploading = false;

  late AnimationController _checkController;
  late Animation<double>   _checkAnimation;

  // ── Departments ──────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _departments = [
    {'name': 'Cardiology',       'icon': Icons.favorite_rounded,          'color': const Color(0xFFE53935), 'light': const Color(0xFFFFEBEE)},
    {'name': 'Pathology',        'icon': Icons.science_rounded,           'color': const Color(0xFF8E24AA), 'light': const Color(0xFFF3E5F5)},
    {'name': 'Radiology',        'icon': Icons.image_search_rounded,      'color': const Color(0xFF1565C0), 'light': const Color(0xFFE3F2FD)},
    {'name': 'Neurology',        'icon': Icons.psychology_rounded,        'color': const Color(0xFF00897B), 'light': const Color(0xFFE0F2F1)},
    {'name': 'Orthopedics',      'icon': Icons.accessibility_new_rounded, 'color': const Color(0xFFEF6C00), 'light': const Color(0xFFFFF3E0)},
    {'name': 'Endocrinology',    'icon': Icons.water_drop_rounded,        'color': const Color(0xFF00838F), 'light': const Color(0xFFE0F7FA)},
    {'name': 'Gastroenterology', 'icon': Icons.medical_services_rounded,  'color': const Color(0xFF2E7D32), 'light': const Color(0xFFE8F5E9)},
    {'name': 'Pulmonology',      'icon': Icons.air_rounded,               'color': const Color(0xFF1976D2), 'light': const Color(0xFFE8F4FD)},
    {'name': 'Dermatology',      'icon': Icons.face_rounded,              'color': const Color(0xFFC0392B), 'light': const Color(0xFFFDECEC)},
    {'name': 'Ophthalmology',    'icon': Icons.visibility_rounded,        'color': const Color(0xFF6A1B9A), 'light': const Color(0xFFF3E5F5)},
    {'name': 'ENT',              'icon': Icons.hearing_rounded,           'color': const Color(0xFF558B2F), 'light': const Color(0xFFF1F8E9)},
    {'name': 'General',          'icon': Icons.local_hospital_rounded,    'color': const Color(0xFF546E7A), 'light': const Color(0xFFECEFF1)},
  ];

  // ── File types ───────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _fileTypes = [
    {'type': 'PDF',  'icon': Icons.picture_as_pdf_rounded,   'color': const Color(0xFFE53935), 'label': 'PDF Report'},
    {'type': 'LAB',  'icon': Icons.biotech_rounded,           'color': const Color(0xFF8E24AA), 'label': 'Lab Result'},
    {'type': 'SCAN', 'icon': Icons.document_scanner_rounded,  'color': const Color(0xFF1565C0), 'label': 'Scan / X-Ray'},
    {'type': 'IMG',  'icon': Icons.image_rounded,             'color': const Color(0xFF2E7D32), 'label': 'Image'},
  ];

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _doctorController.dispose();
    _hospitalController.dispose();
    _notesController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Map<String, dynamic>? get _selectedDeptInfo =>
      _departments.firstWhere(
            (d) => d['name'] == _selectedDept,
        orElse: () => {},
      ).isEmpty
          ? null
          : _departments.firstWhere((d) => d['name'] == _selectedDept);

  String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _darkText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ── Simulate file pick ───────────────────────────────────────────────────────
  void _pickFile() {
    // TODO: integrate file_picker package
    setState(() {
      _uploadedFileName = 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('File selected successfully'),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ── Submit ───────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDept == null) {
      _showError('Please select a department');
      return;
    }
    if (_selectedFileType == null) {
      _showError('Please select a record type');
      return;
    }
    if (_selectedDate == null) {
      _showError('Please select the record date');
      return;
    }

    setState(() => _isUploading = true);

    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isUploading = false);
    _checkController.forward();

    // Show success and pop after a moment
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    _showSuccessSheet();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(msg),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 32),

            // Success animation circle
            ScaleTransition(
              scale: _checkAnimation,
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF2E7D32), size: 52),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Record Uploaded!',
                style: TextStyle(
                    color: _darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              '${_titleController.text} has been\nsaved to your Medical Records.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 28),

            // Summary pill
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _lightBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _selectedDeptInfo?['light'] ?? _lightBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _selectedDeptInfo?['icon'] ?? Icons.folder_rounded,
                      color: _selectedDeptInfo?['color'] ?? _blue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_titleController.text,
                            style: const TextStyle(
                                color: _darkText,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Text(
                          '$_selectedDept  ·  ${_selectedDate != null ? _formatDate(_selectedDate!) : ''}',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close sheet
                  Navigator.pop(context); // back to dashboard
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Back to Dashboard',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
              child: const Text('Upload Another Record',
                  style: TextStyle(color: _blue, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _doctorController.clear();
    _hospitalController.clear();
    _notesController.clear();
    setState(() {
      _selectedDept     = null;
      _selectedFileType = null;
      _selectedDate     = null;
      _uploadedFileName = null;
    });
    _checkController.reset();
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Upload source picker ─────────────────────────
                    _buildSectionLabel('Choose Upload Source', Icons.upload_rounded),
                    const SizedBox(height: 12),
                    _buildUploadSourceRow(),
                    const SizedBox(height: 24),

                    // ── File type picker ─────────────────────────────
                    _buildSectionLabel('Record Type', Icons.category_rounded),
                    const SizedBox(height: 12),
                    _buildFileTypeGrid(),
                    const SizedBox(height: 24),

                    // ── Record title ─────────────────────────────────
                    _buildSectionLabel('Record Title', Icons.title_rounded),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'e.g. Blood Test Report, Chest X-Ray',
                      icon: Icons.description_outlined,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter a title'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // ── Department picker ────────────────────────────
                    _buildSectionLabel('Department', Icons.local_hospital_rounded),
                    const SizedBox(height: 12),
                    _buildDeptGrid(),
                    const SizedBox(height: 20),

                    // ── Doctor name ──────────────────────────────────
                    _buildSectionLabel('Doctor Name', Icons.person_rounded),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _doctorController,
                      hint: 'e.g. Dr. Raghav Menon',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 20),

                    // ── Hospital ─────────────────────────────────────
                    _buildSectionLabel('Hospital / Clinic', Icons.business_rounded),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _hospitalController,
                      hint: 'e.g. Apollo Hospital, Hyderabad',
                      icon: Icons.business_outlined,
                    ),
                    const SizedBox(height: 20),

                    // ── Date picker ──────────────────────────────────
                    _buildSectionLabel('Record Date', Icons.calendar_today_rounded),
                    const SizedBox(height: 10),
                    _buildDatePicker(),
                    const SizedBox(height: 20),

                    // ── Notes ────────────────────────────────────────
                    _buildSectionLabel('Notes (Optional)', Icons.notes_rounded),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _notesController,
                      hint: 'Any additional notes about this record...',
                      icon: Icons.notes_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 36),

                    // ── Upload button ────────────────────────────────
                    _buildUploadButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: _blue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_blue, _blueLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Upload Record',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3)),
                        const SizedBox(height: 4),
                        Text('Add a new document to your health vault',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_upload_rounded,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section label ────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _blue, size: 16),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                color: _darkText,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── Upload source row ────────────────────────────────────────────────────────
  Widget _buildUploadSourceRow() {
    final sources = [
      {'label': 'Files',   'icon': Icons.folder_open_rounded,     'desc': 'PDF, DOC'},
      {'label': 'Camera',  'icon': Icons.camera_alt_rounded,       'desc': 'Take photo'},
      {'label': 'Gallery', 'icon': Icons.photo_library_rounded,    'desc': 'From gallery'},
      {'label': 'Scan',    'icon': Icons.document_scanner_rounded, 'desc': 'Scan doc'},
    ];

    return Row(
      children: sources.map((s) {
        return Expanded(
          child: GestureDetector(
            onTap: _pickFile,
            child: Container(
              margin: EdgeInsets.only(
                  right: s != sources.last ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _uploadedFileName != null && s['label'] == 'Files'
                      ? _blue
                      : Colors.grey.withValues(alpha: 0.2),
                  width: _uploadedFileName != null && s['label'] == 'Files'
                      ? 2
                      : 1,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _lightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(s['icon'] as IconData,
                        color: _blue, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(s['label'] as String,
                      style: const TextStyle(
                          color: _darkText,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(s['desc'] as String,
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 10)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── File type grid (2 × 2) ───────────────────────────────────────────────────
  Widget _buildFileTypeGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 3.0,
      children: _fileTypes.map((ft) {
        final isSelected = _selectedFileType == ft['type'];
        final color = ft['color'] as Color;
        return GestureDetector(
          onTap: () => setState(() => _selectedFileType = ft['type'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.grey.withValues(alpha: 0.25),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3))]
                  : [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Icon(ft['icon'] as IconData,
                    color: isSelected ? Colors.white : color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(ft['label'] as String,
                      style: TextStyle(
                          color: isSelected ? Colors.white : _darkText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 16),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Department grid ──────────────────────────────────────────────────────────
  Widget _buildDeptGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _departments.map((dept) {
        final isSelected = _selectedDept == dept['name'];
        final color = dept['color'] as Color;
        final light = dept['light'] as Color;
        return GestureDetector(
          onTap: () => setState(() => _selectedDept = dept['name'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? color : light,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3))]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(dept['icon'] as IconData,
                    color: isSelected ? Colors.white : color, size: 15),
                const SizedBox(width: 6),
                Text(dept['name'] as String,
                    style: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Date picker tile ─────────────────────────────────────────────────────────
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedDate != null
                ? _blue.withValues(alpha: 0.5)
                : _blue.withValues(alpha: 0.3),
            width: _selectedDate != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                color: _blue, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? _formatDate(_selectedDate!)
                    : 'Select record date',
                style: TextStyle(
                    color: _selectedDate != null
                        ? _darkText
                        : Colors.grey.shade400,
                    fontSize: 15,
                    fontWeight: _selectedDate != null
                        ? FontWeight.w600
                        : FontWeight.normal),
              ),
            ),
            Icon(
              _selectedDate != null
                  ? Icons.check_circle_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: _selectedDate != null ? _blue : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── Text field ───────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: _darkText, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: _blue, size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F8FF),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: _blue.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: _blue.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFE53935)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFFE53935), width: 2),
        ),
      ),
    );
  }

  // ── Upload button ────────────────────────────────────────────────────────────
  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _blue.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: _isUploading
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
            SizedBox(width: 14),
            Text('Uploading...',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_rounded, size: 22),
            SizedBox(width: 10),
            Text('Upload Record',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}