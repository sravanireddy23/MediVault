import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pdf_viewer_screen.dart';
import 'image_viewer_screen.dart';
import 'upload_record_screen.dart';
import 'ai_chat_screen.dart';
import 'edit_record_bottom_sheet.dart';
import '../services/s3_service.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  static const Color kPrimaryBlue  = Color(0xFF1565C0);
  static const Color kLightBlue    = Color(0xFF1E88E5);
  static const Color kAppBg        = Color(0xFFF5F8FF);
  static const Color kDarkText     = Color(0xFF1A1A2E);
  static const Color kEmergencyRed = Color(0xFFD32F2F);

  List<Map<String, dynamic>> _allRecords      = [];
  List<Map<String, dynamic>> _filteredRecords = [];
  bool   _loading     = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  String? _filterType;
  String? _filterDept;
  String? _filterYear;

  static const Map<String, Color> _deptColors = {
    'Cardiology':       Color(0xFFE53935),
    'Pathology':        Color(0xFF8E24AA),
    'Radiology':        Color(0xFF1E88E5),
    'Orthopedics':      Color(0xFF43A047),
    'Neurology':        Color(0xFFFF6F00),
    'Dermatology':      Color(0xFF00897B),
    'Gastroenterology': Color(0xFF6D4C41),
    'ENT':              Color(0xFF039BE5),
    'Ophthalmology':    Color(0xFF00ACC1),
    'Gynecology':       Color(0xFFE91E63),
    'Pediatrics':       Color(0xFFFF7043),
    'Urology':          Color(0xFF5C6BC0),
    'Oncology':         Color(0xFF37474F),
    'Endocrinology':    Color(0xFF558B2F),
    'Pulmonology':      Color(0xFF1565C0),
    'Nephrology':       Color(0xFF6A1B9A),
    'Psychiatry':       Color(0xFF283593),
    'General':          Color(0xFF546E7A),
    'Dentistry':        Color(0xFF00695C),
    'Other':            Color(0xFF757575),
  };

  static const Map<String, IconData> _deptIcons = {
    'Cardiology':       Icons.favorite,
    'Pathology':        Icons.science,
    'Radiology':        Icons.radio_button_checked,
    'Orthopedics':      Icons.accessibility_new,
    'Neurology':        Icons.psychology,
    'Dermatology':      Icons.face,
    'Gastroenterology': Icons.lunch_dining,
    'ENT':              Icons.hearing,
    'Ophthalmology':    Icons.remove_red_eye,
    'Gynecology':       Icons.female,
    'Pediatrics':       Icons.child_care,
    'Urology':          Icons.water_drop,
    'Oncology':         Icons.biotech,
    'Endocrinology':    Icons.monitor_heart,
    'Pulmonology':      Icons.air,
    'Nephrology':       Icons.opacity,
    'Psychiatry':       Icons.self_improvement,
    'General':          Icons.local_hospital,
    'Dentistry':        Icons.medical_services,
    'Other':            Icons.folder_special,
  };

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const List<String> _months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  static const List<String> _shortMonths = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _monthYear(DateTime dt) => '${_months[dt.month]} ${dt.year}';
  String _shortDate(DateTime dt)  => '${_shortMonths[dt.month]} ${dt.day}, ${dt.year}';

  DateTime _parseDate(dynamic ts, dynamic fallback) {
    if (ts is Timestamp) return ts.toDate();
    if (ts is String)    return DateTime.tryParse(ts) ?? DateTime.now();
    if (fallback is Timestamp) return fallback.toDate();
    if (fallback is String)    return DateTime.tryParse(fallback) ?? DateTime.now();
    return DateTime.now();
  }

  Future<void> _loadRecords() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users').doc(uid).collection('records')
          .orderBy('uploadedAt', descending: true)
          .get();
      final records = snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      setState(() {
        _allRecords      = records;
        _filteredRecords = records;
        _loading         = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  bool get _hasActiveFilters =>
      _filterType != null || _filterDept != null || _filterYear != null;

  int get _activeFilterCount =>
      (_filterType != null ? 1 : 0) +
          (_filterDept != null ? 1 : 0) +
          (_filterYear != null ? 1 : 0);

  List<String> get _availableYears {
    final years = _allRecords.map((r) {
      final dt = _parseDate(r['uploadedAt'], r['date']);
      return dt.year.toString();
    }).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  List<String> get _availableDepts {
    final depts = _allRecords
        .map((r) => (r['department'] ?? '').toString())
        .where((d) => d.isNotEmpty && d != 'Pending AI Detection')
        .toSet()
        .toList();
    depts.sort();
    return depts;
  }

  void _applyFilters() {
    setState(() {
      _filteredRecords = _allRecords.where((r) {
        if (_searchQuery.isNotEmpty) {
          final t = (r['title']      ?? '').toString().toLowerCase();
          final d = (r['doctor']     ?? '').toString().toLowerCase();
          final h = (r['hospital']   ?? '').toString().toLowerCase();
          final p = (r['department'] ?? '').toString().toLowerCase();
          if (!t.contains(_searchQuery) && !d.contains(_searchQuery) &&
              !h.contains(_searchQuery) && !p.contains(_searchQuery)) {
            return false;
          }
        }
        if (_filterType != null) {
          final uploadType = r['uploadType'] ?? 'direct_upload';
          if (_filterType == 'Doctor Visit' &&
              uploadType != 'new_visit' && uploadType != 'existing_visit') {
            return false;
          }
          if (_filterType == 'Direct Upload' && uploadType != 'direct_upload') {
            return false;
          }
        }
        if (_filterDept != null) {
          if ((r['department'] ?? '').toString() != _filterDept) return false;
        }
        if (_filterYear != null) {
          final dt = _parseDate(r['uploadedAt'], r['date']);
          if (dt.year.toString() != _filterYear) return false;
        }
        return true;
      }).toList();
    });
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query.toLowerCase());
    _applyFilters();
  }

  void _clearFilters() {
    setState(() {
      _filterType = null;
      _filterDept = null;
      _filterYear = null;
    });
    _applyFilters();
  }

  void _showFilterSheet() {
    String? tempType = _filterType;
    String? tempDept = _filterDept;
    String? tempYear = _filterYear;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: kPrimaryBlue, size: 20),
                      const SizedBox(width: 8),
                      const Text('Filter Records',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kDarkText)),
                      const Spacer(),
                      if (tempType != null || tempDept != null || tempYear != null)
                        GestureDetector(
                          onTap: () => setSheetState(() {
                            tempType = null;
                            tempDept = null;
                            tempYear = null;
                          }),
                          child: const Text('Clear all',
                              style: TextStyle(color: kEmergencyRed, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sheetSectionLabel('TYPE'),
                  const SizedBox(height: 10),
                  Row(
                    children: ['Doctor Visit', 'Direct Upload'].map((type) {
                      final isSelected = tempType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setSheetState(() =>
                          tempType = tempType == type ? null : type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected ? kPrimaryBlue : const Color(0xFFF5F8FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? kPrimaryBlue : Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  type == 'Doctor Visit' ? Icons.local_hospital_rounded : Icons.upload_file_rounded,
                                  size: 14,
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(type,
                                    style: TextStyle(
                                        color: isSelected ? Colors.white : kDarkText,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  if (_availableDepts.isNotEmpty) ...[
                    _sheetSectionLabel('DEPARTMENT'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _availableDepts.map((dept) {
                        final isSelected = tempDept == dept;
                        final color = _deptColors[dept] ?? const Color(0xFF546E7A);
                        return GestureDetector(
                          onTap: () => setSheetState(() =>
                          tempDept = tempDept == dept ? null : dept),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? color : color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? color : color.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(dept,
                                style: TextStyle(
                                    color: isSelected ? Colors.white : color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (_availableYears.isNotEmpty) ...[
                    _sheetSectionLabel('YEAR'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _availableYears.map((year) {
                        final isSelected = tempYear == year;
                        return GestureDetector(
                          onTap: () => setSheetState(() =>
                          tempYear = tempYear == year ? null : year),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected ? kPrimaryBlue : const Color(0xFFF5F8FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? kPrimaryBlue : Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(year,
                                style: TextStyle(
                                    color: isSelected ? Colors.white : kDarkText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filterType = tempType;
                          _filterDept = tempDept;
                          _filterYear = tempYear;
                        });
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Apply Filters',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sheetSectionLabel(String label) {
    return Text(label,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey[500],
            letterSpacing: 1.0));
  }

  // ── KEY FIX: Group by doctor+hospital so all records under same doctor merge ──
  Map<String, List<Map<String, dynamic>>> _groupByMonth() {
    final Map<String, List<Map<String, dynamic>>> map = {};
    for (final r in _filteredRecords) {
      final key = _monthYear(_parseDate(r['uploadedAt'], r['date']));
      map.putIfAbsent(key, () => []).add(r);
    }
    return map;
  }

  List<_RecordGroup> _groupIntoEpisodes(List<Map<String, dynamic>> records) {
    final Map<String, List<Map<String, dynamic>>> episodeMap = {};
    final List<Map<String, dynamic>> directUploads = [];

    for (final r in records) {
      final uploadType = (r['uploadType'] ?? '').toString();
      final doctor     = (r['doctor']     ?? '').toString().trim();
      final hospital   = (r['hospital']   ?? '').toString().trim();

      if ((uploadType == 'new_visit' || uploadType == 'existing_visit') &&
          doctor.isNotEmpty) {
        // ── FIX: group ALL doctor records by doctor+hospital key ──
        final key = '${doctor.toLowerCase()}_${hospital.toLowerCase()}';
        episodeMap.putIfAbsent(key, () => []).add(r);
      } else {
        directUploads.add(r);
      }
    }

    final List<_RecordGroup> groups = [];

    for (final entry in episodeMap.entries) {
      final files = entry.value;
      // Sort files within episode newest first
      files.sort((a, b) {
        final da = _parseDate(a['uploadedAt'], a['date']);
        final db = _parseDate(b['uploadedAt'], b['date']);
        return db.compareTo(da);
      });
      final first = files.first;
      groups.add(_RecordGroup(
        isEpisode:  true,
        doctor:     first['doctor']     ?? '',
        hospital:   first['hospital']   ?? '',
        department: first['department'] ?? 'General',
        date:       _parseDate(first['uploadedAt'], first['date']),
        files:      files,
      ));
    }
    groups.sort((a, b) => b.date.compareTo(a.date));

    for (final r in directUploads) {
      groups.add(_RecordGroup(
        isEpisode:  false,
        doctor:     '',
        hospital:   '',
        department: r['department'] ?? 'General',
        date:       _parseDate(r['uploadedAt'], r['date']),
        files:      [r],
      ));
    }
    return groups;
  }

  bool _isPdf(Map<String, dynamic> r) {
    final name = (r['fileName'] ?? r['title'] ?? '').toString().toLowerCase();
    final url  = (r['fileUrl']  ?? '').toString().toLowerCase();
    return name.endsWith('.pdf') || url.contains('.pdf');
  }

  String _badgeLabel(Map<String, dynamic> r) {
    if (_isPdf(r)) return 'PDF';
    final dept = (r['department'] ?? '').toString().toUpperCase();
    if (dept == 'PATHOLOGY' || dept == 'LABORATORY') return 'LAB';
    return 'IMG';
  }

  Color _badgeColor(String label) {
    switch (label) {
      case 'PDF': return kEmergencyRed;
      case 'LAB': return const Color(0xFF8E24AA);
      default:    return kLightBlue;
    }
  }

  void _openRecord(Map<String, dynamic> record) {
    if (_isPdf(record)) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
            url: record['fileUrl'] ?? '', title: record['title'] ?? 'Report'),
      ));
    } else {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ImageViewerScreen(
            url: record['fileUrl'] ?? '', title: record['title'] ?? 'Report'),
      ));
    }
  }

  void _openAiExplain(Map<String, dynamic> record) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => AiChatScreen(preloadedRecord: record),
    ));
  }

  void _openEdit(Map<String, dynamic> record) {
    EditRecordBottomSheet.show(
      context,
      record: record,
      onSaved: _loadRecords,
    );
  }

  void _showOptionsSheet(Map<String, dynamic> record) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _OptionsSheet(
        record:      record,
        isPdf:       _isPdf(record),
        onView:      () { Navigator.pop(context); _openRecord(record); },
        onEdit:      () { Navigator.pop(context); _openEdit(record); },
        onAiExplain: () { Navigator.pop(context); _openAiExplain(record); },
        onDelete:    () { Navigator.pop(context); _confirmDelete(record); },
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 22),
            SizedBox(width: 8),
            Text('Delete Record',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${record['title'] ?? 'this record'}"',
              style: const TextStyle(fontWeight: FontWeight.w600, color: kDarkText),
            ),
            const SizedBox(height: 8),
            Text(
              'This will permanently delete the file from storage and cannot be undone.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kEmergencyRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white)),
              ),
              SizedBox(width: 12),
              Text('Deleting record...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final fileUrl = record['fileUrl'] ?? '';
      if (fileUrl.isNotEmpty) {
        await S3Service.deleteFile(fileUrl: fileUrl);
      }

      await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('records').doc(record['id'])
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record deleted successfully'),
            backgroundColor: Color(0xFF388E3C),
          ),
        );
        _loadRecords();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: kEmergencyRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthGroups = _groupByMonth();
    return Scaffold(
      backgroundColor: kAppBg,
      body: Column(
        children: [
          _buildHeader(_allRecords.length),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: kPrimaryBlue))
                : _filteredRecords.isEmpty
                ? _buildEmptyState()
                : _buildTimeline(monthGroups),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
              builder: (_) => const UploadRecordScreen()));
          _loadRecords();
        },
        backgroundColor: kPrimaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(int total) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Records',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        Text('Timeline · Newest first',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_copy_outlined, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text('$total Records',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  style: const TextStyle(fontSize: 15, color: kDarkText),
                  decoration: InputDecoration(
                    hintText: 'Search records, doctors...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                    prefixIcon: Icon(Icons.search, color: kPrimaryBlue.withValues(alpha: 0.7)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        })
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(Map<String, List<Map<String, dynamic>>> monthGroups) {
    return RefreshIndicator(
      color: kPrimaryBlue,
      onRefresh: _loadRecords,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          _buildStatsRow(),
          if (_hasActiveFilters) _buildActiveFilterChips(),
          ...monthGroups.entries.map((entry) {
            final groups = _groupIntoEpisodes(entry.value);
            return _buildMonthSection(entry.key, groups);
          }),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            '${_filteredRecords.length} record${_filteredRecords.length == 1 ? '' : 's'}',
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _hasActiveFilters ? const Color(0xFFE3F2FD) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _hasActiveFilters ? kPrimaryBlue : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune,
                      size: 15,
                      color: _hasActiveFilters ? kPrimaryBlue : Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('Filter',
                      style: TextStyle(
                          fontSize: 13,
                          color: _hasActiveFilters ? kPrimaryBlue : Colors.grey[700],
                          fontWeight: FontWeight.w600)),
                  if (_hasActiveFilters) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 18, height: 18,
                      decoration: const BoxDecoration(
                          color: kPrimaryBlue, shape: BoxShape.circle),
                      child: Center(
                        child: Text('$_activeFilterCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8, runSpacing: 4,
        children: [
          if (_filterType != null)
            _filterChip(_filterType!, () {
              setState(() => _filterType = null);
              _applyFilters();
            }),
          if (_filterDept != null)
            _filterChip(_filterDept!, () {
              setState(() => _filterDept = null);
              _applyFilters();
            }),
          if (_filterYear != null)
            _filterChip(_filterYear!, () {
              setState(() => _filterYear = null);
              _applyFilters();
            }),
          GestureDetector(
            onTap: _clearFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kEmergencyRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kEmergencyRed.withValues(alpha: 0.3)),
              ),
              child: const Text('Clear all',
                  style: TextStyle(
                      color: kEmergencyRed,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryBlue.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: kPrimaryBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 14, color: kPrimaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(String month, List<_RecordGroup> groups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(month,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[500],
                  letterSpacing: 0.5)),
        ),
        ...groups.map(_buildGroupCard),
      ],
    );
  }

  Widget _buildGroupCard(_RecordGroup group) {
    final deptColor = _deptColors[group.department] ?? const Color(0xFF757575);
    final deptIcon  = _deptIcons[group.department]  ?? Icons.folder_special;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          if (group.isEpisode)
            _buildEpisodeHeader(group, deptColor, deptIcon)
          else
            _buildDirectUploadHeader(group),
          ...group.files.asMap().entries.map(
                  (e) => _buildFileRow(e.value, e.key == group.files.length - 1)),
        ],
      ),
    );
  }

  Widget _buildEpisodeHeader(_RecordGroup group, Color deptColor, IconData deptIcon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: deptColor.withValues(alpha: 0.12),
                shape: BoxShape.circle),
            child: Icon(deptIcon, color: deptColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(group.doctor,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: kDarkText))),
                    Text(
                        '${group.files.length} file${group.files.length == 1 ? '' : 's'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${group.hospital} · ${_shortDate(group.date)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                      color: deptColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(group.department,
                      style: TextStyle(
                          color: deptColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectUploadHeader(_RecordGroup group) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: const Color(0xFFFF6F00).withValues(alpha: 0.12),
                shape: BoxShape.circle),
            child: const Icon(Icons.upload_file, color: Color(0xFFFF6F00), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(
                            group.files.first['title'] ?? 'Direct Upload',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: kDarkText))),
                    Text('1 file',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFF6F00).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4)),
                      child: const Text('Direct Upload',
                          style: TextStyle(
                              color: Color(0xFFFF6F00),
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 6),
                    Text(_shortDate(group.date),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileRow(Map<String, dynamic> record, bool isLast) {
    final badge      = _badgeLabel(record);
    final badgeColor = _badgeColor(badge);
    return GestureDetector(
      onTap: () => _openRecord(record),
      child: Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey[100]!, width: 1))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4))),
              child: Text(badge,
                  style: TextStyle(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(record['title'] ?? 'Report',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: kDarkText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            GestureDetector(
              onTap: () => _showOptionsSheet(record),
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.more_vert_rounded, size: 18, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
              _searchQuery.isEmpty && !_hasActiveFilters
                  ? 'No records yet'
                  : 'No results found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text(
              _searchQuery.isEmpty && !_hasActiveFilters
                  ? 'Tap + to upload your first medical record'
                  : 'Try adjusting your search or filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[400])),
          if (_hasActiveFilters) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
              label: const Text('Clear Filters'),
              style: TextButton.styleFrom(foregroundColor: kPrimaryBlue),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Models ────────────────────────────────────────────────────────────────────
class _RecordGroup {
  final bool isEpisode;
  final String doctor, hospital, department;
  final DateTime date;
  final List<Map<String, dynamic>> files;
  _RecordGroup({
    required this.isEpisode,
    required this.doctor,
    required this.hospital,
    required this.department,
    required this.date,
    required this.files,
  });
}

// ── Options bottom sheet ──────────────────────────────────────────────────────
class _OptionsSheet extends StatelessWidget {
  final Map<String, dynamic> record;
  final bool isPdf;
  final VoidCallback onView, onEdit, onAiExplain, onDelete;

  const _OptionsSheet({
    required this.record,
    required this.isPdf,
    required this.onView,
    required this.onEdit,
    required this.onAiExplain,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              record['title'] ?? 'Report',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A1A2E)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              isPdf ? 'PDF Document' : 'Image File',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _tile(
            icon: isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
            label: 'View ${isPdf ? 'PDF' : 'Image'}',
            color: const Color(0xFF1565C0),
            onTap: onView,
          ),
          _tile(
            icon: Icons.edit_outlined,
            label: 'Edit',
            color: const Color(0xFF1E88E5),
            onTap: onEdit,
          ),
          _tile(
            icon: Icons.auto_awesome,
            label: 'AI Explain',
            color: const Color(0xFF388E3C),
            onTap: onAiExplain,
          ),
          const Divider(height: 16),
          _tile(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            color: const Color(0xFFD32F2F),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: color)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}