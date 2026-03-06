import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyInfoScreen extends StatefulWidget {
  // ── Personal details (from SignUpPage1) ──────────────────────────────────
  final String name;
  final String age;
  final String bloodGroup;

  // ── Medical details (from SignUpPage2) ───────────────────────────────────
  final String allergies;
  final String conditions;
  final String medications;
  final String surgeries;
  final String emergencyContactName;
  final String emergencyContactPhone;

  const EmergencyInfoScreen({
    super.key,
    // Defaults shown when opened directly (e.g. from auth screen before login)
    this.name = 'Unknown',
    this.age = '—',
    this.bloodGroup = '—',
    this.allergies = 'None recorded',
    this.conditions = 'None recorded',
    this.medications = 'None recorded',
    this.surgeries = 'None recorded',
    this.emergencyContactName = 'Not provided',
    this.emergencyContactPhone = '',
  });

  @override
  State<EmergencyInfoScreen> createState() => _EmergencyInfoScreenState();
}

class _EmergencyInfoScreenState extends State<EmergencyInfoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ── Colors ─────────────────────────────────────────────────────────────────
  static const _red = Color(0xFFE53935);
  static const _softRed = Color(0xFFFFEBEE);
  static const _blue = Color(0xFF1565C0);
  static const _lightBlue = Color(0xFFE3F2FD);
  static const _darkText = Color(0xFF1A1A2E);

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

  // ── Helpers ────────────────────────────────────────────────────────────────
  List<String> _splitField(String value) {
    if (value.trim().isEmpty || value.trim().toLowerCase() == 'none recorded') {
      return ['None recorded'];
    }
    return value
        .split(RegExp(r'[,\n]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _call(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
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
                    iconColor: _blue,
                    bgColor: _lightBlue,
                    items: _splitField(widget.conditions),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Current Medications',
                    icon: Icons.medication_rounded,
                    iconColor: const Color(0xFF1976D2),
                    bgColor: const Color(0xFFE8F4FD),
                    items: _splitField(widget.medications),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Past Surgeries',
                    icon: Icons.local_hospital_rounded,
                    iconColor: const Color(0xFF0D47A1),
                    bgColor: const Color(0xFFE0EAFF),
                    items: _splitField(widget.surgeries),
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(),
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
      // Softer: blue-to-red gradient instead of pure red
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFFE53935)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
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
                  Icon(Icons.lock_open_rounded, color: Colors.white, size: 13),
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

  // ── Patient Header Card ────────────────────────────────────────────────────
  Widget _buildPatientCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // Blue-dominant gradient with a red tint — softer than pure red
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.3),
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
                widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                // Age pill
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cake_rounded,
                          color: Colors.white70, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Age ${widget.age}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Emergency icon with soft red circle
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emergency_rounded,
                color: Colors.white, size: 22),
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
        // Soft left border accent in red, rest in blue
        border: Border(
          left: const BorderSide(color: _red, width: 4),
          top: BorderSide(color: _lightBlue, width: 1),
          right: BorderSide(color: _lightBlue, width: 1),
          bottom: BorderSide(color: _lightBlue, width: 1),
        ),
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
            widget.bloodGroup,
            style: const TextStyle(
              color: _red,
              fontSize: 52,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ── Allergies Card ─────────────────────────────────────────────────────────
  Widget _buildAllergiesCard() {
    final allergies = _splitField(widget.allergies);
    final hasAllergies = !(allergies.length == 1 &&
        allergies[0].toLowerCase() == 'none recorded');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Softer: mostly white with very light red tint
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAllergies
              ? _red.withValues(alpha: 0.3)
              : _lightBlue,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: hasAllergies
                ? _red.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
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
                  // Icon bg: soft red if allergies, blue if none
                  color: hasAllergies ? _softRed : _lightBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.warning_rounded,
                    color: hasAllergies ? _red : _blue, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Allergies',
                style: TextStyle(
                  color: hasAllergies ? _red : _darkText,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasAllergies) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    // CRITICAL badge: red but smaller/less intense
                    color: _red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _red.withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'CRITICAL',
                    style: TextStyle(
                      color: _red,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          // Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allergies.map((allergy) {
              final isNone = allergy.toLowerCase() == 'none recorded';
              return Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isNone ? _lightBlue : _softRed,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isNone
                        ? _blue.withValues(alpha: 0.3)
                        : _red.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  allergy,
                  style: TextStyle(
                    color: isNone ? _blue : _red,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Generic Info Card ──────────────────────────────────────────────────────
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
                  color: _darkText,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                        color: _darkText,
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

  // ── Emergency Contact Card ─────────────────────────────────────────────────
  Widget _buildContactCard() {
    final hasPhone = widget.emergencyContactPhone.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Soft blue border, red accent only on left
        border: Border(
          left: const BorderSide(color: _red, width: 4),
          top: BorderSide(color: _lightBlue, width: 1),
          right: BorderSide(color: _lightBlue, width: 1),
          bottom: BorderSide(color: _lightBlue, width: 1),
        ),
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
          // Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _softRed,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'EMERGENCY CONTACT',
              style: TextStyle(
                color: _red,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Avatar with blue bg (less red)
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _lightBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded,
                    color: _blue, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.emergencyContactName,
                      style: const TextStyle(
                        color: _darkText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Emergency Contact',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Call button — red but smaller/softer
              if (hasPhone)
                GestureDetector(
                  onTap: () => _call(widget.emergencyContactPhone),
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: _red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _red.withValues(alpha: 0.3),
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
          if (hasPhone) ...[
            const SizedBox(height: 12),
            // Phone row with blue tint
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _lightBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_rounded, color: _blue, size: 15),
                  const SizedBox(width: 8),
                  Text(
                    widget.emergencyContactPhone,
                    style: const TextStyle(
                      color: _blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _call(widget.emergencyContactPhone),
                    child: Text(
                      'Tap to Call',
                      style: TextStyle(
                        color: _blue.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
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