import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String age;
  final String dob;
  final String phone;
  final String gender;
  final String bloodGroup;
  final String allergies;
  final String conditions;
  final String medications;
  final String surgeries;
  final String emergencyContactName;
  final String emergencyContactPhone;

  const ProfileScreen({
    super.key,
    this.userName = 'User',
    this.age = '—',
    this.dob = '—',
    this.phone = '—',
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
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _blue      = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF1E88E5);
  static const _lightBlue = Color(0xFFE3F2FD);
  static const _lightBg   = Color(0xFFF5F8FF);
  static const _darkText  = Color(0xFF1A1A2E);
  static const _red       = Color(0xFFD32F2F);

  List<String> _split(String value) {
    if (value.trim().isEmpty) return ['None recorded'];
    return value
        .split(RegExp(r'[,\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String get _initials {
    final parts = widget.userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildSection(
                  'Personal Information',
                  Icons.person_rounded,
                  _buildPersonalInfo(),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  'Medical Summary',
                  Icons.medical_information_rounded,
                  _buildMedicalSummary(),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  'Emergency Contact',
                  Icons.emergency_rounded,
                  _buildEmergencyContact(),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 60,
      pinned: true,
      elevation: 0,
      backgroundColor: _blue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'My Profile',
        style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded,
              color: Colors.white, size: 20),
          onPressed: () => _showComingSoon('Edit Profile'),
          tooltip: 'Edit Profile',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_blue, _blueLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  // ── Profile Header ───────────────────────────────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_blue, _blueLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.userName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _headerPill(Icons.cake_rounded, '${widget.age} yrs'),
              const SizedBox(width: 8),
              _headerPill(
                widget.gender.toLowerCase() == 'male'
                    ? Icons.male_rounded
                    : widget.gender.toLowerCase() == 'female'
                    ? Icons.female_rounded
                    : Icons.person_rounded,
                widget.gender,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bloodtype_rounded,
                        color: Colors.white, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      widget.bloodGroup,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ── Section wrapper ──────────────────────────────────────────────────────────
  Widget _buildSection(String title, IconData icon, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: _lightBlue,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: _blue, size: 15),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                    color: _darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
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
            child: content,
          ),
        ],
      ),
    );
  }

  // ── 1. Personal Information ──────────────────────────────────────────────────
  Widget _buildPersonalInfo() {
    return Column(
      children: [
        _infoTile(Icons.person_rounded, 'Full Name', widget.userName),
        _divider(),
        _infoTile(Icons.cake_rounded, 'Date of Birth', widget.dob),
        _divider(),
        _infoTile(Icons.calendar_today_rounded, 'Age', '${widget.age} years'),
        _divider(),
        _infoTile(Icons.people_rounded, 'Gender', widget.gender),
        _divider(),
        _infoTile(Icons.bloodtype_rounded, 'Blood Group', widget.bloodGroup),
        _divider(),
        _infoTile(Icons.phone_rounded, 'Phone Number',
            widget.phone.isNotEmpty ? '+91 ${widget.phone}' : '—'),
      ],
    );
  }

  // ── 2. Medical Summary ───────────────────────────────────────────────────────
  Widget _buildMedicalSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 4),
          child: Row(
            children: [
              const Text(
                'Health Overview',
                style: TextStyle(
                    color: _darkText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showComingSoon('Edit Medical Summary'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.edit_rounded,
                    size: 13, color: _blue),
                label: const Text('Edit',
                    style: TextStyle(color: _blue, fontSize: 13)),
              ),
            ],
          ),
        ),
        _divider(),
        _medicalRow(
          Icons.warning_amber_rounded,
          'Allergies',
          _split(widget.allergies),
          const Color(0xFFE53935),
          const Color(0xFFFFEBEE),
        ),
        _divider(),
        _medicalRow(
          Icons.monitor_heart_rounded,
          'Chronic Conditions',
          _split(widget.conditions),
          const Color(0xFF1565C0),
          const Color(0xFFE3F2FD),
        ),
        _divider(),
        _medicalRow(
          Icons.medication_rounded,
          'Current Medications',
          _split(widget.medications),
          const Color(0xFF2E7D32),
          const Color(0xFFE8F5E9),
        ),
        _divider(),
        _medicalRow(
          Icons.local_hospital_rounded,
          'Past Surgeries',
          _split(widget.surgeries),
          const Color(0xFF8E24AA),
          const Color(0xFFF3E5F5),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _medicalRow(
      IconData icon,
      String label,
      List<String> items,
      Color color,
      Color bg,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: items.map((item) {
                    final isNone = item == 'None recorded';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isNone ? Colors.grey.shade100 : bg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isNone
                              ? Colors.grey.shade200
                              : color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                            color: isNone
                                ? Colors.grey.shade400
                                : color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Emergency Contact ─────────────────────────────────────────────────────
  Widget _buildEmergencyContact() {
    final hasName  = widget.emergencyContactName.trim().isNotEmpty;
    final hasPhone = widget.emergencyContactPhone.trim().isNotEmpty;

    return Column(
      children: [
        _infoTile(
          Icons.person_rounded,
          'Contact Name',
          hasName ? widget.emergencyContactName : 'Not provided',
        ),
        _divider(),
        _infoTile(
          Icons.phone_rounded,
          'Phone Number',
          hasPhone ? widget.emergencyContactPhone : 'Not provided',
          trailing: hasPhone
              ? Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Call',
              style: TextStyle(
                  color: _red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          )
              : null,
        ),
        _divider(),
        // ── Edit Emergency Info button only ──────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showComingSoon('Edit Emergency Info'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                side: const BorderSide(color: _blue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text(
                'Edit Emergency Info',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Reusable Tiles ───────────────────────────────────────────────────────────
  Widget _infoTile(
      IconData icon,
      String label,
      String value, {
        Widget? trailing,
      }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: _lightBlue,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: _blue, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                      color: _darkText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    thickness: 1,
    color: Colors.grey.withValues(alpha: 0.1),
    indent: 16,
    endIndent: 16,
  );

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.construction_rounded,
                color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('$feature — Coming soon!'),
          ],
        ),
        backgroundColor: _blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }
}
