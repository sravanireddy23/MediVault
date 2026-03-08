import 'package:flutter/material.dart';

// ── Data model ────────────────────────────────────────────────────────────────
class MedicalRecord {
  final String id;
  final String title;
  final String department;
  final String year;
  final String date;
  final String fileType; // 'PDF' | 'IMG' | 'LAB' | 'SCAN'
  final String doctor;
  final String hospital;

  const MedicalRecord({
    required this.id,
    required this.title,
    required this.department,
    required this.year,
    required this.date,
    required this.fileType,
    required this.doctor,
    required this.hospital,
  });
}

// ── Department metadata ───────────────────────────────────────────────────────
class DepartmentInfo {
  final String name;
  final IconData icon;
  final Color color;
  final Color lightColor;

  const DepartmentInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.lightColor,
  });
}

// ── Sample data ───────────────────────────────────────────────────────────────
const List<MedicalRecord> _sampleRecords = [
  MedicalRecord(id: '1', title: 'ECG Report', department: 'Cardiology', year: '2025', date: 'Mar 2, 2025', fileType: 'PDF', doctor: 'Dr. Raghav Menon', hospital: 'Apollo Hospital'),
  MedicalRecord(id: '2', title: 'Echo Cardiogram', department: 'Cardiology', year: '2024', date: 'Nov 15, 2024', fileType: 'SCAN', doctor: 'Dr. Raghav Menon', hospital: 'Apollo Hospital'),
  MedicalRecord(id: '3', title: 'Blood Test - CBC', department: 'Pathology', year: '2025', date: 'Feb 20, 2025', fileType: 'LAB', doctor: 'Dr. Priya Sharma', hospital: 'Medanta'),
  MedicalRecord(id: '4', title: 'Urine Analysis', department: 'Pathology', year: '2025', date: 'Jan 5, 2025', fileType: 'LAB', doctor: 'Dr. Priya Sharma', hospital: 'Medanta'),
  MedicalRecord(id: '5', title: 'Lipid Profile', department: 'Pathology', year: '2024', date: 'Aug 10, 2024', fileType: 'LAB', doctor: 'Dr. Amit Roy', hospital: 'Fortis'),
  MedicalRecord(id: '6', title: 'Chest X-Ray', department: 'Radiology', year: '2025', date: 'Feb 14, 2025', fileType: 'SCAN', doctor: 'Dr. Suresh Nair', hospital: 'KIMS'),
  MedicalRecord(id: '7', title: 'MRI Brain', department: 'Radiology', year: '2024', date: 'Sep 3, 2024', fileType: 'SCAN', doctor: 'Dr. Suresh Nair', hospital: 'KIMS'),
  MedicalRecord(id: '8', title: 'Abdominal CT Scan', department: 'Radiology', year: '2023', date: 'May 22, 2023', fileType: 'SCAN', doctor: 'Dr. Kavya Reddy', hospital: 'Yashoda'),
  MedicalRecord(id: '9', title: 'EEG Report', department: 'Neurology', year: '2024', date: 'Dec 1, 2024', fileType: 'PDF', doctor: 'Dr. Anand Krishnan', hospital: 'NIMHANS'),
  MedicalRecord(id: '10', title: 'Nerve Conduction Study', department: 'Neurology', year: '2023', date: 'Jul 18, 2023', fileType: 'PDF', doctor: 'Dr. Anand Krishnan', hospital: 'NIMHANS'),
  MedicalRecord(id: '11', title: 'Knee X-Ray', department: 'Orthopedics', year: '2025', date: 'Jan 30, 2025', fileType: 'SCAN', doctor: 'Dr. Vikram Singh', hospital: 'Sunshine Hospital'),
  MedicalRecord(id: '12', title: 'Post-Op Report', department: 'Orthopedics', year: '2023', date: 'Jun 10, 2023', fileType: 'PDF', doctor: 'Dr. Vikram Singh', hospital: 'Sunshine Hospital'),
  MedicalRecord(id: '13', title: 'Thyroid Function Test', department: 'Endocrinology', year: '2025', date: 'Mar 1, 2025', fileType: 'LAB', doctor: 'Dr. Meera Pillai', hospital: 'Care Hospital'),
  MedicalRecord(id: '14', title: 'HbA1c Test', department: 'Endocrinology', year: '2024', date: 'Oct 20, 2024', fileType: 'LAB', doctor: 'Dr. Meera Pillai', hospital: 'Care Hospital'),
  MedicalRecord(id: '15', title: 'Colonoscopy Report', department: 'Gastroenterology', year: '2024', date: 'Jul 7, 2024', fileType: 'PDF', doctor: 'Dr. Rajesh Iyer', hospital: 'Global Hospital'),
  MedicalRecord(id: '16', title: 'Pulmonary Function Test', department: 'Pulmonology', year: '2023', date: 'Apr 14, 2023', fileType: 'PDF', doctor: 'Dr. Sita Ram', hospital: 'Chest Hospital'),
];

const Map<String, DepartmentInfo> _deptMeta = {
  'Cardiology':      DepartmentInfo(name: 'Cardiology',      icon: Icons.favorite_rounded,        color: Color(0xFFE53935), lightColor: Color(0xFFFFEBEE)),
  'Pathology':       DepartmentInfo(name: 'Pathology',       icon: Icons.science_rounded,          color: Color(0xFF8E24AA), lightColor: Color(0xFFF3E5F5)),
  'Radiology':       DepartmentInfo(name: 'Radiology',       icon: Icons.image_search_rounded,     color: Color(0xFF1565C0), lightColor: Color(0xFFE3F2FD)),
  'Neurology':       DepartmentInfo(name: 'Neurology',       icon: Icons.psychology_rounded,       color: Color(0xFF00897B), lightColor: Color(0xFFE0F2F1)),
  'Orthopedics':     DepartmentInfo(name: 'Orthopedics',     icon: Icons.accessibility_new_rounded,color: Color(0xFFEF6C00), lightColor: Color(0xFFFFF3E0)),
  'Endocrinology':   DepartmentInfo(name: 'Endocrinology',   icon: Icons.water_drop_rounded,      color: Color(0xFF00838F), lightColor: Color(0xFFE0F7FA)),
  'Gastroenterology':DepartmentInfo(name: 'Gastroenterology',icon: Icons.medical_services_rounded, color: Color(0xFF2E7D32), lightColor: Color(0xFFE8F5E9)),
  'Pulmonology':     DepartmentInfo(name: 'Pulmonology',     icon: Icons.air_rounded,             color: Color(0xFF1976D2), lightColor: Color(0xFFE8F4FD)),
};

DepartmentInfo _getDeptInfo(String dept) {
  return _deptMeta[dept] ??
      const DepartmentInfo(
        name: 'Other',
        icon: Icons.folder_rounded,
        color: Color(0xFF546E7A),
        lightColor: Color(0xFFECEFF1),
      );
}

// ── Screen ────────────────────────────────────────────────────────────────────
class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen>
    with SingleTickerProviderStateMixin {
  // ── Colors ──────────────────────────────────────────────────────────────────
  static const _blue     = Color(0xFF1565C0);
  static const _lightBg  = Color(0xFFF5F8FF);
  static const _darkText = Color(0xFF1A1A2E);

  // ── State ───────────────────────────────────────────────────────────────────
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedDept;   // null = all departments
  String? _selectedYear;   // null = all years
  String _selectedFileType = 'All'; // All | PDF | LAB | SCAN | IMG

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Computed lists ───────────────────────────────────────────────────────────
  List<MedicalRecord> get _filtered {
    return _sampleRecords.where((r) {
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          r.title.toLowerCase().contains(q) ||
          r.department.toLowerCase().contains(q) ||
          r.doctor.toLowerCase().contains(q);
      final matchDept = _selectedDept == null || r.department == _selectedDept;
      final matchYear = _selectedYear == null || r.year == _selectedYear;
      final matchType = _selectedFileType == 'All' || r.fileType == _selectedFileType;
      return matchSearch && matchDept && matchYear && matchType;
    }).toList();
  }

  List<String> get _allDepts {
    final d = _sampleRecords.map((r) => r.department).toSet().toList();
    d.sort();
    return d;
  }

  List<String> get _allYears {
    final y = _sampleRecords.map((r) => r.year).toSet().toList();
    y.sort((a, b) => b.compareTo(a)); // newest first
    return y;
  }

  // ── Grouping ─────────────────────────────────────────────────────────────────
  Map<String, List<MedicalRecord>> _groupByDept(List<MedicalRecord> records) {
    final map = <String, List<MedicalRecord>>{};
    for (final r in records) {
      map.putIfAbsent(r.department, () => []).add(r);
    }
    // sort keys alphabetically
    return Map.fromEntries(
        map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  Map<String, List<MedicalRecord>> _groupByYear(List<MedicalRecord> records) {
    final map = <String, List<MedicalRecord>>{};
    for (final r in records) {
      map.putIfAbsent(r.year, () => []).add(r);
    }
    // sort keys newest first
    return Map.fromEntries(
        map.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
  }

  // ── File type chip color ─────────────────────────────────────────────────────
  Color _fileTypeColor(String type) {
    switch (type) {
      case 'PDF':  return const Color(0xFFE53935);
      case 'LAB':  return const Color(0xFF8E24AA);
      case 'SCAN': return const Color(0xFF1565C0);
      case 'IMG':  return const Color(0xFF2E7D32);
      default:     return const Color(0xFF546E7A);
    }
  }

  IconData _fileTypeIcon(String type) {
    switch (type) {
      case 'PDF':  return Icons.picture_as_pdf_rounded;
      case 'LAB':  return Icons.biotech_rounded;
      case 'SCAN': return Icons.document_scanner_rounded;
      case 'IMG':  return Icons.image_rounded;
      default:     return Icons.insert_drive_file_rounded;
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(innerBoxIsScrolled),
        ],
        body: Column(
          children: [
            _buildSearchBar(),
            _buildFilterRow(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDeptView(),
                  _buildYearView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────────
  Widget _buildAppBar(bool scrolled) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: scrolled ? 2 : 0,
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
              colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
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
                        Text('Medical Records',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3)),
                        SizedBox(height: 4),
                        Text('All your health documents in one place',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  // Total count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_copy_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${_filtered.length} Records',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Search Bar ───────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: _blue,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: _darkText, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search records, doctors, departments...',
          hintStyle:
          TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: Color(0xFF1565C0), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close_rounded,
                color: Colors.grey, size: 18),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ── Filter Row ───────────────────────────────────────────────────────────────
  Widget _buildFilterRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // File type filter chips
            ...['All', 'PDF', 'LAB', 'SCAN'].map((type) {
              final isSelected = _selectedFileType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFileType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _blue : const Color(0xFFF5F8FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? _blue
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (type != 'All') ...[
                          Icon(_fileTypeIcon(type),
                              size: 13,
                              color: isSelected
                                  ? Colors.white
                                  : _fileTypeColor(type)),
                          const SizedBox(width: 5),
                        ],
                        Text(type,
                            style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : _darkText,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(width: 4),
            Container(width: 1, height: 24, color: Colors.grey.shade300),
            const SizedBox(width: 12),

            // Year filter
            _buildDropdownChip(
              label: _selectedYear ?? 'Year',
              icon: Icons.calendar_today_rounded,
              isActive: _selectedYear != null,
              onTap: () => _showYearPicker(),
            ),
            const SizedBox(width: 8),

            // Department filter
            _buildDropdownChip(
              label: _selectedDept != null
                  ? (_selectedDept!.length > 10
                  ? '${_selectedDept!.substring(0, 10)}…'
                  : _selectedDept!)
                  : 'Department',
              icon: Icons.local_hospital_rounded,
              isActive: _selectedDept != null,
              onTap: () => _showDeptPicker(),
            ),

            // Clear filters
            if (_selectedDept != null || _selectedYear != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() {
                  _selectedDept = null;
                  _selectedYear = null;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.close_rounded,
                          size: 13, color: Color(0xFFE53935)),
                      SizedBox(width: 4),
                      Text('Clear',
                          style: TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE3F2FD) : const Color(0xFFF5F8FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? _blue : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: isActive ? _blue : Colors.grey),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: isActive ? _blue : _darkText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 14, color: isActive ? _blue : Colors.grey),
          ],
        ),
      ),
    );
  }

  // ── Tab Bar ──────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: _blue,
        unselectedLabelColor: Colors.grey,
        labelStyle:
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle:
        const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        indicatorColor: _blue,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.grey.withValues(alpha: 0.2),
        tabs: const [
          Tab(
            icon: Icon(Icons.local_hospital_rounded, size: 18),
            text: 'By Department',
            iconMargin: EdgeInsets.only(bottom: 2),
          ),
          Tab(
            icon: Icon(Icons.calendar_month_rounded, size: 18),
            text: 'By Year',
            iconMargin: EdgeInsets.only(bottom: 2),
          ),
        ],
      ),
    );
  }

  // ── Department View ──────────────────────────────────────────────────────────
  Widget _buildDeptView() {
    final grouped = _groupByDept(_filtered);

    if (grouped.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dept = grouped.keys.elementAt(index);
        final records = grouped[dept]!;
        final info = _getDeptInfo(dept);
        return _buildDeptSection(dept, records, info);
      },
    );
  }

  Widget _buildDeptSection(
      String dept, List<MedicalRecord> records, DepartmentInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Department header
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: info.lightColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: info.color.withValues(alpha: 0.25), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: info.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(info.icon, color: info.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dept,
                        style: TextStyle(
                            color: info.color,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    Text(
                      '${records.length} record${records.length > 1 ? 's' : ''}',
                      style: TextStyle(
                          color: info.color.withValues(alpha: 0.7),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: info.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${records.length}',
                  style: TextStyle(
                      color: info.color,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        // Records under this dept
        ...records.map((r) => _buildRecordCard(r, info)),

        const SizedBox(height: 20),
      ],
    );
  }

  // ── Year View ────────────────────────────────────────────────────────────────
  Widget _buildYearView() {
    final grouped = _groupByYear(_filtered);

    if (grouped.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final year = grouped.keys.elementAt(index);
        final records = grouped[year]!;
        return _buildYearSection(year, records);
      },
    );
  }

  Widget _buildYearSection(String year, List<MedicalRecord> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year header — timeline style
        Row(
          children: [
            // Year pill
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded,
                      color: Colors.white, size: 15),
                  const SizedBox(width: 6),
                  Text(year,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1565C0).withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${records.length} records',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Timeline list with dept color accent
        ...records.map((r) {
          final info = _getDeptInfo(r.department);
          return _buildRecordCard(r, info, showDeptTag: true);
        }),

        const SizedBox(height: 20),
      ],
    );
  }

  // ── Record Card ──────────────────────────────────────────────────────────────
  Widget _buildRecordCard(MedicalRecord record, DepartmentInfo info,
      {bool showDeptTag = false}) {
    final typeColor = _fileTypeColor(record.fileType);

    return GestureDetector(
      onTap: () => _showRecordDetail(record, info),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: info.color, width: 3.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // File type icon box
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_fileTypeIcon(record.fileType),
                  color: typeColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.title,
                      style: const TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(record.doctor,
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Dept tag (shown in year view)
                      if (showDeptTag) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: info.lightColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(record.department,
                              style: TextStyle(
                                  color: info.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 6),
                      ],

                      // Date
                      Icon(Icons.access_time_rounded,
                          size: 11, color: Colors.grey.shade400),
                      const SizedBox(width: 3),
                      Text(record.date,
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right side: file type badge + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: typeColor.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Text(record.fileType,
                      style: TextStyle(
                          color: typeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.shade300, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Record Detail Bottom Sheet ────────────────────────────────────────────────
  void _showRecordDetail(MedicalRecord record, DepartmentInfo info) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: info.lightColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(info.icon, color: info.color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.title,
                          style: const TextStyle(
                              color: Color(0xFF1A1A2E),
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(record.department,
                          style: TextStyle(
                              color: info.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _fileTypeColor(record.fileType)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _fileTypeColor(record.fileType)
                            .withValues(alpha: 0.4)),
                  ),
                  child: Text(record.fileType,
                      style: TextStyle(
                          color: _fileTypeColor(record.fileType),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Details grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _detailRow(Icons.calendar_today_rounded, 'Date',
                      record.date),
                  const SizedBox(height: 14),
                  _detailRow(Icons.person_rounded, 'Doctor',
                      record.doctor),
                  const SizedBox(height: 14),
                  _detailRow(Icons.local_hospital_rounded, 'Hospital',
                      record.hospital),
                  const SizedBox(height: 14),
                  _detailRow(Icons.folder_rounded, 'Year', record.year),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _blue,
                      side: const BorderSide(color: _blue),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Share',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('View Record',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _blue, size: 15),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  // ── Pickers ──────────────────────────────────────────────────────────────────
  void _showYearPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildPickerSheet(
        title: 'Filter by Year',
        icon: Icons.calendar_month_rounded,
        items: _allYears,
        selected: _selectedYear,
        onSelect: (v) => setState(() =>
        _selectedYear = (_selectedYear == v) ? null : v),
        colorBuilder: (_) => _blue,
        lightColorBuilder: (_) => const Color(0xFFE3F2FD),
      ),
    );
  }

  void _showDeptPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildPickerSheet(
        title: 'Filter by Department',
        icon: Icons.local_hospital_rounded,
        items: _allDepts,
        selected: _selectedDept,
        onSelect: (v) => setState(() =>
        _selectedDept = (_selectedDept == v) ? null : v),
        colorBuilder: (dept) => _getDeptInfo(dept).color,
        lightColorBuilder: (dept) => _getDeptInfo(dept).lightColor,
      ),
    );
  }

  Widget _buildPickerSheet({
    required String title,
    required IconData icon,
    required List<String> items,
    required String? selected,
    required void Function(String) onSelect,
    required Color Function(String) colorBuilder,
    required Color Function(String) lightColorBuilder,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(icon, color: _blue, size: 20),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: items.map((item) {
                final isSelected = selected == item;
                final color = colorBuilder(item);
                final lightColor = lightColorBuilder(item);
                return GestureDetector(
                  onTap: () {
                    onSelect(item);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? color : lightColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSelected
                              ? color
                              : color.withValues(alpha: 0.3)),
                    ),
                    child: Text(item,
                        style: TextStyle(
                            color: isSelected ? Colors.white : color,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.folder_off_rounded,
                color: _blue, size: 48),
          ),
          const SizedBox(height: 20),
          const Text('No records found',
              style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search query',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}