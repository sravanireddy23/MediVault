import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
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
  final String dob;
  final String phone;

  const ProfileScreen({
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
    this.dob = '—',
    this.phone = '—',
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

  // ── Sample doctors with access ───────────────────────────────────────────────
  final List<Map<String, dynamic>> _doctorsWithAccess = [
    {
      'name': 'Dr. Raghav Menon',
      'specialty': 'Cardiology',
      'hospital': 'Apollo Hospital',
      'since': 'Mar 1, 2025',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFFE53935),
    },
    {
      'name': 'Dr. Priya Sharma',
      'specialty': 'Pathology',
      'hospital': 'Medanta',
      'since': 'Feb 10, 2025',
      'icon': Icons.science_rounded,
      'color': Color(0xFF8E24AA),
    },
  ];

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
                _buildSection('Personal Information', Icons.person_rounded,
                    _buildPersonalInfo()),
                const SizedBox(height: 16),
                _buildSection('Medical Summary', Icons.medical_information_rounded,
                    _buildMedicalSummary()),
                const SizedBox(height: 16),
                _buildSection('Emergency Contact', Icons.emergency_rounded,
                    _buildEmergencyContact()),
                const SizedBox(height: 16),
                _buildSection('Doctor Access', Icons.people_alt_rounded,
                    _buildDoctorAccess()),
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
      title: const Text('My Profile',
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
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
              child: Text(_initials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 14),
          Text(widget.userName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
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
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                    Text(widget.bloodGroup,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
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
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
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
              Text(title,
                  style: const TextStyle(
                      color: _darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
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
        _infoTile(Icons.cake_rounded, 'Date of Birth', widget.dob),
        _divider(),
        _infoTile(Icons.phone_rounded, 'Phone Number', widget.phone),
        _divider(),
        _infoTile(Icons.email_rounded, 'Email', 'Not provided',
            trailing: TextButton(
              onPressed: () {},
              child: const Text('Add',
                  style: TextStyle(color: _blue, fontSize: 13)),
            )),
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
              const Text('Health Overview',
                  style: TextStyle(
                      color: _darkText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showComingSoon('Edit Medical Summary'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.edit_rounded, size: 13, color: _blue),
                label: const Text('Edit',
                    style: TextStyle(color: _blue, fontSize: 13)),
              ),
            ],
          ),
        ),
        _divider(),
        _medicalRow(Icons.warning_amber_rounded, 'Allergies',
            _split(widget.allergies), const Color(0xFFE53935),
            const Color(0xFFFFEBEE)),
        _divider(),
        _medicalRow(Icons.monitor_heart_rounded, 'Chronic Conditions',
            _split(widget.conditions), const Color(0xFF1565C0),
            const Color(0xFFE3F2FD)),
        _divider(),
        _medicalRow(Icons.medication_rounded, 'Current Medications',
            _split(widget.medications), const Color(0xFF2E7D32),
            const Color(0xFFE8F5E9)),
        _divider(),
        _medicalRow(Icons.local_hospital_rounded, 'Past Surgeries',
            _split(widget.surgeries), const Color(0xFF8E24AA),
            const Color(0xFFF3E5F5)),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _medicalRow(IconData icon, String label, List<String> items,
      Color color, Color bg) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
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
                      child: Text(item,
                          style: TextStyle(
                              color: isNone ? Colors.grey.shade400 : color,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
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
        _infoTile(Icons.person_rounded, 'Contact Name',
            hasName ? widget.emergencyContactName : 'Not provided'),
        _divider(),
        _infoTile(Icons.phone_rounded, 'Phone Number',
            hasPhone ? widget.emergencyContactPhone : 'Not provided',
            trailing: hasPhone
                ? Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Call',
                  style: TextStyle(
                      color: _red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            )
                : null),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showComingSoon('Edit Emergency Contact'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                side: const BorderSide(color: _blue),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.edit_rounded, size: 15),
              label: const Text('Edit Emergency Contact',
                  style: TextStyle(fontSize: 13)),
            ),
          ),
        ),
      ],
    );
  }

  // ── 4. Doctor Access ─────────────────────────────────────────────────────────
  Widget _buildDoctorAccess() {
    if (_doctorsWithAccess.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.people_outline_rounded,
                color: Colors.grey.shade300, size: 40),
            const SizedBox(height: 10),
            Text('No doctors have access',
                style:
                TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          ],
        ),
      );
    }

    return Column(
      children: [
        ..._doctorsWithAccess.asMap().entries.map((entry) {
          final i     = entry.key;
          final doc   = entry.value;
          final color = doc['color'] as Color;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(doc['icon'] as IconData,
                          color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc['name'] as String,
                              style: const TextStyle(
                                  color: _darkText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(
                            '${doc['specialty']} · ${doc['hospital']}',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text('Since ${doc['since']}',
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _confirmRevoke(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _red.withValues(alpha: 0.3)),
                        ),
                        child: const Text('Revoke',
                            style: TextStyle(
                                color: _red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              if (i < _doctorsWithAccess.length - 1) _divider(),
            ],
          );
        }),
      ],
    );
  }

  // ── Reusable Tiles ───────────────────────────────────────────────────────────
  Widget _infoTile(IconData icon, String label, String value,
      {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: _lightBlue, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: _blue, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        color: _darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (trailing != null) trailing,
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

  void _confirmRevoke(int index) {
    final doc = _doctorsWithAccess[index];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Revoke Access',
            style:
            TextStyle(color: _darkText, fontWeight: FontWeight.bold)),
        content: Text(
          'Remove access for ${doc['name']}? They will no longer be able to view your records.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _doctorsWithAccess.removeAt(index));
              Navigator.pop(context);
              _showSnack('Access revoked', isError: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }

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
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _red : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
//
// class ProfileScreen extends StatefulWidget {
//   final String userName;
//   final String age;
//   final String gender;
//   final String bloodGroup;
//   final String allergies;
//   final String conditions;
//   final String medications;
//   final String surgeries;
//   final String emergencyContactName;
//   final String emergencyContactPhone;
//   final String dob;
//   final String phone;
//
//   const ProfileScreen({
//     super.key,
//     this.userName = 'User',
//     this.age = '—',
//     this.gender = '—',
//     this.bloodGroup = '—',
//     this.allergies = '',
//     this.conditions = '',
//     this.medications = '',
//     this.surgeries = '',
//     this.emergencyContactName = '',
//     this.emergencyContactPhone = '',
//     this.dob = '—',
//     this.phone = '—',
//   });
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   // ── Colors ───────────────────────────────────────────────────────────────────
//   static const _blue      = Color(0xFF1565C0);
//   static const _blueLight = Color(0xFF1E88E5);
//   static const _lightBlue = Color(0xFFE3F2FD);
//   static const _lightBg   = Color(0xFFF5F8FF);
//   static const _darkText  = Color(0xFF1A1A2E);
//   static const _red       = Color(0xFFD32F2F);
//
//   // ── Settings state ───────────────────────────────────────────────────────────
//   bool _notificationsEnabled = true;
//   bool _biometricEnabled     = false;
//   final bool _darkModeEnabled      = false;
//   bool _twoFactorEnabled     = false;
//   String _selectedLanguage   = 'English';
//
//   // ── Sample doctors with access ───────────────────────────────────────────────
//   final List<Map<String, dynamic>> _doctorsWithAccess = [
//     {
//       'name': 'Dr. Raghav Menon',
//       'specialty': 'Cardiology',
//       'hospital': 'Apollo Hospital',
//       'since': 'Mar 1, 2025',
//       'icon': Icons.favorite_rounded,
//       'color': Color(0xFFE53935),
//     },
//     {
//       'name': 'Dr. Priya Sharma',
//       'specialty': 'Pathology',
//       'hospital': 'Medanta',
//       'since': 'Feb 10, 2025',
//       'icon': Icons.science_rounded,
//       'color': Color(0xFF8E24AA),
//     },
//   ];
//
//   // ── Helpers ──────────────────────────────────────────────────────────────────
//   List<String> _split(String value) {
//     if (value.trim().isEmpty) return ['None recorded'];
//     return value
//         .split(RegExp(r'[,\n]'))
//         .map((e) => e.trim())
//         .where((e) => e.isNotEmpty)
//         .toList();
//   }
//
//   String get _initials {
//     final parts = widget.userName.trim().split(' ');
//     if (parts.length >= 2) {
//       return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     }
//     return widget.userName.isNotEmpty
//         ? widget.userName[0].toUpperCase()
//         : 'U';
//   }
//
//   // ── Build ────────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _lightBg,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           _buildAppBar(),
//           SliverToBoxAdapter(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildProfileHeader(),
//                 const SizedBox(height: 24),
//                 _buildSection('Personal Information', Icons.person_rounded,
//                     _buildPersonalInfo()),
//                 const SizedBox(height: 16),
//                 _buildSection('Medical Summary', Icons.medical_information_rounded,
//                     _buildMedicalSummary()),
//                 const SizedBox(height: 16),
//                 _buildSection('Emergency Contact', Icons.emergency_rounded,
//                     _buildEmergencyContact()),
//                 const SizedBox(height: 16),
//                 _buildSection('App Settings', Icons.settings_rounded,
//                     _buildAppSettings()),
//                 const SizedBox(height: 16),
//                 _buildSection('Security & Privacy', Icons.shield_rounded,
//                     _buildSecurityPrivacy()),
//                 const SizedBox(height: 16),
//                 _buildSection('Doctor Access', Icons.people_alt_rounded,
//                     _buildDoctorAccess()),
//                 const SizedBox(height: 16),
//                 _buildSection('Account', Icons.manage_accounts_rounded,
//                     _buildAccountActions()),
//                 const SizedBox(height: 100),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── App Bar ──────────────────────────────────────────────────────────────────
//   Widget _buildAppBar() {
//     return SliverAppBar(
//       expandedHeight: 60,
//       pinned: true,
//       elevation: 0,
//       backgroundColor: _blue,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_rounded,
//             color: Colors.white, size: 20),
//         onPressed: () => Navigator.pop(context),
//       ),
//       title: const Text('My Profile',
//           style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold)),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
//           onPressed: () => _showEditProfileSheet(),
//           tooltip: 'Edit Profile',
//         ),
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [_blue, _blueLight],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Profile Header ───────────────────────────────────────────────────────────
//   Widget _buildProfileHeader() {
//     return Container(
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [_blue, _blueLight],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
//       child: Column(
//         children: [
//           // Avatar
//           Container(
//             width: 88,
//             height: 88,
//             decoration: BoxDecoration(
//               color: Colors.white.withValues(alpha: 0.25),
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white, width: 3),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.15),
//                   blurRadius: 12,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Center(
//               child: Text(_initials,
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold)),
//             ),
//           ),
//           const SizedBox(height: 14),
//
//           // Name
//           Text(widget.userName,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//
//           // Age · Gender · Blood Group
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _headerPill(Icons.cake_rounded, '${widget.age} yrs'),
//               const SizedBox(width: 8),
//               _headerPill(
//                 widget.gender.toLowerCase() == 'male'
//                     ? Icons.male_rounded
//                     : widget.gender.toLowerCase() == 'female'
//                     ? Icons.female_rounded
//                     : Icons.person_rounded,
//                 widget.gender,
//               ),
//               const SizedBox(width: 8),
//               // Blood group — special red pill
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 12, vertical: 5),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE53935),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                       color: Colors.white.withValues(alpha: 0.5)),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.bloodtype_rounded,
//                         color: Colors.white, size: 13),
//                     const SizedBox(width: 5),
//                     Text(widget.bloodGroup,
//                         style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _headerPill(IconData icon, String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.2),
//         borderRadius: BorderRadius.circular(20),
//         border:
//         Border.all(color: Colors.white.withValues(alpha: 0.4)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.white, size: 13),
//           const SizedBox(width: 5),
//           Text(label,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
//
//   // ── Section wrapper ──────────────────────────────────────────────────────────
//   Widget _buildSection(String title, IconData icon, Widget content) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section title
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                     color: _lightBlue,
//                     borderRadius: BorderRadius.circular(8)),
//                 child: Icon(icon, color: _blue, size: 15),
//               ),
//               const SizedBox(width: 10),
//               Text(title,
//                   style: const TextStyle(
//                       color: _darkText,
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold)),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: content,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── 1. Personal Information ──────────────────────────────────────────────────
//   Widget _buildPersonalInfo() {
//     return Column(
//       children: [
//         _infoTile(Icons.cake_rounded, 'Date of Birth', widget.dob),
//         _divider(),
//         _infoTile(Icons.phone_rounded, 'Phone Number', widget.phone),
//         _divider(),
//         _infoTile(Icons.email_rounded, 'Email', 'Not provided',
//             trailing: TextButton(
//               onPressed: () {},
//               child: const Text('Add',
//                   style: TextStyle(color: _blue, fontSize: 13)),
//             )),
//       ],
//     );
//   }
//
//   // ── 2. Medical Summary ───────────────────────────────────────────────────────
//   Widget _buildMedicalSummary() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Edit button header
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 14, 12, 4),
//           child: Row(
//             children: [
//               const Text('Health Overview',
//                   style: TextStyle(
//                       color: _darkText,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600)),
//               const Spacer(),
//               TextButton.icon(
//                 onPressed: () => _showEditMedicalSheet(),
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 4),
//                   minimumSize: Size.zero,
//                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 ),
//                 icon: const Icon(Icons.edit_rounded,
//                     size: 13, color: _blue),
//                 label: const Text('Edit',
//                     style: TextStyle(color: _blue, fontSize: 13)),
//               ),
//             ],
//           ),
//         ),
//         _divider(),
//         _medicalRow(Icons.warning_amber_rounded, 'Allergies',
//             _split(widget.allergies), const Color(0xFFE53935),
//             const Color(0xFFFFEBEE)),
//         _divider(),
//         _medicalRow(Icons.monitor_heart_rounded, 'Chronic Conditions',
//             _split(widget.conditions), const Color(0xFF1565C0),
//             const Color(0xFFE3F2FD)),
//         _divider(),
//         _medicalRow(Icons.medication_rounded, 'Current Medications',
//             _split(widget.medications), const Color(0xFF2E7D32),
//             const Color(0xFFE8F5E9)),
//         _divider(),
//         _medicalRow(Icons.local_hospital_rounded, 'Past Surgeries',
//             _split(widget.surgeries), const Color(0xFF8E24AA),
//             const Color(0xFFF3E5F5)),
//         const SizedBox(height: 4),
//       ],
//     );
//   }
//
//   Widget _medicalRow(IconData icon, String label, List<String> items,
//       Color color, Color bg) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(7),
//             decoration: BoxDecoration(
//                 color: bg, borderRadius: BorderRadius.circular(8)),
//             child: Icon(icon, color: color, size: 15),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label,
//                     style: TextStyle(
//                         color: Colors.grey.shade500,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w500)),
//                 const SizedBox(height: 4),
//                 Wrap(
//                   spacing: 6,
//                   runSpacing: 4,
//                   children: items.map((item) {
//                     final isNone = item == 'None recorded';
//                     return Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: isNone
//                             ? Colors.grey.shade100
//                             : bg,
//                         borderRadius: BorderRadius.circular(6),
//                         border: Border.all(
//                           color: isNone
//                               ? Colors.grey.shade200
//                               : color.withValues(alpha: 0.3),
//                         ),
//                       ),
//                       child: Text(item,
//                           style: TextStyle(
//                               color: isNone
//                                   ? Colors.grey.shade400
//                                   : color,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500)),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── 3. Emergency Contact ─────────────────────────────────────────────────────
//   Widget _buildEmergencyContact() {
//     final hasName  = widget.emergencyContactName.trim().isNotEmpty;
//     final hasPhone = widget.emergencyContactPhone.trim().isNotEmpty;
//
//     return Column(
//       children: [
//         _infoTile(Icons.person_rounded, 'Contact Name',
//             hasName ? widget.emergencyContactName : 'Not provided'),
//         _divider(),
//         _infoTile(Icons.phone_rounded, 'Phone Number',
//             hasPhone ? widget.emergencyContactPhone : 'Not provided',
//             trailing: hasPhone
//                 ? Container(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFEBEE),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Text('Call',
//                   style: TextStyle(
//                       color: _red,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold)),
//             )
//                 : null),
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
//           child: SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: () => _showEditEmergencySheet(),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: _blue,
//                 side: const BorderSide(color: _blue),
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//               ),
//               icon: const Icon(Icons.edit_rounded, size: 15),
//               label: const Text('Edit Emergency Contact',
//                   style: TextStyle(fontSize: 13)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── 4. App Settings ──────────────────────────────────────────────────────────
//   Widget _buildAppSettings() {
//     return Column(
//       children: [
//         _toggleTile(
//           icon: Icons.notifications_rounded,
//           iconColor: const Color(0xFFEF6C00),
//           iconBg: const Color(0xFFFFF3E0),
//           label: 'Notifications',
//           subtitle: 'Record reminders & updates',
//           value: _notificationsEnabled,
//           onChanged: (v) => setState(() => _notificationsEnabled = v),
//         ),
//         _divider(),
//         _toggleTile(
//           icon: Icons.fingerprint_rounded,
//           iconColor: const Color(0xFF1565C0),
//           iconBg: const Color(0xFFE3F2FD),
//           label: 'Biometric Lock',
//           subtitle: 'Fingerprint / Face unlock',
//           value: _biometricEnabled,
//           onChanged: (v) => setState(() => _biometricEnabled = v),
//         ),
//         _divider(),
//         _toggleTile(
//           icon: Icons.dark_mode_rounded,
//           iconColor: const Color(0xFF1A1A2E),
//           iconBg: const Color(0xFFECEFF1),
//           label: 'Dark Mode',
//           subtitle: 'Coming soon',
//           value: _darkModeEnabled,
//           onChanged: null, // disabled
//         ),
//         _divider(),
//         _tappableTile(
//           icon: Icons.language_rounded,
//           iconColor: const Color(0xFF00897B),
//           iconBg: const Color(0xFFE0F2F1),
//           label: 'Language',
//           subtitle: _selectedLanguage,
//           onTap: () => _showLanguagePicker(),
//         ),
//       ],
//     );
//   }
//
//   // ── 5. Security & Privacy ────────────────────────────────────────────────────
//   Widget _buildSecurityPrivacy() {
//     return Column(
//       children: [
//         _tappableTile(
//           icon: Icons.lock_rounded,
//           iconColor: const Color(0xFF1565C0),
//           iconBg: const Color(0xFFE3F2FD),
//           label: 'Change PIN / Password',
//           onTap: () => _showComingSoon('Change PIN'),
//         ),
//         _divider(),
//         _toggleTile(
//           icon: Icons.security_rounded,
//           iconColor: const Color(0xFF2E7D32),
//           iconBg: const Color(0xFFE8F5E9),
//           label: 'Two-Factor Authentication',
//           subtitle: '2FA via SMS',
//           value: _twoFactorEnabled,
//           onChanged: (v) => setState(() => _twoFactorEnabled = v),
//         ),
//         _divider(),
//         _tappableTile(
//           icon: Icons.privacy_tip_rounded,
//           iconColor: const Color(0xFF8E24AA),
//           iconBg: const Color(0xFFF3E5F5),
//           label: 'Data Privacy Settings',
//           onTap: () => _showComingSoon('Data Privacy'),
//         ),
//         _divider(),
//         _tappableTile(
//           icon: Icons.download_rounded,
//           iconColor: const Color(0xFF00838F),
//           iconBg: const Color(0xFFE0F7FA),
//           label: 'Download My Data',
//           subtitle: 'Export all records as PDF',
//           onTap: () => _showComingSoon('Export Data'),
//         ),
//       ],
//     );
//   }
//
//   // ── 6. Doctor Access ─────────────────────────────────────────────────────────
//   Widget _buildDoctorAccess() {
//     if (_doctorsWithAccess.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Icon(Icons.people_outline_rounded,
//                 color: Colors.grey.shade300, size: 40),
//             const SizedBox(height: 10),
//             Text('No doctors have access',
//                 style: TextStyle(
//                     color: Colors.grey.shade400, fontSize: 14)),
//           ],
//         ),
//       );
//     }
//
//     return Column(
//       children: [
//         ..._doctorsWithAccess.asMap().entries.map((entry) {
//           final i    = entry.key;
//           final doc  = entry.value;
//           final color = doc['color'] as Color;
//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(9),
//                       decoration: BoxDecoration(
//                         color: color.withValues(alpha: 0.1),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Icon(doc['icon'] as IconData,
//                           color: color, size: 18),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(doc['name'] as String,
//                               style: const TextStyle(
//                                   color: _darkText,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 2),
//                           Text(
//                             '${doc['specialty']} · ${doc['hospital']}',
//                             style: TextStyle(
//                                 color: Colors.grey.shade500,
//                                 fontSize: 12),
//                           ),
//                           const SizedBox(height: 2),
//                           Text('Since ${doc['since']}',
//                               style: TextStyle(
//                                   color: Colors.grey.shade400,
//                                   fontSize: 11)),
//                         ],
//                       ),
//                     ),
//                     // Revoke button
//                     GestureDetector(
//                       onTap: () => _confirmRevoke(i),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFFFEBEE),
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                               color: _red.withValues(alpha: 0.3)),
//                         ),
//                         child: const Text('Revoke',
//                             style: TextStyle(
//                                 color: _red,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (i < _doctorsWithAccess.length - 1) _divider(),
//             ],
//           );
//         }),
//       ],
//     );
//   }
//
//   // ── 7. Account Actions ───────────────────────────────────────────────────────
//   Widget _buildAccountActions() {
//     return Column(
//       children: [
//         _tappableTile(
//           icon: Icons.help_outline_rounded,
//           iconColor: const Color(0xFF1565C0),
//           iconBg: const Color(0xFFE3F2FD),
//           label: 'Help & Support',
//           onTap: () => _showComingSoon('Help & Support'),
//         ),
//         _divider(),
//         _tappableTile(
//           icon: Icons.info_outline_rounded,
//           iconColor: const Color(0xFF546E7A),
//           iconBg: const Color(0xFFECEFF1),
//           label: 'About MediVault',
//           subtitle: 'Version 1.0.0',
//           onTap: () => _showAboutDialog(),
//         ),
//         _divider(),
//
//         // Logout
//         _tappableTile(
//           icon: Icons.logout_rounded,
//           iconColor: _red,
//           iconBg: const Color(0xFFFFEBEE),
//           label: 'Logout',
//           labelColor: _red,
//           onTap: () => _confirmLogout(),
//         ),
//         _divider(),
//
//         // Delete Account — subtle but accessible
//         _tappableTile(
//           icon: Icons.delete_forever_rounded,
//           iconColor: Colors.grey.shade400,
//           iconBg: Colors.grey.shade100,
//           label: 'Delete Account',
//           labelColor: Colors.grey.shade400,
//           subtitle: 'Permanently removes all your data',
//           onTap: () => _confirmDeleteAccount(),
//         ),
//       ],
//     );
//   }
//
//   // ── Reusable tile widgets ─────────────────────────────────────────────────────
//   Widget _infoTile(IconData icon, String label, String value,
//       {Widget? trailing}) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
//       child: Row(
//           children: [
//       Container(
//       padding: const EdgeInsets.all(7),
//       decoration: BoxDecoration(
//           color: _lightBlue,
//           borderRadius: BorderRadius.circular(8)),
//       child: Icon(icon, color: _blue, size: 15),
//     ),
//     const SizedBox(width: 12),
//     Expanded(
//     child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//     Text(label,
//     style: TextStyle(
//     color: Colors.grey.shade400,
//     fontSize: 11,
//     fontWeight: FontWeight.w500)),
//     const SizedBox(height: 3),
//     Text(value,
//     style: const TextStyle(
//     color: _darkText,
//     fontSize: 14,
//     fontWeight: FontWeight.w600)),
//     ],
//     ),
//     ),
//     ?trailing,
//     ],
//     ),
//     );
//     }
//
//   Widget _toggleTile({
//     required IconData icon,
//     required Color iconColor,
//     required Color iconBg,
//     required String label,
//     String? subtitle,
//     required bool value,
//     required void Function(bool)? onChanged,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(7),
//             decoration: BoxDecoration(
//                 color: iconBg, borderRadius: BorderRadius.circular(8)),
//             child: Icon(icon, color: iconColor, size: 15),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label,
//                     style: TextStyle(
//                         color: onChanged == null
//                             ? Colors.grey.shade400
//                             : _darkText,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600)),
//                 if (subtitle != null)
//                   Text(subtitle,
//                       style: TextStyle(
//                           color: Colors.grey.shade400, fontSize: 11)),
//               ],
//             ),
//           ),
//           Switch(
//             value: value,
//             onChanged: onChanged,
//             activeThumbColor: _blue,
//             activeTrackColor: _blue.withValues(alpha: 0.4),
//             inactiveTrackColor: Colors.grey.shade200,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _tappableTile({
//     required IconData icon,
//     required Color iconColor,
//     required Color iconBg,
//     required String label,
//     String? subtitle,
//     Color? labelColor,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(7),
//               decoration: BoxDecoration(
//                   color: iconBg,
//                   borderRadius: BorderRadius.circular(8)),
//               child: Icon(icon, color: iconColor, size: 15),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(label,
//                       style: TextStyle(
//                           color: labelColor ?? _darkText,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600)),
//                   if (subtitle != null)
//                     Text(subtitle,
//                         style: TextStyle(
//                             color: Colors.grey.shade400, fontSize: 11)),
//                 ],
//               ),
//             ),
//             Icon(Icons.chevron_right_rounded,
//                 color: Colors.grey.shade300, size: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _divider() => Divider(
//     height: 1,
//     thickness: 1,
//     color: Colors.grey.withValues(alpha: 0.1),
//     indent: 16,
//     endIndent: 16,
//   );
//
//   // ── Bottom sheets / dialogs ───────────────────────────────────────────────────
//   void _showEditProfileSheet() {
//     _showComingSoon('Edit Profile');
//   }
//
//   void _showEditMedicalSheet() {
//     _showComingSoon('Edit Medical Summary');
//   }
//
//   void _showEditEmergencySheet() {
//     _showComingSoon('Edit Emergency Contact');
//   }
//
//   void _showLanguagePicker() {
//     final languages = ['English', 'Hindi', 'Telugu', 'Tamil', 'Kannada'];
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (_) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40, height: 4,
//               decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             const SizedBox(height: 16),
//             const Row(
//               children: [
//                 Icon(Icons.language_rounded, color: _blue, size: 18),
//                 SizedBox(width: 8),
//                 Text('Select Language',
//                     style: TextStyle(
//                         color: _darkText,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ...languages.map((lang) => ListTile(
//               title: Text(lang,
//                   style: TextStyle(
//                       color: _darkText,
//                       fontWeight: _selectedLanguage == lang
//                           ? FontWeight.bold
//                           : FontWeight.normal)),
//               trailing: _selectedLanguage == lang
//                   ? const Icon(Icons.check_circle_rounded,
//                   color: _blue)
//                   : null,
//               onTap: () {
//                 setState(() => _selectedLanguage = lang);
//                 Navigator.pop(context);
//               },
//             )),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _confirmRevoke(int index) {
//     final doc = _doctorsWithAccess[index];
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16)),
//         title: const Text('Revoke Access',
//             style: TextStyle(
//                 color: _darkText, fontWeight: FontWeight.bold)),
//         content: Text(
//           'Remove access for ${doc['name']}? They will no longer be able to view your records.',
//           style: TextStyle(color: Colors.grey.shade600),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel',
//                 style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               setState(() => _doctorsWithAccess.removeAt(index));
//               Navigator.pop(context);
//               _showSnack('Access revoked', isError: true);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _red,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text('Revoke'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _confirmLogout() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16)),
//         title: const Text('Logout',
//             style: TextStyle(
//                 color: _darkText, fontWeight: FontWeight.bold)),
//         content: Text('Are you sure you want to logout?',
//             style: TextStyle(color: Colors.grey.shade600)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel',
//                 style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               // TODO: clear auth state and navigate to AuthScreen
//               _showSnack('Logged out successfully');
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _red,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _confirmDeleteAccount() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16)),
//         title: const Row(
//           children: [
//             Icon(Icons.warning_rounded, color: _red, size: 20),
//             SizedBox(width: 8),
//             Text('Delete Account',
//                 style: TextStyle(
//                     color: _red, fontWeight: FontWeight.bold)),
//           ],
//         ),
//         content: Text(
//           'This will permanently delete your account and ALL medical records. This action cannot be undone.',
//           style: TextStyle(color: Colors.grey.shade600),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel',
//                 style: TextStyle(color: Colors.grey)),
//           ),
//           OutlinedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _showSnack('Account deletion requested', isError: true);
//             },
//             style: OutlinedButton.styleFrom(
//               foregroundColor: _red,
//               side: const BorderSide(color: _red),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text('Delete',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showAboutDialog() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16)),
//         title: const Row(
//           children: [
//             Icon(Icons.local_hospital_rounded, color: _blue, size: 22),
//             SizedBox(width: 8),
//             Text('MediVault',
//                 style: TextStyle(
//                     color: _darkText, fontWeight: FontWeight.bold)),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Version 1.0.0',
//                 style: TextStyle(
//                     color: Colors.grey.shade500, fontSize: 13)),
//             const SizedBox(height: 8),
//             Text(
//               'Your lifelong medical records — secure, organized, always accessible.',
//               style: TextStyle(
//                   color: Colors.grey.shade600, fontSize: 13),
//             ),
//             const SizedBox(height: 8),
//             Text('Built with ❤️ for better personal healthcare.',
//                 style: TextStyle(
//                     color: Colors.grey.shade500, fontSize: 12)),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close', style: TextStyle(color: _blue)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showComingSoon(String feature) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.construction_rounded,
//                 color: Colors.white, size: 16),
//             const SizedBox(width: 8),
//             Text('$feature — Coming soon!'),
//           ],
//         ),
//         backgroundColor: _blue,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.all(12),
//       ),
//     );
//   }
//
//   void _showSnack(String msg, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: isError ? _red : const Color(0xFF2E7D32),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.all(12),
//       ),
//     );
//   }
// }