import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit_emergency_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _blue      = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF1E88E5);
  static const _lightBg   = Color(0xFFF5F8FF);
  static const _darkText  = Color(0xFF1A1A2E);
  static const _red       = Color(0xFFE53935);

  // Key to force FutureBuilder rebuild on refresh
  int _refreshKey = 0;

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc.data();
  }

  void _refresh() => setState(() => _refreshKey++);

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  // ── Navigate to Edit Emergency ────────────────────────────────────────────
  Future<void> _openEditEmergency(Map<String, dynamic> data) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditEmergencyScreen(
          initialName:  data['emergencyContactName']  ?? '',
          initialPhone: data['emergencyContactPhone'] ?? '',
        ),
      ),
    );
    if (result == true) _refresh();
  }

  // ── Navigate to Edit Profile ──────────────────────────────────────────────
  Future<void> _openEditProfile(Map<String, dynamic> data) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(userData: data),
      ),
    );
    if (result == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: FutureBuilder<Map<String, dynamic>?>(
        key: ValueKey(_refreshKey),
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _blue));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No profile data found.',
                  style: TextStyle(color: Colors.grey)),
            );
          }

          final data = snapshot.data!;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(data),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Personal Information',
                      Icons.person_rounded,
                      _buildPersonalInfo(data),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      'Medical Summary',
                      Icons.medical_information_rounded,
                      _buildMedicalSummary(data),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      'Emergency Contact',
                      Icons.emergency_rounded,
                      _buildEmergencyContact(data),
                    ),
                    const SizedBox(height: 16),

                    // ── Edit Emergency Info button ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _actionButton(
                        icon: Icons.emergency_rounded,
                        label: 'Edit Emergency Info',
                        color: _red,
                        bgColor: const Color(0xFFFFEBEE),
                        onTap: () => _openEditEmergency(data),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Edit Profile button ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _actionButton(
                        icon: Icons.edit_rounded,
                        label: 'Edit Profile',
                        color: _blue,
                        bgColor: const Color(0xFFE3F2FD),
                        onTap: () => _openEditProfile(data),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
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
            fontWeight: FontWeight.bold,
            fontSize: 18),
      ),
    );
  }

  // ── Profile Header ────────────────────────────────────────────────────────
  Widget _buildProfileHeader(Map<String, dynamic> data) {
    final name     = data['name'] ?? 'User';
    final initials = _getInitials(name);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [_blue, _blueLight]),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white24,
            child: Text(initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 14),
          Text(name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "${data['age'] ?? '—'} yrs  •  ${data['gender'] ?? '—'}  •  ${data['bloodGroup'] ?? '—'}",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Personal Info ─────────────────────────────────────────────────────────
  Widget _buildPersonalInfo(Map<String, dynamic> data) {
    return Column(
      children: [
        _infoTile(Icons.person_rounded,   'Full Name',   data['name']),
        _divider(),
        _infoTile(Icons.cake_rounded,     'Date of Birth', data['dob']),
        _divider(),
        _infoTile(Icons.cake_rounded,     'Age',         data['age']),
        _divider(),
        _infoTile(Icons.wc_rounded,       'Gender',      data['gender']),
        _divider(),
        _infoTile(Icons.bloodtype_rounded,'Blood Group', data['bloodGroup']),
        _divider(),
        _infoTile(Icons.email_rounded,    'Email',
            FirebaseAuth.instance.currentUser?.email),
      ],
    );
  }

  // ── Medical Summary ───────────────────────────────────────────────────────
  Widget _buildMedicalSummary(Map<String, dynamic> data) {
    return Column(
      children: [
        _infoTile(Icons.warning_rounded,       'Allergies',   data['allergies']),
        _divider(),
        _infoTile(Icons.monitor_heart_rounded, 'Conditions',  data['conditions']),
        _divider(),
        _infoTile(Icons.medication_rounded,    'Medications', data['medications']),
        _divider(),
        _infoTile(Icons.local_hospital_rounded,'Surgeries',   data['surgeries']),
      ],
    );
  }

  // ── Emergency Contact ─────────────────────────────────────────────────────
  Widget _buildEmergencyContact(Map<String, dynamic> data) {
    return Column(
      children: [
        _infoTile(Icons.person_rounded,'Contact Name',
            data['emergencyContactName']),
        _divider(),
        _infoTile(Icons.phone_rounded, 'Phone Number',
            data['emergencyContactPhone']),
      ],
    );
  }

  // ── Info Tile ─────────────────────────────────────────────────────────────
  Widget _infoTile(IconData icon, String label, dynamic value) {
    final displayValue =
    (value == null || value.toString().trim().isEmpty)
        ? 'Not provided'
        : value.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _blue, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(displayValue,
                    style: const TextStyle(
                        color: _darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
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

  // ── Section Wrapper ───────────────────────────────────────────────────────
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
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
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

  // ── Action Button (Edit Emergency / Edit Profile) ─────────────────────────
  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}