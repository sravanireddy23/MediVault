import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _blue = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF1E88E5);
  static const _lightBlue = Color(0xFFE3F2FD);
  static const _lightBg = Color(0xFFF5F8FF);
  static const _darkText = Color(0xFF1A1A2E);
  static const _red = Color(0xFFD32F2F);

  Future<Map<String, dynamic>?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  List<String> _split(String value) {
    if (value.trim().isEmpty) return ['None recorded'];
    return value
        .split(RegExp(r'[,\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
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

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 60,
      pinned: true,
      backgroundColor: _blue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'My Profile',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> data) {
    final name = data['name'] ?? 'User';
    final initials = _getInitials(name);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_blue, _blueLight],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white24,
            child: Text(
              initials,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            "${data['age'] ?? '—'} yrs • ${data['gender'] ?? '—'} • ${data['bloodGroup'] ?? '—'}",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(Map<String, dynamic> data) {
    return Column(
      children: [
        _infoTile("Full Name", data['name']),
        _infoTile("Age", data['age']),
        _infoTile("Gender", data['gender']),
        _infoTile("Blood Group", data['bloodGroup']),
        _infoTile("Phone", data['phone']),
      ],
    );
  }

  Widget _buildMedicalSummary(Map<String, dynamic> data) {
    return Column(
      children: [
        _infoTile("Allergies", data['allergies']),
        _infoTile("Conditions", data['conditions']),
        _infoTile("Medications", data['medications']),
        _infoTile("Surgeries", data['surgeries']),
      ],
    );
  }

  Widget _buildEmergencyContact(Map<String, dynamic> data) {
    return Column(
      children: [
        _infoTile("Contact Name", data['emergencyContactName']),
        _infoTile("Phone", data['emergencyContactPhone']),
      ],
    );
  }

  Widget _infoTile(String label, dynamic value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value?.toString() ?? ''),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: content,
          ),
        ],
      ),
    );
  }
}