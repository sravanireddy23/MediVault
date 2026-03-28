import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const SettingsScreen({
    super.key,
    this.userName  = 'User',
    this.userEmail = '',
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _blue      = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF1E88E5);
  static const _lightBlue = Color(0xFFE3F2FD);
  static const _darkText  = Color(0xFF1A1A2E);
  static const _red       = Color(0xFFD32F2F);

  String get _initials {
    final parts = widget.userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : 'U';
  }

  // ── Change Password via Firebase ──────────────────────────────────────────
  Future<void> _changePassword() async {
    final email = widget.userEmail.isNotEmpty
        ? widget.userEmail
        : FirebaseAuth.instance.currentUser?.email ?? '';

    if (email.isEmpty) {
      _showSnack('No email found for this account', isError: true);
      return;
    }

    // Show confirmation dialog first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: _blue, size: 22),
            SizedBox(width: 8),
            Text('Change Password',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _darkText)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A password reset link will be sent to:',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _lightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                email,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _blue),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your inbox and follow the link to reset your password.',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        _showSnack('Password reset email sent to $email', isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Failed to send reset email. Try again.', isError: true);
      }
    }
  }

  // ── Data Privacy ──────────────────────────────────────────────────────────
  void _showDataPrivacy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.privacy_tip_rounded,
                          color: Color(0xFF8E24AA), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('Data Privacy Policy',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _darkText)),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    _privacySection(
                      '📋 What We Collect',
                      'MediVault collects your name, date of birth, gender, blood group, medical history, allergies, medications, surgeries, emergency contact, and the medical records you upload.',
                    ),
                    _privacySection(
                      '🔒 How We Store It',
                      'Your data is stored securely using Firebase Firestore (Google Cloud) and your files are stored on AWS S3 with encrypted storage. We use industry-standard security protocols.',
                    ),
                    _privacySection(
                      '🚫 What We Don\'t Do',
                      'We do not sell your data to third parties. We do not use your medical records for advertising. We do not share your information without your consent.',
                    ),
                    _privacySection(
                      '🤖 AI Usage',
                      'When you use AI Explain, your record content is sent to Anthropic\'s Claude API to generate explanations. This data is not stored by Anthropic beyond the request.',
                    ),
                    _privacySection(
                      '🗑️ Deleting Your Data',
                      'You can delete individual records at any time from the My Records screen. To delete your entire account and all data, use the Delete Account option in Settings.',
                    ),
                    _privacySection(
                      '📬 Contact',
                      'For any privacy concerns, contact us at medivault.health@gmail.com. We will respond within 48 hours.',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last updated: March 2025',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _privacySection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _darkText)),
          const SizedBox(height: 6),
          Text(body,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.5)),
        ],
      ),
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: _red, size: 22),
            SizedBox(width: 8),
            Text('Logout',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: _darkText)),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // ── Delete Account ────────────────────────────────────────────────────────
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: _red, size: 22),
            SizedBox(width: 8),
            Text('Delete Account',
                style: TextStyle(
                    color: _red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'This will permanently delete your account and ALL medical records. This action cannot be undone.',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey[600])),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack(
                  'Please contact medivault.health@gmail.com to delete your account',
                  isError: false);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: _red,
              side: const BorderSide(color: _red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── About ─────────────────────────────────────────────────────────────────
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.local_hospital_rounded, color: _blue, size: 22),
            SizedBox(width: 8),
            Text('MediVault',
                style: TextStyle(
                    color: _darkText, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _lightBlue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Version 1.0.0',
                  style: TextStyle(
                      color: _blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            Text(
              'Your lifelong medical records — secure, organized, always accessible.',
              style: TextStyle(
                  color: Colors.grey[600], fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Built with ❤️ for better personal healthcare.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email_outlined,
                    size: 14, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text('medivault.health@gmail.com',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(color: _blue)),
          ),
        ],
      ),
    );
  }

  // ── Snack ─────────────────────────────────────────────────────────────────
  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _red : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: Duration(seconds: isError ? 3 : 4),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
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
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'Account',
                    Icons.manage_accounts_rounded,
                    _buildAccountSection(),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    'App Info',
                    Icons.info_outline_rounded,
                    _buildAppInfoSection(),
                  ),
                  const SizedBox(height: 24),
                  // ── Danger zone ───────────────────────────────────────────
                  _buildDangerZone(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      elevation: 0,
      backgroundColor: _blue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
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
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 2),
                    ),
                    child: Center(
                      child: Text(_initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.userName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        const Text('Settings & Preferences',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section wrapper ───────────────────────────────────────────────────────
  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
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
    );
  }

  // ── Account section ───────────────────────────────────────────────────────
  Widget _buildAccountSection() {
    return Column(
      children: [
        _tappableTile(
          icon: Icons.lock_reset_rounded,
          iconColor: const Color(0xFF1565C0),
          iconBg: const Color(0xFFE3F2FD),
          label: 'Change Password',
          subtitle: 'Send a reset link to your email',
          onTap: _changePassword,
        ),
        _divider(),
        _tappableTile(
          icon: Icons.privacy_tip_rounded,
          iconColor: const Color(0xFF8E24AA),
          iconBg: const Color(0xFFF3E5F5),
          label: 'Data Privacy',
          subtitle: 'How we store and use your data',
          onTap: _showDataPrivacy,
        ),
        _divider(),
        _tappableTile(
          icon: Icons.download_rounded,
          iconColor: const Color(0xFF00838F),
          iconBg: const Color(0xFFE0F7FA),
          label: 'Download My Data',
          subtitle: 'Export all records — coming soon',
          onTap: () => _showSnack('Export feature coming soon!',
              isError: false),
        ),
        _divider(),
        _tappableTile(
          icon: Icons.logout_rounded,
          iconColor: _red,
          iconBg: const Color(0xFFFFEBEE),
          label: 'Logout',
          labelColor: _red,
          onTap: _confirmLogout,
        ),
      ],
    );
  }

  // ── App Info section ──────────────────────────────────────────────────────
  Widget _buildAppInfoSection() {
    return Column(
      children: [
        _tappableTile(
          icon: Icons.info_outline_rounded,
          iconColor: const Color(0xFF546E7A),
          iconBg: const Color(0xFFECEFF1),
          label: 'About MediVault',
          subtitle: 'Version 1.0.0',
          onTap: _showAboutDialog,
        ),
      ],
    );
  }

  // ── Danger zone ───────────────────────────────────────────────────────────
  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.warning_rounded,
                  color: _red, size: 15),
            ),
            const SizedBox(width: 10),
            const Text('Danger Zone',
                style: TextStyle(
                    color: _red,
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
            border: Border.all(
                color: _red.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: _tappableTile(
            icon: Icons.delete_forever_rounded,
            iconColor: _red,
            iconBg: const Color(0xFFFFEBEE),
            label: 'Delete Account',
            labelColor: _red,
            subtitle: 'Permanently removes all your data',
            onTap: _confirmDeleteAccount,
          ),
        ),
      ],
    );
  }

  // ── Tile helpers ──────────────────────────────────────────────────────────
  Widget _tappableTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    String? subtitle,
    Color? labelColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: labelColor ?? _darkText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 12)),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[300], size: 20),
          ],
        ),
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
}