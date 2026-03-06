import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyInfoScreen extends StatefulWidget {
  const EmergencyInfoScreen({super.key});

  @override
  State<EmergencyInfoScreen> createState() => _EmergencyInfoScreenState();
}

class _EmergencyInfoScreenState extends State<EmergencyInfoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ── REPLACE WITH REAL DATA FROM FIRESTORE (fetched by phone/token) ─────────
  final Map<String, dynamic> _data = {
    'name': 'Arjun Sharma',
    'age': '28',
    'bloodGroup': 'O+',
    'allergies': ['Penicillin', 'Peanuts', 'Latex'],
    'conditions': ['Type 2 Diabetes', 'Mild Asthma'],
    'medications': ['Metformin 500mg', 'Salbutamol Inhaler'],
    'emergencyContactName': 'Priya Sharma',
    'emergencyContactRelation': 'Sister',
    'emergencyContactPhone': '+919876543210',
    'doctorName': 'Dr. Ravi Kumar',
    'doctorSpecialty': 'General Physician',
    'doctorPhone': '+919123456789',
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientCard(),
                  const SizedBox(height: 16),
                  _buildBloodGroupCard(),
                  const SizedBox(height: 16),
                  _buildAllergiesCard(),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Medical Conditions',
                    icon: Icons.monitor_heart_rounded,
                    iconColor: const Color(0xFF1565C0),
                    bgColor: const Color(0xFFE3F2FD),
                    items: List<String>.from(_data['conditions']),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Current Medications',
                    icon: Icons.medication_rounded,
                    iconColor: const Color(0xFF1976D2),
                    bgColor: const Color(0xFFE8F4FD),
                    items: List<String>.from(_data['medications']),
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    tag: 'Emergency Contact',
                    name: _data['emergencyContactName'],
                    subtitle: _data['emergencyContactRelation'],
                    phone: _data['emergencyContactPhone'],
                    avatarColor: const Color(0xFFD32F2F),
                    avatarBg: const Color(0xFFFFEBEE),
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    tag: 'Primary Doctor',
                    name: _data['doctorName'],
                    subtitle: _data['doctorSpecialty'],
                    phone: _data['doctorPhone'],
                    avatarColor: const Color(0xFF1565C0),
                    avatarBg: const Color(0xFFE3F2FD),
                    icon: Icons.medical_services_rounded,
                  ),
                  const SizedBox(height: 20),
                  _buildDisclaimer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFD32F2F),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Emergency Info',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 0.3,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5), width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_open_rounded,
                      color: Colors.white, size: 13),
                  SizedBox(width: 4),
                  Text(
                    'No Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Patient Card ───────────────────────────────────────────────────────────
  Widget _buildPatientCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5), width: 2),
            ),
            child: Center(
              child: Text(
                (_data['name'] as String)[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name + Age
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _data['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _infoPill('Age ${_data['age']}',
                        Icons.cake_rounded),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.emergency_rounded,
              color: Colors.white54, size: 28),
        ],
      ),
    );
  }

  Widget _infoPill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Blood Group Card ───────────────────────────────────────────────────────
  Widget _buildBloodGroupCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
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
          const Text(
            'BLOOD GROUP',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _data['bloodGroup'],
            style: const TextStyle(
              color: Color(0xFFD32F2F),
              fontSize: 52,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ── Allergies Card (special red highlight) ─────────────────────────────────
  Widget _buildAllergiesCard() {
    final List<String> allergies = List<String>.from(_data['allergies']);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFD32F2F).withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD32F2F).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_rounded,
                    color: Color(0xFFD32F2F), size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Allergies',
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'CRITICAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allergies
                .map(
                  (allergy) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFFD32F2F).withValues(alpha: 0.5),
                      width: 1.2),
                ),
                child: Text(
                  allergy,
                  style: const TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Generic Info Card (Conditions / Medications) ───────────────────────────
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required List<String> items,
  }) {
    return Container(
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Items
          ...items.map(
                (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Contact Card ───────────────────────────────────────────────────────────
  Widget _buildContactCard({
    required String tag,
    required String name,
    required String subtitle,
    required String phone,
    required Color avatarColor,
    required Color avatarBg,
    required IconData icon,
  }) {
    return Container(
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
          // Tag label
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: avatarBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tag.toUpperCase(),
              style: TextStyle(
                color: avatarColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: avatarBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: avatarColor, size: 22),
              ),
              const SizedBox(width: 14),
              // Name + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Call button
              GestureDetector(
                onTap: () => _call(phone),
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: avatarColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.call_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Phone number row
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_rounded, color: avatarColor, size: 15),
                const SizedBox(width: 8),
                Text(
                  phone,
                  style: TextStyle(
                    color: avatarColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _call(phone),
                  child: Text(
                    'Tap to Call',
                    style: TextStyle(
                      color: avatarColor.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Disclaimer ─────────────────────────────────────────────────────────────
  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: Colors.grey.shade400, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This information is provided for emergency use only. '
                  'Always consult a licensed medical professional for diagnosis and treatment.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}