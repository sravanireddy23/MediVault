import 'package:flutter/material.dart';
import 'emergency_info_screen.dart';
import 'medical_records_screen.dart';
import 'upload_record_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'ai_chat_screen.dart';

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
  static const _darkText  = Color(0xFF1A1A2E);

  // ── Recent records (newest first) ────────────────────────────────────────────
  final List<Map<String, dynamic>> _recentRecords = [
    {
      'title': 'ECG Report',
      'department': 'Cardiology',
      'date': 'Mar 2, 2025',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFFE53935),
      'fileType': 'PDF',
      'isDirect': false,
    },
    {
      'title': 'Blood Test CBC',
      'department': 'Pathology',
      'date': 'Jan 5, 2025',
      'icon': Icons.science_rounded,
      'color': Color(0xFF8E24AA),
      'fileType': 'LAB',
      'isDirect': false,
    },
    {
      'title': 'Thyroid Test',
      'department': 'Direct Upload',
      'date': 'Dec 10, 2024',
      'icon': Icons.upload_file_rounded,
      'color': Color(0xFFF57F17),
      'fileType': 'LAB',
      'isDirect': true,
    },
    {
      'title': 'MRI Brain',
      'department': 'Radiology',
      'date': 'Sep 3, 2024',
      'icon': Icons.image_search_rounded,
      'color': Color(0xFF1565C0),
      'fileType': 'SCAN',
      'isDirect': false,
    },
  ];

  // ── Static health news ───────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _healthArticles = [
    {
      'title': 'Walking 10,000 Steps Daily Reduces Heart Disease Risk by 30%',
      'source': 'Health Today',
      'category': 'Cardiology',
      'readTime': '3 min read',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFFE53935),
      'lightColor': Color(0xFFFFEBEE),
    },
    {
      'title': 'New WHO Guidelines for Managing Type 2 Diabetes in 2025',
      'source': 'Medical News',
      'category': 'Endocrinology',
      'readTime': '4 min read',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF00838F),
      'lightColor': Color(0xFFE0F7FA),
    },
    {
      'title': 'Understanding Your CBC Blood Test: What Every Number Means',
      'source': 'Healthline',
      'category': 'Pathology',
      'readTime': '5 min read',
      'icon': Icons.science_rounded,
      'color': Color(0xFF8E24AA),
      'lightColor': Color(0xFFF3E5F5),
    },
    {
      'title': 'How Sleep Quality Directly Impacts Your Immune System',
      'source': 'WebMD',
      'category': 'General Health',
      'readTime': '3 min read',
      'icon': Icons.nightlight_rounded,
      'color': Color(0xFF1565C0),
      'lightColor': Color(0xFFE3F2FD),
    },
    {
      'title': 'Early Signs of Hypertension You Should Never Ignore',
      'source': 'Mayo Clinic',
      'category': 'Cardiology',
      'readTime': '4 min read',
      'icon': Icons.monitor_heart_rounded,
      'color': Color(0xFFE53935),
      'lightColor': Color(0xFFFFEBEE),
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

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(userName: widget.userName),
      ),
    );
  }

  String get _currentMonth {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    return months[DateTime.now().month - 1];
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
                    _buildMonthlyActivityCard(),
                    _buildRecentRecords(),
                    _buildHealthNews(),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 12),
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
                            Text(
                              widget.bloodGroup,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _openSettings,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 2),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.settings_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
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
          padding: const EdgeInsets.symmetric(
              horizontal: 18, vertical: 14),
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
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12)),
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

  // ── Monthly Activity Card ────────────────────────────────────────────────────
  Widget _buildMonthlyActivityCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bar_chart_rounded,
                      color: _blue, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  '$_currentMonth Activity',
                  style: const TextStyle(
                      color: _darkText,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'This Month',
                    style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _activityStat(
                  icon: Icons.upload_file_rounded,
                  iconColor: _blue,
                  iconBg: const Color(0xFFE3F2FD),
                  value: '2',
                  label: 'Uploads',
                ),
                _verticalDivider(),
                _activityStat(
                  icon: Icons.psychology_rounded,
                  iconColor: const Color(0xFF2E7D32),
                  iconBg: const Color(0xFFE8F5E9),
                  value: '3',
                  label: 'AI Chats',
                ),
                _verticalDivider(),
                _activityStat(
                  icon: Icons.folder_copy_rounded,
                  iconColor: const Color(0xFF8E24AA),
                  iconBg: const Color(0xFFF3E5F5),
                  value: '6',
                  label: 'Total Records',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityStat({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _darkText),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.15),
    );
  }

  // ── Recent Records ───────────────────────────────────────────────────────────
  Widget _buildRecentRecords() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Recent Records',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _darkText),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MedicalRecordsScreen())),
                child: const Text(
                  'See all',
                  style: TextStyle(
                      color: _blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _recentRecords.length,
              itemBuilder: (context, index) =>
                  _buildRecordCard(_recentRecords[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> r) {
    final color    = r['color'] as Color;
    final fileType = r['fileType'] as String;
    final isDirect = r['isDirect'] as bool;

    Color ftColor;
    switch (fileType) {
      case 'PDF':  ftColor = const Color(0xFFE53935); break;
      case 'LAB':  ftColor = const Color(0xFF8E24AA); break;
      case 'SCAN': ftColor = _blue;                   break;
      default:     ftColor = const Color(0xFF2E7D32); break;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const MedicalRecordsScreen())),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
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
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(r['icon'] as IconData,
                      color: color, size: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: ftColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: ftColor.withValues(alpha: 0.35)),
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
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                isDirect
                    ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Direct',
                      style: TextStyle(
                          color: Color(0xFFF57F17),
                          fontSize: 9,
                          fontWeight: FontWeight.w600)),
                )
                    : Text(r['department'] as String,
                    style: TextStyle(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(r['date'] as String,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 9)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Health News ──────────────────────────────────────────────────────────────
  Widget _buildHealthNews() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Health News',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _darkText),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Today',
                  style: TextStyle(
                      color: _blue,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.refresh_rounded,
                        size: 12, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Refresh',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._healthArticles.map((article) => _buildArticleCard(article)),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    final color      = article['color'] as Color;
    final lightColor = article['lightColor'] as Color;

    return GestureDetector(
      onTap: _showComingSoon,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(article['icon'] as IconData,
                    color: color, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['title'] as String,
                    style: const TextStyle(
                        color: _darkText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: lightColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article['category'] as String,
                          style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        article['source'] as String,
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 10),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time_rounded,
                          size: 10, color: Colors.grey.shade400),
                      const SizedBox(width: 3),
                      Text(
                        article['readTime'] as String,
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.newspaper_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Full article — Coming soon with NewsAPI!'),
          ],
        ),
        backgroundColor: _blue,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
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
            const SizedBox(width: 48),
            _navItem(2, Icons.psychology_rounded, 'AI Chat',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AiChatScreen()),
                ).then((_) => setState(() => _selectedIndex = 0))),
            _navItem(3, Icons.person_rounded, 'Profile',
                onTap: () => Navigator.push(
                  context,
                  // ✅ FIXED: ProfileScreen now takes no params
                  // it fetches data directly from Firestore
                  MaterialPageRoute(
                      builder: (_) => const ProfileScreen()),
                ).then((_) => setState(() => _selectedIndex = 0))),
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
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UploadRecordScreen())),
      backgroundColor: _blue,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    );
  }
}