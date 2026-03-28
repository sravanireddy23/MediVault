import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/s3_service.dart';
import '../../services/vision_service.dart';

class UploadRecordScreen extends StatefulWidget {
  const UploadRecordScreen({super.key});

  @override
  State<UploadRecordScreen> createState() => _UploadRecordScreenState();
}

class _UploadRecordScreenState extends State<UploadRecordScreen>
    with SingleTickerProviderStateMixin {

  static const _blue      = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF1E88E5);
  static const _lightBlue = Color(0xFFE3F2FD);
  static const _lightBg   = Color(0xFFF5F8FF);
  static const _darkText  = Color(0xFF1A1A2E);

  int _uploadType = 0;

  final _newVisitFormKey  = GlobalKey<FormState>();
  final _existingFormKey  = GlobalKey<FormState>();
  final _directFormKey    = GlobalKey<FormState>();

  final _titleController      = TextEditingController();
  final _doctorController     = TextEditingController();
  final _hospitalController   = TextEditingController();
  final _reportNameController = TextEditingController();

  DateTime?      _selectedDate;
  String?        _uploadedFileName;
  PlatformFile?  _pickedFile;
  bool           _isUploading        = false;
  String?        _selectedEpisodeId;
  String         _uploadStatus       = '';

  // ── OCR / Department detection state ──────────────────────────────────────
  String?        _confirmedDepartment;
  bool           _isDetecting        = false;

  late AnimationController _checkController;
  late Animation<double>   _checkAnimation;

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

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _blue, onPrimary: Colors.white,
            surface: Colors.white, onSurface: _darkText,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _showTopBanner({required bool success, String? customMessage}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _TopBanner(
        success: success,
        message: customMessage ??
            (success
                ? 'Report uploaded successfully!'
                : 'Upload unsuccessful. Please try again.'),
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 6), () => overlayEntry.remove());
  }

  // ── Pick file + trigger OCR ───────────────────────────────────────────────
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 10 * 1024 * 1024) {
          if (!mounted) return;
          _showTopBanner(
              success: false,
              customMessage: 'File too large. Maximum size is 10 MB.');
          return;
        }

        setState(() {
          _pickedFile          = file;
          _uploadedFileName    = file.name;
          _confirmedDepartment = null;
        });

        _showTopBanner(
            success: true,
            customMessage: 'File selected: ${file.name}');

        // Auto-trigger OCR for images only
        final ext = file.name.split('.').last.toLowerCase();
        if (['jpg', 'jpeg', 'png'].contains(ext) && file.bytes != null) {
          await _runOcrDetection(file.bytes!);
        } else if (ext == 'pdf') {
          // PDF → show manual picker
          if (mounted) _showDepartmentPicker();
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showTopBanner(
          success: false,
          customMessage: 'Could not open file picker. Please try again.');
    }
  }

  // ── Run OCR + Department detection ────────────────────────────────────────
  Future<void> _runOcrDetection(Uint8List bytes) async {
    setState(() => _isDetecting = true);
    try {
      final detected =
      await VisionService.detectDepartmentFromFile(bytes);

      if (!mounted) return;

      if (detected != null) {
        setState(() => _isDetecting = false);
        _showDepartmentConfirmSheet(detected);
      } else {
        setState(() => _isDetecting = false);
        _showDepartmentPicker();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDetecting = false);
      _showDepartmentPicker();
    }
  }

  // ── Department confirm bottom sheet ───────────────────────────────────────
  void _showDepartmentConfirmSheet(String detected) {
    final deptInfo = _getDeptInfo(detected);
    final color    = deptInfo['color'] as Color;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: Icon(deptInfo['icon'] as IconData,
                  color: color, size: 30),
            ),
            const SizedBox(height: 14),
            const Text('Department Detected!',
                style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.bold, color: _darkText)),
            const SizedBox(height: 8),
            Text('AI detected this report belongs to:',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border:
                Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(detected,
                  style: TextStyle(color: color, fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _confirmedDepartment = detected);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Confirm Department',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showDepartmentPicker();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _blue),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Change Department',
                    style: TextStyle(color: _blue,
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Manual department picker ──────────────────────────────────────────────
  void _showDepartmentPicker() {
    String? tempSelected = _confirmedDepartment;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select Department',
                  style: TextStyle(fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _darkText)),
              const SizedBox(height: 4),
              Text(
                _pickedFile?.name.split('.').last.toLowerCase() == 'pdf'
                    ? 'PDF detected — please select department manually'
                    : 'AI could not detect department — please select manually',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 320,
                child: ListView.builder(
                  itemCount: VisionService.validDepartments.length,
                  itemBuilder: (_, i) {
                    final dept  = VisionService.validDepartments[i];
                    final info  = _getDeptInfo(dept);
                    final color = info['color'] as Color;
                    final isSel = tempSelected == dept;
                    return GestureDetector(
                      onTap: () =>
                          setSheetState(() => tempSelected = dept),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSel
                              ? color.withValues(alpha: 0.08)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel
                                ? color
                                : Colors.grey
                                .withValues(alpha: 0.2),
                            width: isSel ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Icon(info['icon'] as IconData,
                                  color: color, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(dept,
                                  style: TextStyle(
                                      color: isSel ? color : _darkText,
                                      fontSize: 14,
                                      fontWeight: isSel
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                            ),
                            if (isSel)
                              Icon(Icons.check_circle_rounded,
                                  color: color, size: 18),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: tempSelected == null
                      ? null
                      : () {
                    setState(() =>
                    _confirmedDepartment = tempSelected);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    _blue.withValues(alpha: 0.4),
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dept icon/color map ───────────────────────────────────────────────────
  Map<String, dynamic> _getDeptInfo(String department) {
    const map = <String, Map<String, dynamic>>{
      'Cardiology':        {'icon': Icons.favorite_rounded,           'color': Color(0xFFE53935)},
      'Pathology':         {'icon': Icons.science_rounded,            'color': Color(0xFF8E24AA)},
      'Radiology':         {'icon': Icons.image_search_rounded,       'color': Color(0xFF1565C0)},
      'Neurology':         {'icon': Icons.psychology_rounded,         'color': Color(0xFF00897B)},
      'Orthopedics':       {'icon': Icons.accessibility_new_rounded,  'color': Color(0xFFEF6C00)},
      'Endocrinology':     {'icon': Icons.water_drop_rounded,         'color': Color(0xFF00838F)},
      'Gastroenterology':  {'icon': Icons.medical_services_rounded,   'color': Color(0xFF2E7D32)},
      'Pulmonology':       {'icon': Icons.air_rounded,                'color': Color(0xFF1976D2)},
      'Dermatology':       {'icon': Icons.face_rounded,               'color': Color(0xFFAD1457)},
      'Ophthalmology':     {'icon': Icons.remove_red_eye_rounded,     'color': Color(0xFF00695C)},
      'ENT':               {'icon': Icons.hearing_rounded,            'color': Color(0xFF6A1B9A)},
      'Urology':           {'icon': Icons.water_rounded,              'color': Color(0xFF0277BD)},
      'Nephrology':        {'icon': Icons.filter_alt_rounded,         'color': Color(0xFF558B2F)},
      'Oncology':          {'icon': Icons.biotech_rounded,            'color': Color(0xFFC62828)},
      'Gynecology':        {'icon': Icons.pregnant_woman_rounded,     'color': Color(0xFFD81B60)},
      'Pediatrics':        {'icon': Icons.child_care_rounded,         'color': Color(0xFFF57F17)},
      'Psychiatry':        {'icon': Icons.self_improvement_rounded,   'color': Color(0xFF4527A0)},
      'General Medicine':  {'icon': Icons.local_hospital_rounded,     'color': Color(0xFF546E7A)},
      'General Surgery':   {'icon': Icons.medical_information_rounded,'color': Color(0xFF37474F)},
      'Dentistry':         {'icon': Icons.sentiment_satisfied_rounded,'color': Color(0xFF00838F)},
    };
    return map[department] ??
        {'icon': Icons.local_hospital_rounded,
          'color': const Color(0xFF546E7A)};
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    bool isValid = false;

    if (_uploadType == 0) {
      isValid = _newVisitFormKey.currentState?.validate() ?? false;
      if (isValid && _selectedDate == null) {
        _showTopBanner(success: false,
            customMessage: 'Please select the visit date.');
        return;
      }
      if (isValid && _pickedFile == null) {
        _showTopBanner(success: false,
            customMessage: 'Please upload a file.');
        return;
      }
    } else if (_uploadType == 1) {
      if (_selectedEpisodeId == null) {
        _showTopBanner(success: false,
            customMessage: 'Please select an existing episode.');
        return;
      }
      isValid = _existingFormKey.currentState?.validate() ?? false;
      if (isValid && _pickedFile == null) {
        _showTopBanner(success: false,
            customMessage: 'Please upload a file.');
        return;
      }
    } else {
      isValid = _directFormKey.currentState?.validate() ?? false;
      if (isValid && _selectedDate == null) {
        _showTopBanner(success: false,
            customMessage: 'Please select the report date.');
        return;
      }
      if (isValid && _pickedFile == null) {
        _showTopBanner(success: false,
            customMessage: 'Please upload a file.');
        return;
      }
    }

    if (!isValid) return;

    // If no department confirmed yet → trigger picker
    if (_confirmedDepartment == null && _pickedFile != null) {
      final ext = _pickedFile!.name.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png'].contains(ext) &&
          _pickedFile!.bytes != null) {
        _showTopBanner(
            success: true,
            customMessage: 'Detecting department before upload...');
        await _runOcrDetection(_pickedFile!.bytes!);
        if (_confirmedDepartment == null) return;
        return;
      } else {
        _showDepartmentPicker();
        return;
      }
    }

    setState(() {
      _isUploading  = true;
      _uploadStatus = 'Uploading file to cloud...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      setState(() => _uploadStatus = 'Uploading file to cloud...');
      final s3Url = await S3Service.uploadFile(
        file: _pickedFile!, userId: user.uid, folder: 'records',
      );

      setState(() => _uploadStatus = 'Saving record details...');

      final title = _uploadType == 2
          ? _reportNameController.text.trim()
          : _titleController.text.trim();

      final department = _confirmedDepartment ?? 'Pending AI Detection';

      final recordData = {
        'title':      title,
        'fileUrl':    s3Url,
        'fileName':   _pickedFile!.name,
        'fileSize':   _pickedFile!.size,
        'uploadType': _uploadType == 0
            ? 'new_visit'
            : _uploadType == 1
            ? 'existing_visit'
            : 'direct_upload',
        'uploadedAt': FieldValue.serverTimestamp(),
        'date':       _selectedDate != null
            ? Timestamp.fromDate(_selectedDate!)
            : FieldValue.serverTimestamp(),
        'userId':     user.uid,
        'department': department,
        if (_uploadType == 0) ...{
          'doctor':   _doctorController.text.trim(),
          'hospital': _hospitalController.text.trim(),
        },
        if (_uploadType == 1) ...{'episodeId': _selectedEpisodeId},
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('records')
          .add(recordData);

      if (!mounted) return;
      setState(() {
        _isUploading  = false;
        _uploadStatus = '';
      });

      _showTopBanner(success: true,
          customMessage: 'Report uploaded successfully!');
      _checkController.forward();
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      _showSuccessSheet(department);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading  = false;
        _uploadStatus = '';
      });
      _showTopBanner(success: false,
          customMessage: 'Upload unsuccessful. Please try again.');
    }
  }

  void _showSuccessSheet(String department) {
    final title = _uploadType == 2
        ? _reportNameController.text
        : _titleController.text;
    final deptInfo = _getDeptInfo(department);
    final color    = deptInfo['color'] as Color;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 32),
            ScaleTransition(
              scale: _checkAnimation,
              child: Container(
                width: 90, height: 90,
                decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF2E7D32), size: 52),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Record Uploaded!',
                style: TextStyle(color: _darkText, fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('$title has been saved to your Medical Records.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500,
                    fontSize: 15, height: 1.5)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: color.withValues(alpha: 0.3), width: 0.8),
              ),
              child: Row(
                children: [
                  Icon(deptInfo['icon'] as IconData,
                      color: color, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Department',
                            style: TextStyle(color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                        Text(department,
                            style: TextStyle(color: color,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle_rounded,
                      color: color, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 28),
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
                  padding:
                  const EdgeInsets.symmetric(vertical: 16),
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
    _newVisitFormKey.currentState?.reset();
    _existingFormKey.currentState?.reset();
    _directFormKey.currentState?.reset();
    _titleController.clear();
    _doctorController.clear();
    _hospitalController.clear();
    _reportNameController.clear();
    setState(() {
      _uploadType          = 0;
      _selectedDate        = null;
      _uploadedFileName    = null;
      _pickedFile          = null;
      _selectedEpisodeId   = null;
      _confirmedDepartment = null;
    });
    _checkController.reset();
  }

  void _resetControllers() {
    _titleController.clear();
    _doctorController.clear();
    _hospitalController.clear();
    _reportNameController.clear();
    _selectedDate        = null;
    _uploadedFileName    = null;
    _pickedFile          = null;
    _selectedEpisodeId   = null;
    _confirmedDepartment = null;
  }

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
                  _buildSectionLabel(
                      'What type of upload?', Icons.category_rounded),
                  const SizedBox(height: 12),
                  _buildUploadTypeSelector(),
                  const SizedBox(height: 24),
                  if (_uploadType == 0) _buildNewVisitForm(),
                  if (_uploadType == 1) _buildExistingVisitForm(),
                  if (_uploadType == 2) _buildDirectUploadForm(),
                  const SizedBox(height: 36),
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
                            style: TextStyle(color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3)),
                        SizedBox(height: 4),
                        Text(
                            'Add a new document to your health vault',
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

  Widget _buildUploadTypeSelector() {
    final types = [
      {'label': 'New Visit',     'sub': 'New doctor episode', 'icon': Icons.local_hospital_rounded},
      {'label': 'Add to Visit',  'sub': 'Existing episode',   'icon': Icons.add_to_photos_rounded},
      {'label': 'Direct Upload', 'sub': 'Lab / old report',   'icon': Icons.upload_file_rounded},
    ];
    return Row(
      children: List.generate(types.length, (index) {
        final isSelected = _uploadType == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(
                    () { _uploadType = index; _resetControllers(); }),
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
                    ? [BoxShadow(
                    color: _blue.withValues(alpha: 0.25),
                    blurRadius: 8, offset: const Offset(0, 3))]
                    : [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  Icon(types[index]['icon'] as IconData,
                      color: isSelected ? Colors.white : _blue,
                      size: 22),
                  const SizedBox(height: 6),
                  Text(types[index]['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isSelected ? Colors.white : _darkText,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(types[index]['sub'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isSelected
                              ? Colors.white70
                              : Colors.grey.shade400,
                          fontSize: 9)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

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
                    : null),
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
                    : null),
            const SizedBox(height: 20),
            _buildSectionLabel(
                'Visit Date', Icons.calendar_today_rounded),
            const SizedBox(height: 10),
            _buildDatePicker('Date of your visit'),
            const SizedBox(height: 20),
            _buildSectionLabel(
                'Report Title', Icons.description_rounded),
            const SizedBox(height: 10),
            _buildTextField(
                controller: _titleController,
                hint: 'e.g. ECG Report, Blood Test',
                icon: Icons.description_outlined,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter report title'
                    : null),
            const SizedBox(height: 20),
            _buildSectionLabel(
                'Upload File', Icons.attach_file_rounded),
            const SizedBox(height: 10),
            _buildDropZone(),
            const SizedBox(height: 14),
            _buildAiNote(),
          ]),
    );
  }

  Widget _buildExistingVisitForm() {
    return Form(
      key: _existingFormKey,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel(
                'Select Existing Episode', Icons.history_rounded),
            const SizedBox(height: 12),
            ..._existingEpisodes.map((ep) => _buildEpisodeSelectItem(ep)),
            const SizedBox(height: 20),
            _buildSectionLabel(
                'Report Title', Icons.description_rounded),
            const SizedBox(height: 10),
            _buildTextField(
                controller: _titleController,
                hint: 'e.g. Follow-up Blood Test',
                icon: Icons.description_outlined,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter report title'
                    : null),
            const SizedBox(height: 20),
            _buildSectionLabel(
                'Upload File', Icons.attach_file_rounded),
            const SizedBox(height: 10),
            _buildDropZone(),
            const SizedBox(height: 14),
            _buildAiNote(),
          ]),
    );
  }

  Widget _buildDirectUploadForm() {
    return Form(
      key: _directFormKey,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel(
                'Report Name', Icons.description_rounded),
            const SizedBox(height: 10),
            _buildTextField(
                controller: _reportNameController,
                hint: 'e.g. Blood Test, Thyroid Report',
                icon: Icons.description_outlined,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter report name'
                    : null),
            const SizedBox(height: 20),
            _buildSectionLabel(
                'Date on Report', Icons.calendar_today_rounded),
            const SizedBox(height: 10),
            _buildDatePicker('Date printed on the report'),
            const SizedBox(height: 20),
            _buildSectionLabel(
                'Upload File', Icons.attach_file_rounded),
            const SizedBox(height: 10),
            _buildDropZone(),
            const SizedBox(height: 14),
            _buildAiNote(),
          ]),
    );
  }

  Widget _buildEpisodeSelectItem(Map<String, dynamic> ep) {
    final isSelected = _selectedEpisodeId == ep['id'];
    final color      = ep['color'] as Color;
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
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: lightColor, shape: BoxShape.circle),
              child: Center(child: Icon(ep['icon'] as IconData,
                  color: color, size: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ep['doctor'] as String,
                        style: const TextStyle(fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _darkText)),
                    const SizedBox(height: 2),
                    Text('${ep['hospital']} · ${ep['date']}',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: lightColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(ep['department'] as String,
                          style: TextStyle(color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
            ),
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected
                        ? _blue
                        : Colors.grey.shade300,
                    width: 2),
              ),
              child: isSelected
                  ? Center(
                  child: Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(
                        color: _blue, shape: BoxShape.circle),
                  ))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _isUploading ? null : _pickFile,
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
              ),
            ),
            child: Column(
              children: [
                if (_isDetecting) ...[
                  const SizedBox(
                    width: 28, height: 28,
                    child: CircularProgressIndicator(
                        color: _blue, strokeWidth: 2.5),
                  ),
                  const SizedBox(height: 8),
                  const Text('Detecting department...',
                      style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _blue)),
                  const SizedBox(height: 4),
                  Text('AI is reading your report',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400)),
                ] else ...[
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
                          : _blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _uploadedFileName != null
                        ? (_uploadedFileName!.length > 30
                        ? '${_uploadedFileName!.substring(0, 30)}...'
                        : _uploadedFileName!)
                        : 'PDF, JPG, PNG supported  •  Max 10 MB',
                    style: TextStyle(
                      fontSize: 11,
                      color: _uploadedFileName != null
                          ? const Color(0xFF2E7D32)
                          : Colors.grey.shade400,
                    ),
                  ),
                  if (_uploadedFileName != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() {
                        _uploadedFileName    = null;
                        _pickedFile          = null;
                        _confirmedDepartment = null;
                      }),
                      child: const Text('Remove',
                          style: TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),

        // Confirmed department chip
        if (_confirmedDepartment != null) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _showDepartmentPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: (_getDeptInfo(_confirmedDepartment!)['color']
                as Color)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: (_getDeptInfo(_confirmedDepartment!)['color']
                  as Color)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getDeptInfo(
                        _confirmedDepartment!)['icon'] as IconData,
                    color: _getDeptInfo(
                        _confirmedDepartment!)['color'] as Color,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(_confirmedDepartment!,
                      style: TextStyle(
                          color: _getDeptInfo(
                              _confirmedDepartment!)['color']
                          as Color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  Icon(Icons.edit_rounded,
                      color: _getDeptInfo(
                          _confirmedDepartment!)['color'] as Color,
                      size: 12),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAiNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
        border:
        Border.all(color: const Color(0xFFA5D6A7), width: 0.8),
      ),
      child: const Row(
        children: [
          Icon(Icons.psychology_rounded,
              size: 16, color: Color(0xFF2E7D32)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI auto-detects department from images · PDF requires manual selection',
              style: TextStyle(fontSize: 12,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

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
                      : FontWeight.normal,
                ),
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

  Widget _buildSectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _blue, size: 16),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(color: _darkText,
                fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

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
        hintStyle:
        TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: _blue, size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F8FF),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: _blue.withValues(alpha: 0.3))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: _blue.withValues(alpha: 0.3))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            const BorderSide(color: _blue, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFFE53935))),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFFE53935), width: 2)),
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading || _isDetecting ? null : _submit,
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
            ? Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5),
          ),
          const SizedBox(height: 8),
          Text(_uploadStatus,
              style: const TextStyle(
                  fontSize: 12, color: Colors.white70)),
        ])
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

// ══════════════════════════════════════════════════════════════════════════════
// TOP BANNER WIDGET
// ══════════════════════════════════════════════════════════════════════════════
class _TopBanner extends StatefulWidget {
  final bool success;
  final String message;
  const _TopBanner({required this.success, required this.message});

  @override
  State<_TopBanner> createState() => _TopBannerState();
}

class _TopBannerState extends State<_TopBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(
        begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.success
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE53935);
    final icon = widget.success
        ? Icons.check_circle_rounded
        : Icons.error_rounded;
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            color: bgColor,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 14, left: 16, right: 16,
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(widget.message,
                      style: const TextStyle(color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}