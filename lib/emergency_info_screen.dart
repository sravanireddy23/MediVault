import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyInfoScreen extends StatefulWidget {
  final String name;
  final String age;
  final String gender;
  final String bloodGroup;
  final String allergies;
  final String conditions;
  final String medications;
  final String surgeries;
  final String emergencyContactName;
  final String emergencyContactPhone;

  const EmergencyInfoScreen({
    super.key,
    this.name = 'Unknown',
    this.age = 'N/A',
    this.gender = 'N/A',
    this.bloodGroup = 'N/A',
    this.allergies = '',
    this.conditions = '',
    this.medications = '',
    this.surgeries = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
  });

  @override
  State<EmergencyInfoScreen> createState() => _EmergencyInfoScreenState();
}

class _EmergencyInfoScreenState extends State<EmergencyInfoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const _blue      = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF1E88E5);
  static const _lightBlue = Color(0xFFE3F2FD);
  static const _red       = Color(0xFFE53935);
  static const _softRed   = Color(0xFFFFEBEE);
  static const _darkText  = Color(0xFF1A1A2E);

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

  List<String> _split(String value) {
    if (value.trim().isEmpty) return ['None recorded'];
    final parts = value
        .split(RegExp(r'[,\n]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.isEmpty ? ['None recorded'] : parts;
  }

  Future<void> _call(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  IconData _genderIcon(String g) {
    if (g.toLowerCase() == 'male') return Icons.male_rounded;
    if (g.toLowerCase() == 'female') return Icons.female_rounded;
    return Icons.person_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _appBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _patientCard(),
                  const SizedBox(height: 16),
                  _bloodGroupCard(),
                  const SizedBox(height: 16),
                  _allergiesCard(),
                  const SizedBox(height: 16),
                  _infoCard(
                    title: 'Medical Conditions',
                    icon: Icons.monitor_heart_rounded,
                    iconColor: _blue,
                    bgColor: _lightBlue,
                    items: _split(widget.conditions),
                  ),
                  const SizedBox(height: 16),
                  _infoCard(
                    title: 'Current Medications',
                    icon: Icons.medication_rounded,
                    iconColor: const Color(0xFF1976D2),
                    bgColor: const Color(0xFFE8F4FD),
                    items: _split(widget.medications),
                  ),
                  const SizedBox(height: 16),
                  _infoCard(
                    title: 'Past Surgeries',
                    icon: Icons.local_hospital_rounded,
                    iconColor: const Color(0xFF0D47A1),
                    bgColor: const Color(0xFFE0EAFF),
                    items: _split(widget.surgeries),
                  ),
                  const SizedBox(height: 16),
                  _contactCard(),
                  const SizedBox(height: 20),
                  _disclaimer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_blue, _red],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Emergency Info',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.3)),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  Text('No Login',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _patientCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_blue, _blueLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: _blue.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
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
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _pill(Icons.cake_rounded, 'Age ${widget.age}'),
                    _pill(_genderIcon(widget.gender), widget.gender),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.25), shape: BoxShape.circle),
            child: const Icon(Icons.emergency_rounded,
                color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String label) {
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
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _bloodGroupCard() {
    final bg = widget.bloodGroup.trim().isEmpty ? 'N/A' : widget.bloodGroup.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Icon + label
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: _softRed,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.bloodtype_rounded,
                      color: _red, size: 22),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Blood Group',
                        style: TextStyle(
                            color: _darkText,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 3),
                    Text('Patient blood type',
                        style:
                        TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          // Big value box
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              color: _softRed,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _red.withValues(alpha: 0.4)),
            ),
            child: Text(
              bg,
              style: const TextStyle(
                  color: _red,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _allergiesCard() {
    final items = _split(widget.allergies);
    final hasAllergies =
    !(items.length == 1 && items[0] == 'None recorded');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAllergies ? _red.withValues(alpha: 0.35) : _lightBlue,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3)),
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
                    color: hasAllergies ? _softRed : _lightBlue,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.warning_rounded,
                    color: hasAllergies ? _red : _blue, size: 18),
              ),
              const SizedBox(width: 10),
              Text('Allergies',
                  style: TextStyle(
                      color: hasAllergies ? _red : _darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              if (hasAllergies) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                    Border.all(color: _red.withValues(alpha: 0.4)),
                  ),
                  child: const Text('CRITICAL',
                      style: TextStyle(
                          color: _red,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              final isNone = item == 'None recorded';
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
                child: Text(item,
                    style: TextStyle(
                        color: isNone ? _blue : _red,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
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
              offset: const Offset(0, 3)),
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
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      color: _darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
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
                        color: iconColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item,
                        style: const TextStyle(
                            color: _darkText,
                            fontSize: 14,
                            height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard() {
    final contactName = widget.emergencyContactName.trim().isEmpty
        ? 'Not provided'
        : widget.emergencyContactName.trim();
    final contactPhone = widget.emergencyContactPhone.trim().isEmpty
        ? 'Not provided'
        : widget.emergencyContactPhone.trim();
    final canCall = widget.emergencyContactPhone.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: _softRed, borderRadius: BorderRadius.circular(6)),
            child: const Text('EMERGENCY CONTACT',
                style: TextStyle(
                    color: _red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
          ),
          const SizedBox(height: 18),

          // Name row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: _lightBlue,
                    borderRadius: BorderRadius.circular(10)),
                child:
                const Icon(Icons.person_rounded, color: _blue, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contact Name',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 3),
                    Text(contactName,
                        style: const TextStyle(
                            color: _darkText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: _lightBlue),
          const SizedBox(height: 14),

          // Phone row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: canCall ? _lightBlue : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.phone_rounded,
                    color: canCall ? _blue : Colors.grey, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Phone Number',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 3),
                    Text(
                      contactPhone,
                      style: TextStyle(
                          color: canCall ? _blue : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: canCall ? 0.5 : 0),
                    ),
                  ],
                ),
              ),
              if (canCall)
                GestureDetector(
                  onTap: () => _call(widget.emergencyContactPhone),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _red,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: _red.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.call_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text('Call',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _disclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
                  color: Colors.grey.shade500, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}