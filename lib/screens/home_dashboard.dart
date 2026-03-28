import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'emergency_info_screen.dart';
import 'medical_records_screen.dart';
import 'upload_record_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'ai_chat_screen.dart';
import '../services/news_service.dart';

class HomeDashboard extends StatefulWidget {
  final String userName;
  final String userEmail;   // ← NEW
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
    this.userName  = 'User',
    this.userEmail = '',    // ← NEW
    this.age       = '—',
    this.gender    = '—',
    this.bloodGroup = '—',
    this.allergies  = '',
    this.conditions = '',
    this.medications = '',
    this.surgeries   = '',
    this.emergencyContactName  = '',
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

  // ── Firestore data ────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _recentRecords = [];
  int _totalRecords      = 0;
  int _thisMonthUploads  = 0;
  int _doctorsVisited    = 0;
  bool _isLoadingRecords = true;

  // ── News data ─────────────────────────────────────────────────────────────
  List<NewsArticle> _articles  = [];
  bool _isLoadingNews          = true;
  bool _isLoadingMore          = false;
  bool _hasMoreNews            = true;
  String? _newsError;
  int _newsPage                = 1;
  static const int _pageSize   = 5;

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
    _fetchDashboardData();
    _fetchNews();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ── Fetch Firestore records ───────────────────────────────────────────────
  Future<void> _fetchDashboardData() async {
    setState(() => _isLoadingRecords = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) { setState(() => _isLoadingRecords = false); return; }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('records')
          .orderBy('uploadedAt', descending: true)
          .get();

      final docs = snapshot.docs;
      final now  = DateTime.now();
      int thisMonthCount = 0;
      final Set<String> uniqueDoctors = {};
      final List<Map<String, dynamic>> recent = [];

      for (final doc in docs) {
        final data       = doc.data();
        final uploadedAt = data['uploadedAt'];
        final uploadType = data['uploadType'] ?? 'direct_upload';
        final fileName   = data['fileName'] ?? '';
        final department = data['department'] ?? 'Pending AI Detection';

        if (uploadedAt is Timestamp) {
          final dt = uploadedAt.toDate();
          if (dt.month == now.month && dt.year == now.year) thisMonthCount++;
        }

        if (uploadType != 'direct_upload') {
          final doctor = data['doctor'] ?? '';
          if (doctor.isNotEmpty) uniqueDoctors.add(doctor);
        }

        if (recent.length < 4) {
          final deptInfo = _getDeptInfoForDashboard(department, uploadType);
          recent.add({
            'title':      data['title'] ?? fileName,
            'department': uploadType == 'direct_upload' ? 'Direct Upload' : department,
            'date':       _formatDate(uploadedAt),
            'icon':       deptInfo['icon'],
            'color':      deptInfo['color'],
            'fileType':   _getFileType(fileName),
            'isDirect':   uploadType == 'direct_upload',
            'fileUrl':    data['fileUrl'] ?? '',
          });
        }
      }

      setState(() {
        _recentRecords    = recent;
        _totalRecords     = docs.length;
        _thisMonthUploads = thisMonthCount;
        _doctorsVisited   = uniqueDoctors.length;
        _isLoadingRecords = false;
      });
    } catch (_) {
      setState(() => _isLoadingRecords = false);
    }
  }

  // ── Fetch news ────────────────────────────────────────────────────────────
  Future<void> _fetchNews({bool isRefresh = false}) async {
    setState(() {
      if (isRefresh) { _newsPage = 1; _articles = []; _hasMoreNews = true; }
      _isLoadingNews = true;
      _newsError     = null;
    });
    try {
      final articles = await NewsService.fetchHealthNews(
          pageSize: _pageSize, page: 1);
      setState(() {
        _articles      = articles;
        _isLoadingNews = false;
        _newsPage      = 2;
        _hasMoreNews   = articles.length >= _pageSize;
      });
    } catch (_) {
      setState(() {
        _newsError     = 'Could not load news. Tap refresh to try again.';
        _isLoadingNews = false;
      });
    }
  }

  // ── Load more news ────────────────────────────────────────────────────────
  Future<void> _loadMoreNews() async {
    if (_isLoadingMore || !_hasMoreNews) return;
    setState(() => _isLoadingMore = true);
    try {
      final more = await NewsService.fetchHealthNews(
          pageSize: _pageSize, page: _newsPage);
      setState(() {
        _articles.addAll(more);
        _newsPage++;
        _hasMoreNews   = more.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() => _isLoadingMore = false);
    }
  }

  // ── Open article ──────────────────────────────────────────────────────────
  Future<void> _openArticle(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Could not open article'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(12),
        ));
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Map<String, dynamic> _getDeptInfoForDashboard(
      String department, String uploadType) {
    if (uploadType == 'direct_upload') {
      return {'icon': Icons.upload_file_rounded, 'color': const Color(0xFFF57F17)};
    }
    const map = {
      'Cardiology':      {'icon': Icons.favorite_rounded,           'color': Color(0xFFE53935)},
      'Pathology':       {'icon': Icons.science_rounded,            'color': Color(0xFF8E24AA)},
      'Radiology':       {'icon': Icons.image_search_rounded,       'color': Color(0xFF1565C0)},
      'Neurology':       {'icon': Icons.psychology_rounded,         'color': Color(0xFF00897B)},
      'Orthopedics':     {'icon': Icons.accessibility_new_rounded,  'color': Color(0xFFEF6C00)},
      'Endocrinology':   {'icon': Icons.water_drop_rounded,         'color': Color(0xFF00838F)},
      'Gastroenterology':{'icon': Icons.medical_services_rounded,   'color': Color(0xFF2E7D32)},
      'Pulmonology':     {'icon': Icons.air_rounded,                'color': Color(0xFF1976D2)},
    };
    return map[department] ??
        {'icon': Icons.local_hospital_rounded, 'color': const Color(0xFF546E7A)};
  }

  String _getFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (ext == 'pdf') return 'PDF';
    if (['jpg', 'jpeg', 'png'].contains(ext)) return 'IMG';
    return 'PDF';
  }

  String _formatDate(dynamic uploadedAt) {
    DateTime dt;
    if (uploadedAt is Timestamp) {
      dt = uploadedAt.toDate();
    } else {
      dt = DateTime.now();
    }
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  void _openEmergencyInfo() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => EmergencyInfoScreen(
        name: widget.userName, age: widget.age, gender: widget.gender,
        bloodGroup: widget.bloodGroup, allergies: widget.allergies,
        conditions: widget.conditions, medications: widget.medications,
        surgeries: widget.surgeries,
        emergencyContactName: widget.emergencyContactName,
        emergencyContactPhone: widget.emergencyContactPhone,
      ),
    ));
  }

  // ── Settings — now passes userEmail ──────────────────────────────────────
  void _openSettings() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => SettingsScreen(
        userName:  widget.userName,
        userEmail: widget.userEmail,   // ← FIXED
      ),
    ));
  }

  String get _currentMonth {
    const months = ['January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    return months[DateTime.now().month - 1];
  }

  // ── Build ─────────────────────────────────────────────────────────────────
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

  // ── App Bar ───────────────────────────────────────────────────────────────
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
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Hello, ${widget.userName} 👋',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3),
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        const Text(
                            'Your health records, all in one place',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13,
                                fontWeight: FontWeight.w300)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bloodtype_rounded,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(widget.bloodGroup,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _openSettings,
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.settings_rounded,
                                color: Colors.white, size: 20),
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

  // ── Emergency Banner ──────────────────────────────────────────────────────
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
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFD32F2F).withValues(alpha: 0.35),
                  blurRadius: 12, offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle),
                child: const Icon(Icons.emergency_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emergency Info',
                        style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold, fontSize: 15)),
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

  // ── Monthly Activity Card ─────────────────────────────────────────────────
  Widget _buildMonthlyActivityCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8, offset: const Offset(0, 3)),
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
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.bar_chart_rounded,
                      color: _blue, size: 16),
                ),
                const SizedBox(width: 10),
                Text('$_currentMonth Activity',
                    style: const TextStyle(color: _darkText,
                        fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('This Month',
                      style: TextStyle(color: Color(0xFF2E7D32),
                          fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoadingRecords
                ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(
                      color: _blue, strokeWidth: 2),
                ))
                : Row(
              children: [
                _activityStat(
                    icon: Icons.upload_file_rounded,
                    iconColor: _blue,
                    iconBg: const Color(0xFFE3F2FD),
                    value: '$_thisMonthUploads',
                    label: 'Uploads'),
                _verticalDivider(),
                _activityStat(
                    icon: Icons.person_rounded,
                    iconColor: const Color(0xFF2E7D32),
                    iconBg: const Color(0xFFE8F5E9),
                    value: '$_doctorsVisited',
                    label: 'Doctors'),
                _verticalDivider(),
                _activityStat(
                    icon: Icons.folder_copy_rounded,
                    iconColor: const Color(0xFF8E24AA),
                    iconBg: const Color(0xFFF3E5F5),
                    value: '$_totalRecords',
                    label: 'Total Records'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityStat({required IconData icon, required Color iconColor,
    required Color iconBg, required String value, required String label}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: _darkText)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(
      height: 50, width: 1,
      color: Colors.grey.withValues(alpha: 0.15));

  // ── Recent Records ────────────────────────────────────────────────────────
  Widget _buildRecentRecords() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Recent Records',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: _darkText)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const MedicalRecordsScreen())),
                child: const Text('See all',
                    style: TextStyle(color: _blue, fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingRecords)
            const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator(
                    color: _blue, strokeWidth: 2)))
          else if (_recentRecords.isEmpty)
            _buildNoRecordsPlaceholder()
          else
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

  Widget _buildNoRecordsPlaceholder() {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const UploadRecordScreen()))
          .then((_) => _fetchDashboardData()),
      child: Container(
        height: 140, width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _blue.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: _blue, size: 32),
            SizedBox(height: 8),
            Text('Upload your first record',
                style: TextStyle(color: _blue, fontSize: 13,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Tap to get started',
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> r) {
    final color    = r['color'] as Color;
    final fileType = r['fileType'] as String;
    final isDirect = r['isDirect'] as bool;
    Color ftColor;
    switch (fileType) {
      case 'PDF': ftColor = const Color(0xFFE53935); break;
      case 'IMG': ftColor = const Color(0xFF2E7D32); break;
      default:    ftColor = _blue;
    }
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const MedicalRecordsScreen()))
          .then((_) => _fetchDashboardData()),
      child: Container(
        width: 150, margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: color, width: 3.5)),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8, offset: const Offset(0, 3))],
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
                      borderRadius: BorderRadius.circular(8)),
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
                      style: TextStyle(color: ftColor,
                          fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['title'] as String,
                    style: const TextStyle(color: _darkText, fontSize: 11,
                        fontWeight: FontWeight.bold),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                isDirect
                    ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(4)),
                    child: const Text('Direct',
                        style: TextStyle(color: Color(0xFFF57F17),
                            fontSize: 9, fontWeight: FontWeight.w600)))
                    : Text(r['department'] as String,
                    style: TextStyle(color: color, fontSize: 9,
                        fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
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

  // ── Health News ───────────────────────────────────────────────────────────
  Widget _buildHealthNews() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Health News',
                  style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.bold, color: _darkText)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('Live',
                    style: TextStyle(color: _blue,
                        fontSize: 10, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _fetchNews(isRefresh: true),
                child: Container(
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
                          style: TextStyle(color: Colors.grey,
                              fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingNews)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(
                    color: _blue, strokeWidth: 2),
              ),
            )
          else if (_newsError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      color: Colors.grey, size: 36),
                  const SizedBox(height: 10),
                  Text(_newsError!,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _fetchNews(isRefresh: true),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            )
          else if (_articles.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No health news available right now.',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              )
            else ...[
                ..._articles.map((article) => _buildArticleCard(article)),
                if (_hasMoreNews)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: _isLoadingMore
                          ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(
                                color: _blue, strokeWidth: 2),
                          ))
                          : OutlinedButton.icon(
                        onPressed: _loadMoreNews,
                        icon: const Icon(Icons.expand_more_rounded,
                            size: 18, color: _blue),
                        label: const Text('Load More',
                            style: TextStyle(color: _blue,
                                fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: _blue, width: 1.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                        ),
                      ),
                    ),
                  ),
                if (!_hasMoreNews && _articles.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text("You're all caught up! ✅",
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ),
                  ),
              ],
        ],
      ),
    );
  }

  Widget _buildArticleCard(NewsArticle article) {
    return GestureDetector(
      onTap: () => _openArticle(article.url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                child: Icon(Icons.health_and_safety_rounded,
                    color: _blue, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title,
                      style: const TextStyle(color: _darkText,
                          fontSize: 13, fontWeight: FontWeight.w600,
                          height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Text(article.source,
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (article.publishedAt.isNotEmpty) ...[
                        Text(' · ',
                            style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 11)),
                        Text(article.publishedAt,
                            style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 11)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.open_in_new_rounded,
                size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8, elevation: 10, color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_rounded, 'Home', onTap: () {}),
            _navItem(1, Icons.folder_copy_rounded, 'Records',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const MedicalRecordsScreen()))
                    .then((_) => setState(() => _selectedIndex = 0))),
            const SizedBox(width: 48),
            _navItem(2, Icons.psychology_rounded, 'AI Chat',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const AiChatScreen()))
                    .then((_) => setState(() => _selectedIndex = 0))),
            _navItem(3, Icons.person_rounded, 'Profile',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const ProfileScreen()))
                    .then((_) => setState(() => _selectedIndex = 0))),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label,
      {required VoidCallback onTap}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () { setState(() => _selectedIndex = index); onTap(); },
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

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const UploadRecordScreen()))
          .then((_) => _fetchDashboardData()),
      backgroundColor: _blue, elevation: 4, shape: const CircleBorder(),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    );
  }
}