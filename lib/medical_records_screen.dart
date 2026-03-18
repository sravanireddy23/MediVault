import 'package:flutter/material.dart';

// ── Episode Model ─────────────────────────────────────────────────────────────
class Episode {
  final String id;
  final String doctorName;
  final String hospital;
  final String department;
  final String date;
  final String month; // for grouping e.g. 'March 2025'
  final String year;
  final List<EpisodeReport> reports;
  final bool isDirect; // true = direct upload, no doctor

  const Episode({
    required this.id,
    required this.doctorName,
    required this.hospital,
    required this.department,
    required this.date,
    required this.month,
    required this.year,
    required this.reports,
    this.isDirect = false,
  });
}

// ── Report inside an Episode ──────────────────────────────────────────────────
class EpisodeReport {
  final String id;
  final String title;
  final String fileType; // PDF | LAB | SCAN | IMG
  final String aiDepartment; // AI detected department (for direct uploads)

  const EpisodeReport({
    required this.id,
    required this.title,
    required this.fileType,
    this.aiDepartment = '',
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

const Map<String, DepartmentInfo> _deptMeta = {
  'Cardiology':      DepartmentInfo(name: 'Cardiology',      icon: Icons.favorite_rounded,         color: Color(0xFFE53935), lightColor: Color(0xFFFFEBEE)),
  'Pathology':       DepartmentInfo(name: 'Pathology',       icon: Icons.science_rounded,           color: Color(0xFF8E24AA), lightColor: Color(0xFFF3E5F5)),
  'Radiology':       DepartmentInfo(name: 'Radiology',       icon: Icons.image_search_rounded,      color: Color(0xFF1565C0), lightColor: Color(0xFFE3F2FD)),
  'Neurology':       DepartmentInfo(name: 'Neurology',       icon: Icons.psychology_rounded,        color: Color(0xFF00897B), lightColor: Color(0xFFE0F2F1)),
  'Orthopedics':     DepartmentInfo(name: 'Orthopedics',     icon: Icons.accessibility_new_rounded, color: Color(0xFFEF6C00), lightColor: Color(0xFFFFF3E0)),
  'Endocrinology':   DepartmentInfo(name: 'Endocrinology',   icon: Icons.water_drop_rounded,        color: Color(0xFF00838F), lightColor: Color(0xFFE0F7FA)),
  'Gastroenterology':DepartmentInfo(name: 'Gastroenterology',icon: Icons.medical_services_rounded,  color: Color(0xFF2E7D32), lightColor: Color(0xFFE8F5E9)),
  'Pulmonology':     DepartmentInfo(name: 'Pulmonology',     icon: Icons.air_rounded,               color: Color(0xFF1976D2), lightColor: Color(0xFFE8F4FD)),
  'General':         DepartmentInfo(name: 'General',         icon: Icons.local_hospital_rounded,    color: Color(0xFF546E7A), lightColor: Color(0xFFECEFF1)),
  'Direct Upload':   DepartmentInfo(name: 'Direct Upload',   icon: Icons.upload_file_rounded,       color: Color(0xFFF57F17), lightColor: Color(0xFFFFF8E1)),
};

DepartmentInfo _getDeptInfo(String dept) {
  return _deptMeta[dept] ??
      const DepartmentInfo(
        name: 'General',
        icon: Icons.folder_rounded,
        color: Color(0xFF546E7A),
        lightColor: Color(0xFFECEFF1),
      );
}

// ── Sample Data ───────────────────────────────────────────────────────────────
final List<Episode> _sampleEpisodes = [
  // March 2025 — Doctor Visit
  Episode(
    id: 'e1',
    doctorName: 'Dr. Raghav Menon',
    hospital: 'Apollo Hospital',
    department: 'Cardiology',
    date: 'Mar 2, 2025',
    month: 'March 2025',
    year: '2025',
    reports: [
      EpisodeReport(id: 'r1', title: 'ECG Report', fileType: 'PDF'),
      EpisodeReport(id: 'r2', title: 'Blood Test - CBC', fileType: 'LAB'),
      EpisodeReport(id: 'r3', title: 'Prescription', fileType: 'PDF'),
    ],
  ),
  // January 2025 — Doctor Visit
  Episode(
    id: 'e2',
    doctorName: 'Dr. Priya Sharma',
    hospital: 'Medanta',
    department: 'Pathology',
    date: 'Jan 5, 2025',
    month: 'January 2025',
    year: '2025',
    reports: [
      EpisodeReport(id: 'r4', title: 'CBC Report', fileType: 'LAB'),
      EpisodeReport(id: 'r5', title: 'Urine Analysis', fileType: 'LAB'),
    ],
  ),
  // December 2024 — Direct Upload
  Episode(
    id: 'e3',
    doctorName: 'Thyroid Function Test',
    hospital: '',
    department: 'Direct Upload',
    date: 'Dec 10, 2024',
    month: 'December 2024',
    year: '2024',
    isDirect: true,
    reports: [
      EpisodeReport(
        id: 'r6',
        title: 'Thyroid Test Report',
        fileType: 'LAB',
        aiDepartment: 'Endocrinology',
      ),
    ],
  ),
  // September 2024 — Doctor Visit
  Episode(
    id: 'e4',
    doctorName: 'Dr. Suresh Nair',
    hospital: 'KIMS',
    department: 'Radiology',
    date: 'Sep 3, 2024',
    month: 'September 2024',
    year: '2024',
    reports: [
      EpisodeReport(id: 'r7', title: 'MRI Brain', fileType: 'SCAN'),
    ],
  ),
  // June 2024 — Direct Upload
  Episode(
    id: 'e5',
    doctorName: 'Annual Health Checkup',
    hospital: '',
    department: 'Direct Upload',
    date: 'Jun 10, 2024',
    month: 'June 2024',
    year: '2024',
    isDirect: true,
    reports: [
      EpisodeReport(
        id: 'r8',
        title: 'Annual Health Report',
        fileType: 'PDF',
        aiDepartment: 'General',
      ),
    ],
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  static const _blue     = Color(0xFF1565C0);
  static const _lightBg  = Color(0xFFF5F8FF);
  static const _darkText = Color(0xFF1A1A2E);

  final _searchController = TextEditingController();
  String _searchQuery     = '';
  String? _filterDept;    // null = all
  String? _filterYear;    // null = all
  String? _filterType;    // null = all (Doctor Visit / Direct Upload)

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtered episodes ────────────────────────────────────────────────────────
  List<Episode> get _filtered {
    return _sampleEpisodes.where((e) {
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          e.doctorName.toLowerCase().contains(q) ||
          e.hospital.toLowerCase().contains(q) ||
          e.department.toLowerCase().contains(q) ||
          e.reports.any((r) => r.title.toLowerCase().contains(q));
      final matchDept = _filterDept == null ||
          e.department == _filterDept ||
          e.reports.any((r) => r.aiDepartment == _filterDept);
      final matchYear = _filterYear == null || e.year == _filterYear;
      final matchType = _filterType == null ||
          (_filterType == 'Doctor Visit' && !e.isDirect) ||
          (_filterType == 'Direct Upload' && e.isDirect);
      return matchSearch && matchDept && matchYear && matchType;
    }).toList();
  }

  // ── All unique years from data ───────────────────────────────────────────────
  List<String> get _allYears {
    final y = _sampleEpisodes.map((e) => e.year).toSet().toList();
    y.sort((a, b) => b.compareTo(a));
    return y;
  }

  // ── All unique departments from data ────────────────────────────────────────
  List<String> get _allDepts {
    final d = <String>{};
    for (final e in _sampleEpisodes) {
      if (!e.isDirect) d.add(e.department);
      for (final r in e.reports) {
        if (r.aiDepartment.isNotEmpty) d.add(r.aiDepartment);
      }
    }
    final list = d.toList()..sort();
    return list;
  }

  // ── Group by month ───────────────────────────────────────────────────────────
  Map<String, List<Episode>> get _groupedByMonth {
    final map = <String, List<Episode>>{};
    for (final e in _filtered) {
      map.putIfAbsent(e.month, () => []).add(e);
    }
    return map;
  }

  // ── Total record count ───────────────────────────────────────────────────────
  int get _totalRecords {
    return _filtered.fold(0, (sum, e) => sum + e.reports.length);
  }

  bool get _hasActiveFilters =>
      _filterDept != null || _filterYear != null || _filterType != null;

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
            _buildToolbar(),
            Expanded(
              child: _filtered.isEmpty
                  ? _buildEmptyState()
                  : _buildTimeline(),
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
                        Text('My Records',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3)),
                        SizedBox(height: 4),
                        Text('Timeline · Newest first',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  // Total records badge
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
                          '$_totalRecords Records',
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
          hintText: 'Search records, doctors...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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

  // ── Toolbar (filter button) ──────────────────────────────────────────────────
  Widget _buildToolbar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            '${_filtered.length} episode${_filtered.length != 1 ? 's' : ''}',
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade500),
          ),
          const Spacer(),
          // Filter button
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _hasActiveFilters
                    ? const Color(0xFFE3F2FD)
                    : const Color(0xFFF5F8FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _hasActiveFilters
                      ? _blue
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded,
                      size: 14,
                      color: _hasActiveFilters ? _blue : Colors.grey),
                  const SizedBox(width: 6),
                  Text('Filter',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _hasActiveFilters ? _blue : _darkText)),
                  if (_hasActiveFilters) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: _blue,
                        shape: BoxShape.circle,
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

  // ── Timeline ─────────────────────────────────────────────────────────────────
  Widget _buildTimeline() {
    final grouped = _groupedByMonth;
    final months = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: months.length,
      itemBuilder: (context, index) {
        final month = months[index];
        final episodes = grouped[month]!;
        return _buildMonthSection(month, episodes);
      },
    );
  }

  // ── Month Section ────────────────────────────────────────────────────────────
  Widget _buildMonthSection(String month, List<Episode> episodes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month label
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Row(
            children: [
              Text(month,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500)),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 0.5,
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
        // Episodes under this month
        ...episodes.map((e) => _buildEpisodeCard(e)),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Episode Card ─────────────────────────────────────────────────────────────
  Widget _buildEpisodeCard(Episode episode) {
    final deptInfo = _getDeptInfo(episode.department);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.grey.withValues(alpha: 0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Episode Header ────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Department dot
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: deptInfo.lightColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(deptInfo.icon,
                        color: deptInfo.color, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor name or report title (for direct)
                      Text(
                        episode.isDirect
                            ? episode.doctorName
                            : episode.doctorName,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _darkText),
                      ),
                      const SizedBox(height: 2),
                      // Hospital and date
                      Text(
                        episode.isDirect
                            ? episode.date
                            : '${episode.hospital} · ${episode.date}',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 6),
                      // Department tag
                      episode.isDirect
                          ? Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: const Text('Direct Upload',
                                style: TextStyle(
                                    color: Color(0xFFF57F17),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      )
                          : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: deptInfo.lightColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(episode.department,
                            style: TextStyle(
                                color: deptInfo.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                // File count
                Text(
                  '${episode.reports.length} file${episode.reports.length != 1 ? 's' : ''}',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),

          // ── Reports List ──────────────────────────────────
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.12)),
              ),
            ),
            child: Column(
              children: episode.reports
                  .map((r) => _buildReportRow(r, episode.isDirect))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Report Row ───────────────────────────────────────────────────────────────
  Widget _buildReportRow(EpisodeReport report, bool isDirect) {
    final typeColor = _fileTypeColor(report.fileType);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: Colors.grey.withValues(alpha: 0.08), width: 1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // File type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: typeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(report.fileType,
                      style: TextStyle(
                          color: typeColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                // Report title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.title,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _darkText)),
                      // AI detected department for direct uploads
                      if (isDirect &&
                          report.aiDepartment.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.psychology_rounded,
                                size: 10, color: Color(0xFF2E7D32)),
                            const SizedBox(width: 3),
                            Text('AI: ${report.aiDepartment}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // AI Explain button
                GestureDetector(
                  onTap: () => _showAiExplain(report),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFA5D6A7), width: 0.8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.psychology_rounded,
                            size: 12, color: Color(0xFF2E7D32)),
                        SizedBox(width: 4),
                        Text('AI Explain',
                            style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── AI Explain Bottom Sheet ──────────────────────────────────────────────────
  void _showAiExplain(EpisodeReport report) {
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.psychology_rounded,
                      color: Color(0xFF2E7D32), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Report Explanation',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _darkText)),
                      Text(report.title,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 14, color: Color(0xFF1565C0)),
                      SizedBox(width: 6),
                      Text('Claude AI will explain this report',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'AI explanation will be available once Claude API is connected. It will explain your report in simple language and answer your questions.',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.psychology_rounded, size: 18),
                label: const Text('Coming Soon — Claude API',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter Sheet ─────────────────────────────────────────────────────────────
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Row(
                children: [
                  const Icon(Icons.tune_rounded,
                      color: _blue, size: 18),
                  const SizedBox(width: 8),
                  const Text('Filter Records',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _darkText)),
                  const Spacer(),
                  // Clear all
                  if (_hasActiveFilters)
                    GestureDetector(
                      onTap: () {
                        setSheetState(() {});
                        setState(() {
                          _filterDept = null;
                          _filterYear = null;
                          _filterType = null;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear all',
                          style: TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Type filter
              _filterSectionLabel('TYPE'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Doctor Visit', 'Direct Upload'].map((type) {
                  final isSelected = _filterType == type;
                  return GestureDetector(
                    onTap: () {
                      setSheetState(() {});
                      setState(() => _filterType =
                      _filterType == type ? null : type);
                    },
                    child: Container(
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
                      child: Text(type,
                          style: TextStyle(
                              color: isSelected ? Colors.white : _darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Department filter
              _filterSectionLabel('DEPARTMENT'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allDepts.map((dept) {
                  final isSelected = _filterDept == dept;
                  final info = _getDeptInfo(dept);
                  return GestureDetector(
                    onTap: () {
                      setSheetState(() {});
                      setState(() => _filterDept =
                      _filterDept == dept ? null : dept);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? info.color
                            : info.lightColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? info.color
                              : info.color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(dept,
                          style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : info.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Year filter
              _filterSectionLabel('YEAR'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allYears.map((year) {
                  final isSelected = _filterYear == year;
                  return GestureDetector(
                    onTap: () {
                      setSheetState(() {});
                      setState(() => _filterYear =
                      _filterYear == year ? null : year);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _blue
                            : const Color(0xFFF5F8FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? _blue
                              : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(year,
                          style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : _darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Apply Filters',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterSectionLabel(String label) {
    return Text(label,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.8));
  }

  // ── File type color ──────────────────────────────────────────────────────────
  Color _fileTypeColor(String type) {
    switch (type) {
      case 'PDF':  return const Color(0xFFE53935);
      case 'LAB':  return const Color(0xFF8E24AA);
      case 'SCAN': return const Color(0xFF1565C0);
      case 'IMG':  return const Color(0xFF2E7D32);
      default:     return const Color(0xFF546E7A);
    }
  }

  // ── Empty State ───────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.folder_off_rounded,
                color: _blue, size: 48),
          ),
          const SizedBox(height: 20),
          const Text('No records found',
              style: TextStyle(
                  color: _darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search query',
            style:
            TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
