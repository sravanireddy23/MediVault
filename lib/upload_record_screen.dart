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

  // ── Upload type: 0=New Visit, 1=Add to Existing, 2=Direct Upload ─────────────
  int _uploadType = 0;

  // ── Form keys ────────────────────────────────────────────────────────────────
  final _newVisitFormKey     = GlobalKey<FormState>();
  final _existingFormKey     = GlobalKey<FormState>();
  final _directFormKey       = GlobalKey<FormState>();

  // ── Controllers ──────────────────────────────────────────────────────────────
  final _titleController    = TextEditingController();
  final _doctorController   = TextEditingController();
  final _hospitalController = TextEditingController();
  final _reportNameController = TextEditingController();

  // ── State ────────────────────────────────────────────────────────────────────
  DateTime? _selectedDate;
  String?   _uploadedFileName;
  bool      _isUploading = false;
  String?   _selectedEpisodeId; // for existing episode selection

  late AnimationController _checkController;
  late Animation<double>   _checkAnimation;

  // ── Sample existing episodes (will come from Firestore later) ────────────────
  final List<Map<String, dynamic>> _existingEpisodes = [
    {
      'id': 'e1',
      'doctor': 'Dr. Raghav Menon',
      'hospital': 'Apollo Hospital',
      'department': 'Cardiology',
      'date': 'Mar 2, 2025',
      'color': Color(0xFFE53935),
      'lightColor': Color(0xFFFFEBEE),
      'icon': Icons.favorite_rounded,
    },
    {
      'id': 'e2',
      'doctor': 'Dr. Priya Sharma',
      'hospital': 'Medanta',
      'department': 'Pathology',
      'date': 'Jan 5, 2025',
      'color': Color(0xFF8E24AA),
      'lightColor': Color(0xFFF3E5F5),
      'icon': Icons.science_rounded,
    },
    {
      'id': 'e3',
      'doctor': 'Dr. Suresh Nair',
      'hospital': 'KIMS',
      'department': 'Radiology',
      'date': 'Sep 3, 2024',
      'color': Color(0xFF1565C0),
      'lightColor': Color(0xFFE3F2FD),
      'icon': Icons.image_search_rounded,
    },
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
    _reportNameController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  // ── Format date ──────────────────────────────────────────────────────────────
  String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  // ── Date picker ──────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
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

  // ── File picker (simulated — will use file_picker package later) ─────────────
  void _pickFile() {
    // TODO: integrate file_picker package
    setState(() {
      _uploadedFileName =
      'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('File selected successfully'),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ── Validate and submit ──────────────────────────────────────────────────────
  Future<void> _submit() async {
    // Validate based on upload type
    bool isValid = false;

    if (_uploadType == 0) {
      // New Visit
      isValid = _newVisitFormKey.currentState?.validate() ?? false;
      if (isValid && _selectedDate == null) {
        _showError('Please select the visit date');
        return;
      }
      if (isValid && _uploadedFileName == null) {
        _showError('Please upload a file');
        return;
      }
    } else if (_uploadType == 1) {
      // Add to Existing
      if (_selectedEpisodeId == null) {
        _showError('Please select an existing episode');
        return;
      }
      isValid = _existingFormKey.currentState?.validate() ?? false;
      if (isValid && _uploadedFileName == null) {
        _showError('Please upload a file');
        return;
      }
    } else {
      // Direct Upload
      isValid = _directFormKey.currentState?.validate() ?? false;
      if (isValid && _selectedDate == null) {
        _showError('Please select the report date');
        return;
      }
      if (isValid && _uploadedFileName == null) {
        _showError('Please upload a file');
        return;
      }
    }

    if (!isValid) return;

    setState(() => _isUploading = true);
    // TODO: Save to Firestore + AWS S3
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isUploading = false);
    _checkController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ── Success Sheet ─────────────────────────────────────────────────────────────
  void _showSuccessSheet() {
    final title = _uploadType == 0
        ? _titleController.text
        : _uploadType == 1
        ? _titleController.text
        : _reportNameController.text;

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
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 32),
            // Success icon
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
              '$title has been saved to your Medical Records.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 15,
                  height: 1.5),
            ),
            const SizedBox(height: 16),
            // AI note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFA5D6A7), width: 0.8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.psychology_rounded,
                      color: Color(0xFF2E7D32), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI will auto-detect the department from your report.',
                      style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Back to dashboard
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
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

  // ── Reset form ───────────────────────────────────────────────────────────────
  void _resetForm() {
    _newVisitFormKey.currentState?.reset();
    _existingFormKey.currentState?.reset();
    _directFormKey.currentState?.reset();
    _titleController.clear();
    _doctorController.clear();
    _hospitalController.clear();
    _reportNameController.clear();
    setState(() {
      _uploadType       = 0;
      _selectedDate     = null;
      _uploadedFileName = null;
      _selectedEpisodeId = null;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Upload type selector ─────────────────────────
                  _buildSectionLabel(
                      'What type of upload?', Icons.category_rounded),
                  const SizedBox(height: 12),
                  _buildUploadTypeSelector(),
                  const SizedBox(height: 24),

                  // ── Dynamic form based on type ───────────────────
                  if (_uploadType == 0) _buildNewVisitForm(),
                  if (_uploadType == 1) _buildExistingVisitForm(),
                  if (_uploadType == 2) _buildDirectUploadForm(),

                  const SizedBox(height: 36),

                  // ── Upload button ────────────────────────────────
                  _buildUploadButton(),
                  const SizedBox(height: 20),
                ],
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Upload Record',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3)),
                        SizedBox(height: 4),
                        Text('Add a new document to your health vault',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
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

  // ── Upload type selector ─────────────────────────────────────────────────────
  Widget _buildUploadTypeSelector() {
    final types = [
      {
        'label': 'New Visit',
        'sub': 'New doctor episode',
        'icon': Icons.local_hospital_rounded,
      },
      {
        'label': 'Add to Visit',
        'sub': 'Existing episode',
        'icon': Icons.add_to_photos_rounded,
      },
      {
        'label': 'Direct Upload',
        'sub': 'Lab / old report',
        'icon': Icons.upload_file_rounded,
      },
    ];

    return Row(
      children: List.generate(types.length, (index) {
        final isSelected = _uploadType == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _uploadType = index;
              _resetControllers();
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                  right: index < types.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? _blue : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? _blue
                      : Colors.grey.withValues(alpha: 0.25),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                      color: _blue.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ]
                    : [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    types[index]['icon'] as IconData,
                    color: isSelected ? Colors.white : _blue,
                    size: 22,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    types[index]['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:
                        isSelected ? Colors.white : _darkText,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    types[index]['sub'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isSelected
                            ? Colors.white70
                            : Colors.grey.shade400,
                        fontSize: 9),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _resetControllers() {
    _titleController.clear();
    _doctorController.clear();
    _hospitalController.clear();
    _reportNameController.clear();
    _selectedDate = null;
    _uploadedFileName = null;
    _selectedEpisodeId = null;
  }

  // ── New Visit Form ───────────────────────────────────────────────────────────
  Widget _buildNewVisitForm() {
    return Form(
      key: _newVisitFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Doctor Name', Icons.person_rounded),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _doctorController,
            hint: 'e.g. Dr. Raghav Menon',
            icon: Icons.person_outline_rounded,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter doctor name'
                : null,
          ),
          const SizedBox(height: 20),
          _buildSectionLabel(
              'Hospital / Clinic', Icons.business_rounded),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _hospitalController,
            hint: 'e.g. Apollo Hospital, Hyderabad',
            icon: Icons.business_outlined,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter hospital name'
                : null,
          ),
          const SizedBox(height: 20),
          _buildSectionLabel('Visit Date', Icons.calendar_today_rounded),
          const SizedBox(height: 10),
          _buildDatePicker('Date of your visit'),
          const SizedBox(height: 20),
          _buildSectionLabel('Report Title', Icons.description_rounded),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _titleController,
            hint: 'e.g. ECG Report, Blood Test',
            icon: Icons.description_outlined,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter report title'
                : null,
          ),
          const SizedBox(height: 20),
          _buildSectionLabel('Upload File', Icons.attach_file_rounded),
          const SizedBox(height: 10),
          _buildDropZone(),
          const SizedBox(height: 14),
          _buildAiNote(),
        ],
      ),
    );
  }

  // ── Add to Existing Visit Form ───────────────────────────────────────────────
  Widget _buildExistingVisitForm() {
    return Form(
      key: _existingFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(
              'Select Existing Episode', Icons.history_rounded),
          const SizedBox(height: 12),
          // Episode list
          ..._existingEpisodes.map((ep) => _buildEpisodeSelectItem(ep)),
          const SizedBox(height: 20),
          _buildSectionLabel('Report Title', Icons.description_rounded),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _titleController,
            hint: 'e.g. Follow-up Blood Test',
            icon: Icons.description_outlined,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter report title'
                : null,
          ),
          const SizedBox(height: 20),
          _buildSectionLabel('Upload File', Icons.attach_file_rounded),
          const SizedBox(height: 10),
          _buildDropZone(),
          const SizedBox(height: 14),
          _buildAiNote(),
        ],
      ),
    );
  }

  // ── Direct Upload Form ───────────────────────────────────────────────────────
  Widget _buildDirectUploadForm() {
    return Form(
      key: _directFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Report Name', Icons.description_rounded),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _reportNameController,
            hint: 'e.g. Blood Test, Thyroid Report',
            icon: Icons.description_outlined,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter report name'
                : null,
          ),
          const SizedBox(height: 20),
          _buildSectionLabel(
              'Date on Report', Icons.calendar_today_rounded),
          const SizedBox(height: 10),
          _buildDatePicker('Date printed on the report'),
          const SizedBox(height: 20),
          _buildSectionLabel('Upload File', Icons.attach_file_rounded),
          const SizedBox(height: 10),
          _buildDropZone(),
          const SizedBox(height: 14),
          _buildAiNote(),
        ],
      ),
    );
  }

  // ── Episode select item ──────────────────────────────────────────────────────
  Widget _buildEpisodeSelectItem(Map<String, dynamic> ep) {
    final isSelected = _selectedEpisodeId == ep['id'];
    final color = ep['color'] as Color;
    final lightColor = ep['lightColor'] as Color;

    return GestureDetector(
      onTap: () => setState(() => _selectedEpisodeId = ep['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? _lightBlue : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? _blue
                : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Dept icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: lightColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(ep['icon'] as IconData,
                    color: color, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ep['doctor'] as String,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _darkText)),
                  const SizedBox(height: 2),
                  Text(
                    '${ep['hospital']} · ${ep['date']}',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: lightColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(ep['department'] as String,
                        style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            // Radio indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _blue : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: _blue,
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Drop zone ────────────────────────────────────────────────────────────────
  Widget _buildDropZone() {
    return GestureDetector(
      onTap: _pickFile,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: _uploadedFileName != null
              ? const Color(0xFFE8F5E9)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _uploadedFileName != null
                ? const Color(0xFF2E7D32)
                : _blue.withValues(alpha: 0.4),
            width: 1.5,
            style: _uploadedFileName != null
                ? BorderStyle.solid
                : BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _uploadedFileName != null
                  ? Icons.check_circle_rounded
                  : Icons.attach_file_rounded,
              color: _uploadedFileName != null
                  ? const Color(0xFF2E7D32)
                  : _blue,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _uploadedFileName != null
                  ? 'File selected!'
                  : 'Tap to upload file',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _uploadedFileName != null
                      ? const Color(0xFF2E7D32)
                      : _blue),
            ),
            const SizedBox(height: 4),
            Text(
              _uploadedFileName != null
                  ? _uploadedFileName!.length > 30
                  ? '${_uploadedFileName!.substring(0, 30)}...'
                  : _uploadedFileName!
                  : 'PDF, JPG, PNG supported',
              style: TextStyle(
                  fontSize: 11,
                  color: _uploadedFileName != null
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade400),
            ),
            if (_uploadedFileName != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _uploadedFileName = null),
                child: const Text('Remove',
                    style: TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── AI note ──────────────────────────────────────────────────────────────────
  Widget _buildAiNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color(0xFFA5D6A7), width: 0.8),
      ),
      child: const Row(
        children: [
          Icon(Icons.psychology_rounded,
              size: 16, color: Color(0xFF2E7D32)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI will auto-detect the department from your report',
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ── Date picker tile ─────────────────────────────────────────────────────────
  Widget _buildDatePicker(String hint) {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
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
            const Icon(Icons.calendar_today_rounded,
                color: _blue, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? _formatDate(_selectedDate!)
                    : hint,
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
        hintStyle: TextStyle(
            color: Colors.grey.shade400, fontSize: 14),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_rounded, size: 22),
            SizedBox(width: 10),
            Text('Upload Record',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
