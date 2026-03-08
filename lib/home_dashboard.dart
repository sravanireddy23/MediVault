import 'package:flutter/material.dart';
import 'emergency_info_screen.dart';
import 'medical_records_screen.dart';
import 'upload_record_screen.dart';

class HomeDashboard extends StatefulWidget {
  final String userName;
  final String age;
  final String gender;
  final String bloodGroup;
  final String allergies;
  final String conditions;
  final String medications;
  final String surgeries;
  final String emergencyContactName;
  final String emergencyContactPhone;

  const HomeDashboard({
    super.key,
    this.userName = 'User',
    this.age = '—',
    this.gender = '—',
    this.bloodGroup = '—',
    this.allergies = '',
    this.conditions = '',
    this.medications = '',
    this.surgeries = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
  });

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedIndex = 0;

  static const _blue      = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF1E88E5);
  static const _lightBlue = Color(0xFFE3F2FD);
  static const _darkText  = Color(0xFF1A1A2E);

  final List<Map<String, dynamic>> _quickStats = [
    {'label': 'Records',  'value': '24', 'icon': Icons.folder_copy_rounded},
    {'label': 'Doctors',  'value': '3',  'icon': Icons.medical_services_rounded},
    {'label': 'Upcoming', 'value': '1',  'icon': Icons.calendar_today_rounded},
  ];

  final List<Map<String, dynamic>> _recentlyOpened = [
    {
      'title': 'Blood Test Report',
      'department': 'Pathology',
      'date': 'Mar 2, 2025',
      'icon': Icons.science_rounded,
      'color': Color(0xFF8E24AA),
      'fileType': 'LAB',
    },
    {
      'title': 'Chest X-Ray',
      'department': 'Radiology',
      'date': 'Feb 14, 2025',
      'icon': Icons.image_search_rounded,
      'color': Color(0xFF1565C0),
      'fileType': 'SCAN',
    },
    {
      'title': 'ECG Report',
      'department': 'Cardiology',
      'date': 'Jan 28, 2025',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFFE53935),
      'fileType': 'PDF',
    },
  ];

  final List<Map<String, dynamic>> _recentlyUploaded = [
    {
      'title': 'Knee X-Ray',
      'department': 'Orthopedics',
      'date': 'Jan 30, 2025',
      'icon': Icons.accessibility_new_rounded,
      'color': Color(0xFFEF6C00),
      'fileType': 'SCAN',
    },
    {
      'title': 'Thyroid Function Test',
      'department': 'Endocrinology',
      'date': 'Mar 1, 2025',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF00838F),
      'fileType': 'LAB',
    },
    {
      'title': 'MRI Brain',
      'department': 'Neurology',
      'date': 'Feb 28, 2025',
      'icon': Icons.psychology_rounded,
      'color': Color(0xFF00897B),
      'fileType': 'SCAN',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _slideController, curve: Curves.easeOutCubic));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _openEmergencyInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmergencyInfoScreen(
          name: widget.userName,
          age: widget.age,
          gender: widget.gender,
          bloodGroup: widget.bloodGroup,
          allergies: widget.allergies,
          conditions: widget.conditions,
          medications: widget.medications,
          surgeries: widget.surgeries,
          emergencyContactName: widget.emergencyContactName,
          emergencyContactPhone: widget.emergencyContactPhone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEmergencyBanner(),
                    _buildQuickStats(),
                    _buildQuickAccess(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: _blue,
      automaticallyImplyLeading: false,
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hello, ${widget.userName} 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your health records, all in one place',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bloodtype_rounded,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(widget.bloodGroup,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2),
                        ),
                        child: Center(
                          child: Text(
                            widget.userName.isNotEmpty
                                ? widget.userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Emergency Banner ─────────────────────────────────────────────────────────
  Widget _buildEmergencyBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: GestureDetector(
        onTap: _openEmergencyInfo,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD32F2F), Color(0xFFE53935)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD32F2F).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emergency_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emergency Info',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    SizedBox(height: 2),
                    Text('Accessible without login · Tap to view',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white70, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Quick Stats ──────────────────────────────────────────────────────────────
  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: List.generate(_quickStats.length, (index) {
          final stat = _quickStats[index];
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  right: index < _quickStats.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(stat['icon'] as IconData, color: _blue, size: 22),
                  const SizedBox(height: 8),
                  Text(stat['value'] as String,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _darkText)),
                  const SizedBox(height: 3),
                  Text(stat['label'] as String,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Quick Access ─────────────────────────────────────────────────────────────
  Widget _buildQuickAccess() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Access',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _darkText)),
          const SizedBox(height: 20),

          // 1. Recently Opened
          _buildQuickSection(
            title: 'Recently Opened',
            icon: Icons.history_rounded,
            iconColor: _blue,
            bgColor: _lightBlue,
            records: _recentlyOpened,
            onSeeAll: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MedicalRecordsScreen())),
          ),

          const SizedBox(height: 24),

          // 2. Recently Uploaded
          _buildQuickSection(
            title: 'Recently Uploaded',
            icon: Icons.cloud_done_rounded,
            iconColor: const Color(0xFF1976D2),
            bgColor: const Color(0xFFE8F4FD),
            records: _recentlyUploaded,
            onSeeAll: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const UploadRecordScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required List<Map<String, dynamic>> records,
    required VoidCallback onSeeAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(
                    color: _darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: onSeeAll,
              child: Text('See all',
                  style: TextStyle(
                      color: iconColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: records.length,
            itemBuilder: (context, index) =>
                _buildRecordCard(records[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> r) {
    final color    = r['color'] as Color;
    final fileType = r['fileType'] as String;

    Color ftColor;
    switch (fileType) {
      case 'PDF':  ftColor = const Color(0xFFE53935); break;
      case 'LAB':  ftColor = const Color(0xFF8E24AA); break;
      case 'SCAN': ftColor = _blue;                   break;
      default:     ftColor = const Color(0xFF2E7D32); break;
    }

    return GestureDetector(
      onTap: () => _showRecordDetail(r),
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: color, width: 3.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(r['icon'] as IconData, color: color, size: 16),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: ftColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: ftColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(fileType,
                      style: TextStyle(
                          color: ftColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['title'] as String,
                    style: const TextStyle(
                        color: _darkText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(r['department'] as String,
                    style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(r['date'] as String,
                    style:
                    const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Record Detail Bottom Sheet ───────────────────────────────────────────────
  void _showRecordDetail(Map<String, dynamic> r) {
    final color    = r['color'] as Color;
    final fileType = r['fileType'] as String;

    Color ftColor;
    switch (fileType) {
      case 'PDF':  ftColor = const Color(0xFFE53935); break;
      case 'LAB':  ftColor = const Color(0xFF8E24AA); break;
      case 'SCAN': ftColor = _blue;                   break;
      default:     ftColor = const Color(0xFF2E7D32); break;
    }

    IconData ftIcon;
    switch (fileType) {
      case 'PDF':  ftIcon = Icons.picture_as_pdf_rounded;  break;
      case 'LAB':  ftIcon = Icons.biotech_rounded;          break;
      case 'SCAN': ftIcon = Icons.document_scanner_rounded; break;
      default:     ftIcon = Icons.image_rounded;            break;
    }

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
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),

            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(r['icon'] as IconData, color: color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r['title'] as String,
                          style: const TextStyle(
                              color: _darkText,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(r['department'] as String,
                          style: TextStyle(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: ftColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ftColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(fileType,
                      style: TextStyle(
                          color: ftColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Details card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _detailRow(Icons.calendar_today_rounded,
                      'Date', r['date'] as String),
                  const SizedBox(height: 14),
                  _detailRow(Icons.local_hospital_rounded,
                      'Department', r['department'] as String),
                  const SizedBox(height: 14),
                  _detailRow(ftIcon, 'Record Type', fileType),
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
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MedicalRecordsScreen()),
                      );
                    },
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
                    color: _darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 10,
      color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_rounded, 'Home', onTap: () {}),
            _navItem(1, Icons.folder_copy_rounded, 'Records',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MedicalRecordsScreen()),
                ).then((_) => setState(() => _selectedIndex = 0))),
            const SizedBox(width: 48), // FAB gap
            _navItem(2, Icons.people_alt_rounded, 'Doctors', onTap: () {}),
            _navItem(3, Icons.person_rounded, 'Profile', onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label,
      {required VoidCallback onTap}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isSelected ? _blue : Colors.grey, size: 22),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? _blue : Colors.grey,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal)),
        ],
      ),
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const UploadRecordScreen())),
      backgroundColor: _blue,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    );
  }
}